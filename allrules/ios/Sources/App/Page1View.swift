import SwiftUI

/// Page 1 — label & control violations (13 fixtures). Each fixture is a single
/// element; the rule it violates is named in the comment above it. No chrome:
/// every visible element on this page IS a violation.
///
/// UIKit-backed fixtures (KitButton/KitImageView) are used wherever the rule
/// inspects a signal SwiftUI accessibility nodes never carry — see UIKitFixtures.swift.
struct Page1View: View {
    @State private var toggleOn = true

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 28) {
                // interactable-element-content-label: button whose label/value/name are all empty.
                Button(action: {}) {
                    Rectangle().fill(Color.orange).frame(width: 120, height: 48)
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

            HStack(spacing: 44) {
                // duplicate-accessibility-label: the same "Add" on two separate buttons.
                // UIKit-backed: the rule gates on hittable(), and the capture never emits
                // isHittable for SwiftUI accessibility nodes (defaults "0" → skipped).
                KitButton(title: "Add").frame(width: 64, height: 48)
                KitButton(title: "Add").frame(width: 64, height: 48)

                // imageview-element-content-label: accessible UIImageView with NO label —
                // deterministic FAIL. (A SwiftUI .accessibilityElement() drops the image
                // trait the rule gates on; a present label only reaches AI review.)
                KitImageView(imageName: "meaningful_img_01.jpg")
                    .frame(width: 72, height: 72)

                // interactive-element-unsupported-type: a recognised control class
                // (UIButton) whose traits are EMPTY — the only shape the iOS rule fails.
                // Also fires missing-view-type-in-spoken-output: the caption for a
                // trait-less button carries no role word.
                KitButton(title: "Cart", clearTraits: true).frame(width: 100, height: 48)
            }

            HStack(spacing: 18) {
                // button-element-content-label-capitalization: first word lowercase.
                Button("submit now") {}
                // label-at-front: on iOS the rule fails a label that STARTS WITH a trait
                // word ("button", "link", "image", "search") — not a label that rephrases
                // the visible text.
                Button("Submit") {}.accessibilityLabel("Button Submit")
                // label-in-name: visible text not contained in the accessible name.
                // UIKit-backed: for SwiftUI nodes the capture sets text = the label itself,
                // so the rule can never fail; UIButton.currentTitle is real visible text.
                KitButton(title: "Confirm", accessibilityLabel: "Send form")
                    .frame(width: 110, height: 48)
            }

            HStack(spacing: 18) {
                // special-character-element-content-label: the iOS rule fails only a
                // SYMBOL-ONLY label (zero alphanumerics) — deterministic.
                Button("Notifications") {}.accessibilityLabel("🔔")
                // view-type-in-content-label: role word "Button" duplicated in the name.
                Button("Play") {}.accessibilityLabel("Play Button Button")
                // state-in-content-label: state word "selected" duplicated in the name.
                Button("Filter") {}.accessibilityLabel("Selected filter, selected")
            }

            // images-of-text: bitmap with baked-in words; none of them exist as real
            // text elements on this page, so the AI check has nothing to match.
            bundledImage("unsplash_text_01.jpg")
                .resizable()
                .frame(width: 320, height: 110)
                .accessibilityLabel("Promotional banner")
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
