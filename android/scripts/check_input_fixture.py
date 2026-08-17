#!/usr/bin/env python3
"""Assert the input-field fixtures still reach the AI judge.

A field only produces an AI verdict if it:

  1. has a contentDescription (else editable-element-content-label short-circuits
     to a static FAIL and the AI is never consulted), and that label is junk
     (else the AI judges it fine and reports nothing), and
  2. PASSES accessible-input-field-label -- satisfied by a caption carrying
     android:labelFor for this field, and
  3. PASSES input-type-for-input-field -- its inputType's category must either be
     "Text Input" (always-valid bypass) or have no regex entry, or else the
     caption text must match that category's regex.

Junk labels must also be unique per screen, or duplicate-element-content-label
fires as unintended noise -- which matters on the all-violations screen, where
every field shares one screen.

Rules 2 and 3 mirror the engine at
app-accessibility/lib/bstack_rule_engine/rules/standard_rules/. If those change,
this check is what should fail first.

Run: python3 android/scripts/check_input_fixture.py
"""
import re
import sys
from pathlib import Path

LAYOUT_DIR = Path(__file__).resolve().parents[1] / "app/src/main/res/layout"

# layout -> id pattern of the fields converted to the AI_REVIEW shape. Scoped by id
# because the all-violations screen also holds EditTexts belonging to other rules'
# demos, which are deliberately left bare.
TARGETS = {
    "activity_input_field_labels.xml": r"^ifl",
    "activity_all_violations.xml": r"^av_(ed|ifl)",
}

# Mirrors TYPE_TO_CATEGORY, keyed by the XML attribute value rather than the
# decoded Android bitmask. Only the values this fixture uses are listed; add a
# row before using a new inputType. `date`/`textUri` are deliberately absent --
# both decode through the ambiguous 0x10 variation that also means
# number-password, so they land in Password Input and fail the caption match.
TYPE_TO_CATEGORY = {
    "text": "Text Input",
    "textPersonName": "Text Input",
    "textEmailAddress": "Email Input",
    "textPostalAddress": "Postal Address Input",
    "textPassword": "Password Input",
    "phone": "Phone Input",
    "number": "Number Input",
    "numberDecimal": "Number Input",
}

# Verbatim from CATEGORY_TO_REGEX in input_type_for_input_field.rb.
CATEGORY_TO_REGEX = {
    "Text Input": r"\b(name|title|description|message|text|content|comment|note|info|remarks|details|subject|summary|story|narrative|feedback|statement|memo|bio|biography|profile|thoughts|opinion)\b|[\/]",
    "Email Input": r"\b(email|e-mail|email address|mailbox)\b|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z]{2,}",
    "Phone Input": r"\b(phone|mobile|contact|cell|telephone|tel|fax|whatsapp|emergency|hotline|dial|call)\b|\+?\d{1,3}[-.\s]?\d{7,15}",
    "Number Input": r"\b(number|num|qty|quantity|count|amount|price|cost|total|value|age|size|weight|height|score|rating|measure|volume|percentage|percent|degree|capacity|speed|distance|limit|pincode|zipcode|zip|postal)\b|\b\d+(\.\d+)?\b",
    "Date & Time Input": r"\b(date|time|year|month|day|hour|minute|second|birthday|dob|schedule|appointment|anniversary|timestamp|deadline|reminder)\b|\d{1,4}[-\/]\d{1,2}[-\/]\d{1,4}|\b\d{1,2}:\d{2}(\s?(AM|PM))?\b",
    "Password Input": r"\b(password|pass|pwd|security|auth|credential|cvv|pin|key|access code|login|verification|otp|secret|passphrase|token)\b",
}

# A junk label is the whole point of the fixture. If someone "fixes" these to
# read like real labels, the AI stops reporting and the screen goes silent.
JUNK = re.compile(r"^field \d+$")


def attr(tag, name):
    m = re.search(r'android:%s="([^"]*)"' % name, tag)
    return m.group(1) if m else None


def check(path, id_pattern):
    xml = path.read_text()
    want = re.compile(id_pattern)

    # caption id -> caption text, via labelFor
    captions = {}
    for tag in re.findall(r"<TextView\b[^>]*/>", xml, re.S):
        target = attr(tag, "labelFor")
        if target:
            captions[target.removeprefix("@+id/")] = attr(tag, "text") or ""

    fields = []
    for tag in re.findall(r"<EditText\b[^>]*/>", xml, re.S):
        fid = (attr(tag, "id") or "").removeprefix("@id/").removeprefix("@+id/")
        if want.search(fid):
            fields.append((fid, tag))
    assert fields, f"{path.name}: no EditText matching {id_pattern!r} -- ids renamed?"

    failures = []
    seen = {}
    for fid, tag in fields:
        desc = attr(tag, "contentDescription")
        itype = attr(tag, "inputType")

        if not desc:
            failures.append(f"{fid}: no contentDescription -- static FAIL, AI never runs")
            continue
        if not JUNK.match(desc):
            failures.append(f"{fid}: contentDescription {desc!r} is not junk -- AI will pass it")
        if desc in seen:
            failures.append(
                f"{fid}: contentDescription {desc!r} duplicates {seen[desc]} "
                f"-- trips duplicate-element-content-label"
            )
        seen[desc] = fid

        caption = captions.get(fid)
        if caption is None:
            failures.append(f"{fid}: no caption with labelFor -- accessible-input-field-label FAILs")
            continue

        category = TYPE_TO_CATEGORY.get(itype)
        if category is None:
            failures.append(f"{fid}: inputType {itype!r} not in TYPE_TO_CATEGORY -- add a row")
            continue

        # "Text Input" is always valid once visible text exists; a category with
        # no regex returns NOT_APPLICABLE. Neither can FAIL.
        if category == "Text Input" or category not in CATEGORY_TO_REGEX:
            continue
        if not re.search(CATEGORY_TO_REGEX[category], caption, re.I):
            failures.append(
                f"{fid}: caption {caption!r} does not match {category} regex "
                f"-- input-type-for-input-field FAILs statically"
            )

    return len(fields), failures


def main():
    rc = 0
    for name, pattern in TARGETS.items():
        count, failures = check(LAYOUT_DIR / name, pattern)
        if failures:
            rc = 1
            print(f"FAIL ({len(failures)} problem(s)) in {name}:")
            for f in failures:
                print("  -", f)
        else:
            print(f"OK {name}: {count} fields pass both static input rules, junk labels unique")
    return rc


if __name__ == "__main__":
    sys.exit(main())
