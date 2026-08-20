import SwiftUI

/// Page 1 — labels, controls, text, contrast and geometry (former pages 1 + 2
/// merged: two sparse screens wasted viewport, and the scan sees more rules per
/// snapshot this way). Each fixture is a single element; the rule it violates is
/// named in the comment above it. No chrome: every visible element IS a violation.
///
/// LAYOUT RULE: every row must fit a 390pt-wide screen inside 20pt padding
/// (350pt usable) — the rule processor SKIPS any element that is not fully
/// inside the screen bounds, which is exactly how the old oversized second row
/// silently killed the "Cart" fixture on this page.
///
/// This page must NOT sit in a ScrollView (responsive-containers passes any
/// element with a ScrollView ancestor) and keeps landscape support (see
/// AppDelegate) — only the forms page locks orientation.
struct Page1View: View {
    @State private var toggleOn = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 24) {
                // interactable-element-content-label: button whose label/value/name are all empty.
                Button(action: {}) {
                    Rectangle().fill(Color.orange).frame(width: 100, height: 44)
                }
                .accessibilityLabel("")

                // screen-reader-for-interactive-elements: unlabeled icon button — the
                // screen-reader rule reports alongside the failing label rule.
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up").frame(width: 44, height: 44)
                }
                .accessibilityLabel("")

                // switch-element-content-label: UISwitch with no accessible name.
                Toggle("", isOn: $toggleOn).labelsHidden()
            }

            HStack(spacing: 12) {
                // duplicate-accessibility-label: the same "Add" on two separate buttons.
                // UIKit-backed: the rule gates on hittable(), and the capture never emits
                // isHittable for SwiftUI accessibility nodes (defaults "0" → skipped).
                KitButton(title: "Add").frame(width: 56, height: 48)
                KitButton(title: "Add").frame(width: 56, height: 48)

                // imageview-element-content-label: accessible UIImageView with NO label —
                // deterministic FAIL.
                KitImageView(imageName: "meaningful_img_01.jpg")
                    .frame(width: 64, height: 64)

                // interactive-element-unsupported-type: a recognised control class
                // (UIButton) whose traits are EMPTY — the only shape the iOS rule fails.
                // Also fires missing-view-type-in-spoken-output (caption has no role word).
                KitButton(title: "Cart", clearTraits: true).frame(width: 84, height: 48)
            }

            HStack(spacing: 16) {
                // button-element-content-label-capitalization: first word lowercase.
                Button("submit now") {}
                // label-at-front: on iOS the rule fails a label that STARTS WITH a trait
                // word ("button", "link", "image", "search").
                Button("Submit") {}.accessibilityLabel("Button Submit")
                // label-in-name: visible text not contained in the accessible name.
                // UIKit-backed: for SwiftUI nodes the capture sets text = the label itself,
                // so the rule can never fail; UIButton.currentTitle is real visible text.
                KitButton(title: "Confirm", accessibilityLabel: "Send form")
                    .frame(width: 96, height: 44)
            }

            HStack(spacing: 16) {
                // special-character-element-content-label: the iOS rule fails only a
                // SYMBOL-ONLY label (zero alphanumerics) — deterministic.
                Button("Notifications") {}.accessibilityLabel("🔔")
                // view-type-in-content-label: role word "Button" duplicated in the name.
                Button("Play") {}.accessibilityLabel("Play Button Button")
                // state-in-content-label: state word "selected" duplicated in the name.
                Button("Filter") {}.accessibilityLabel("Selected filter, selected")
            }

            HStack(spacing: 24) {
                // special-character (second, UIKit-backed shape): symbol-only UILabel —
                // its accessibilityLabel IS its text, zero alphanumerics.
                KitLabel(text: "★♥➜", size: 17).frame(width: 64, height: 24)

                // duplicate-accessibility-label (second, shape-diverse pair): plain
                // UIViews with the .button trait — the exact element shape the duplicate
                // rule demonstrably processed in earlier scans.
                KitTraitButton(label: "Bookmark").frame(width: 48, height: 44)
                KitTraitButton(label: "Bookmark").frame(width: 48, height: 44)
            }

            // images-of-text: bitmap with baked-in words; none of them exist as real
            // text elements on this page, so the AI check has nothing to match.
            bundledImage("unsplash_text_01.jpg")
                .resizable()
                .frame(width: 300, height: 90)
                .accessibilityLabel("Promotional banner")

            HStack(spacing: 24) {
                // text-color-contrast: #999999 on white at 14pt ≈ 2.85:1 (< 4.5:1).
                // UIKit-backed: swatches are captured off UIKit text classes only.
                // lines: 0 keeps the may-clip flag off so this doesn't also fire truncation.
                KitLabel(text: "Low contrast body copy", size: 14,
                         color: UIColor(white: 0.6, alpha: 1), lines: 0)
                    .frame(width: 180, height: 20)

                // non-text-contrast: light-grey glyph on white ≈ 2.0:1 (< 3.0:1).
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(white: 0.73))
                    .background(Color.white)
                    .accessibilityLabel("Next")
            }

            HStack(spacing: 20) {
                // text-magnification: fixed-size custom font — no Dynamic Type support.
                Text("This text will not scale")
                    .font(.custom("Helvetica", size: 17))

                // text-truncation: fixed 140pt frame clips the line. UIKit-backed:
                // the may-clip flag is computed from UILabel.numberOfLines.
                KitLabel(text: "Order confirmation details for your recent purchase",
                         size: 17, lines: 1)
                    .frame(width: 140, height: 20)
            }

            HStack(spacing: 24) {
                // touch-target-size: 30pt < 44pt on both axes; kept ≥24pt from
                // neighbours so the spacing rule does not also fire here.
                Button(action: {}) {
                    Image(systemName: "xmark").frame(width: 30, height: 30)
                }
                .accessibilityLabel("Close")

                // touch-target-size-and-spacing: two 20pt targets touching (centres
                // 20pt apart < 24pt). Labels differ so the same-label ancestor
                // exemption cannot apply.
                HStack(spacing: 0) {
                    Button(action: {}) {
                        Image(systemName: "hand.thumbsup").frame(width: 20, height: 20)
                    }
                    .accessibilityLabel("Like")
                    Button(action: {}) {
                        Image(systemName: "hand.thumbsdown").frame(width: 20, height: 20)
                    }
                    .accessibilityLabel("Dislike")
                }

                // overlapping-interactive-elements: two buttons, byte-identical frames.
                // KNOWN ENGINE DEAD-END on iOS: hittability is a hitTest at the element's
                // centre — of two views sharing a frame, at most ONE can own the shared
                // centre pixel, so a same-bounds pair never survives the filter. Kept for
                // the day the engine softens the hittable gate.
                ZStack {
                    Button(action: {}) {
                        Text("Buy now").frame(width: 160, height: 44)
                    }
                    Button(action: {}) {
                        Color.clear.frame(width: 160, height: 44)
                    }
                    .accessibilityLabel("Buy now overlay")
                }
            }

            HStack(alignment: .top, spacing: 20) {
                // responsive-containers: StaticText with a fixed-frame ancestor chain and
                // no ScrollView anywhere above it. KNOWN ENGINE DEAD-END on iOS (the
                // ancestor walk aborts NA on plain UIView/UIWindow) — kept for parity.
                VStack { Text("Reflow violation sample") }
                    .frame(width: 140, height: 44)

                // two-dimensional-scroll: real UIScrollView with oversize content —
                // the rule matches type == "UIScrollView" literally.
                KitTwoAxisScroll().frame(width: 180, height: 100)
            }

            // missing-heading: heading-styled text (title2 bold over footnote body)
            // with NO .isHeader trait anywhere on this page's section titles.
            Text("Order Summary").font(.title2.bold())
            Text("3 items · Delivered Friday").font(.footnote)
            Text("Payment Method").font(.title2.bold())
            Text("Visa ending 4242").font(.footnote)

            // incorrect-heading: small body text wrongly carrying the header trait.
            Text("Info")
                .font(.footnote)
                .accessibilityAddTraits(.isHeader)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
