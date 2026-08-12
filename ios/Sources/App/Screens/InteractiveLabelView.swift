import SwiftUI

/// Rule 3 — Interactive element accessibility label.
///
/// Buttons, toggles, and text fields whose accessible names are missing, generic,
/// contextually wrong, or empty. Mirrors activity_interactive_label.xml (iOS has no
/// native checkbox, so the Android Switch + Checkbox groups both map to Toggle here).
struct InteractiveLabelView: View {
    @State private var toggleMissing = false
    @State private var toggleGeneric = false
    @State private var checkMissing  = false
    @State private var checkGeneric  = false
    @State private var editMissing   = ""
    @State private var editEmail     = ""
    @State private var editNamed     = ""

    private let columns = [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)]

    // SF Symbol | (bad) label — nil = missing entirely
    private let iconButtons: [(symbol: String, label: String?)] = [
        ("heart.fill",              nil),           // 1: missing
        ("square.and.arrow.up",     "button"),      // 2: generic
        ("trash.fill",              "share"),       // 3: contextually wrong
        ("exclamationmark.triangle","" ),           // 4: empty
        ("chevron.right",           "ic_chevron"),  // 5: filename
        ("person.circle",           "icon"),        // 6: generic
    ]

    var body: some View {
        RuleScreen {
            caption("AI: check_accessibility_label",
                    "interactable-element-content-label · missing / generic / wrong names")

            // Icon buttons / tappable views.
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Array(iconButtons.enumerated()), id: \.offset) { _, b in
                    Button(action: {}) {
                        Image(systemName: b.symbol)
                            .resizable().scaledToFit().padding(22)
                            .frame(height: 84)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Theme.textPrimary)
                            .background(Theme.card)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.cardBorder, lineWidth: 1))
                            .cornerRadius(8)
                    }
                    .modifier(MaybeLabel(label: b.label))
                }

                // 7 & 8: custom tappable coloured views with no label at all.
                ForEach([Theme.brandPrimary, Theme.violationRed], id: \.self) { color in
                    color
                        .frame(height: 84)
                        .cornerRadius(8)
                        .onTapGesture {}
                        .accessibilityAddTraits(.isButton) // interactive, but no name
                }
            }

            caption("AI: check_accessibility_label",
                    "switch-element-content-label · iOS has no native checkbox, so both pairs are Toggles")

            // Switch-style toggles: missing, then generic label.
            Toggle("", isOn: $toggleMissing).labelsHidden().padding(.top, 8)
            Toggle("", isOn: $toggleGeneric).labelsHidden().padding(.top, 8)
                .accessibilityLabel("switch")

            // Checkbox-style toggles: same two failures again.
            Toggle("", isOn: $checkMissing).labelsHidden().padding(.top, 12)
            Toggle("", isOn: $checkGeneric).labelsHidden().padding(.top, 8)
                .accessibilityLabel("checkbox")

            caption("AI: check_accessibility_label",
                    "editable-element-content-label · both fields below FAIL deterministically")

            // No placeholder, no accessibility label → missing name.
            TextField("", text: $editMissing)
                .textFieldStyle(.roundedBorder)
                .padding(.top, 8)

            // A visible "Email" caption that is NOT programmatically associated with
            // the field below it, so the field still has no accessible name.
            Text("Email")
                .font(.system(size: 12))
                .foregroundColor(Theme.textSecondary)
                .padding(.top, 12)
            TextField("", text: $editEmail)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)

            // ─────────────────────────────────────────────────────────────────
            // Everything above has a MISSING label, which is the deterministic
            // FAIL branch of each rule — the AI is never asked to judge anything,
            // so the screen could look full of violations while the AI was dead.
            // That is the RCA-1294 failure mode. The element below carries a
            // label that is PRESENT but poor, which is the only way this rule
            // reaches AI review.
            // ─────────────────────────────────────────────────────────────────
            caption("AI: check_accessibility_label",
                    "editable-element-content-label · expects \"Meaningful Label\"")

            TextField("Name", text: $editNamed)
                .textFieldStyle(.roundedBorder)

            // ─────────────────────────────────────────────────────────────────
            // Deterministic only — NOT AI-attributed.
            //
            // The AI returns a rulesViolated list, and app-accessibility fans the
            // entries out onto their own rules via AI_DETECTED_ISSUES::RULE_MAPPING
            // ("Label in Name" -> label-in-name, "Label at Front" -> label-at-front,
            // "Label with State" -> state-in-content-label, and two more). But all
            // five of those rules sit in RULES_WITH_AI_FEATURE_DISABLED, and both
            // callback paths skip a mapped rule that appears in that list — so the
            // AI half of these rules is switched off server-side today.
            //
            // They are kept here because the ON-DEVICE rules still evaluate them
            // and had no fixture at all, so this is real coverage. Just do not read
            // them as evidence that AI is working: only "Label Missing" and
            // "Meaningful Label" surface that, and always on the submitting rule.
            // ─────────────────────────────────────────────────────────────────
            caption("Deterministic only — AI fan-out disabled",
                    "label-in-name · label-at-front · state-in-content-label")

            // Visible "Submit", announced "Send form". Same on both platforms.
            Button("Submit") {}
                .accessibilityLabel("Send form")

            // iOS scores label-at-front DIFFERENTLY from Android: it fails when the
            // name begins with a TRAIT word ("button"/"btn"/"link"/"image"/"img"/
            // "search"). Android's "Tap to Search flights" would pass here.
            Button("Save") {}
                .accessibilityLabel("Button Save changes")

            // Also iOS-specific: a REPEATED "selected" on buttons. Switches key on
            // "0"/"1" and sliders on duplicate percentages — never "on"/"off" the
            // way the Android switch branch does.
            Button("Standard delivery") {}
                .accessibilityLabel("Standard delivery selected, selected")
        }
    }

    /// On-screen label naming what the elements under it are expected to raise, so a
    /// reviewer can read the expected result off a screenshot instead of the source.
    private func caption(_ task: String, _ rules: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(task)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(Theme.brandPrimary)
            Text(rules)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 18)
        .accessibilityHidden(true)   // fixture scaffolding, not part of the test surface
    }
}

/// Applies an accessibility label only when one is provided (nil = leave the element unnamed).
private struct MaybeLabel: ViewModifier {
    let label: String?
    func body(content: Content) -> some View {
        if let label { content.accessibilityLabel(Text(label)) } else { content }
    }
}
