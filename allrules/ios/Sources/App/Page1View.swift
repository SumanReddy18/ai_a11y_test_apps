import SwiftUI

/// Page 1 — label & control violations (13 fixtures). Each fixture is a single
/// element; the rule it violates is named in the comment above it. No chrome:
/// every visible element on this page IS a violation.
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
                Button(action: {}) { Image(systemName: "plus").frame(width: 44, height: 44) }
                    .accessibilityLabel("Add")
                Button(action: {}) { Image(systemName: "plus.circle").frame(width: 44, height: 44) }
                    .accessibilityLabel("Add")

                // imageview-element-content-label: exact stop word "image" as the label.
                bundledImage("meaningful_img_01.jpg")
                    .resizable()
                    .frame(width: 72, height: 72)
                    .accessibilityElement()
                    .accessibilityLabel("image")

                // interactive-element-unsupported-type: accessible + tappable element of
                // type Image with ALL traits removed (empty traitsStringArray).
                Image(systemName: "cart")
                    .frame(width: 44, height: 44)
                    .accessibilityElement()
                    .accessibilityLabel("Cart")
                    .accessibilityRemoveTraits(.isImage)
                    .onTapGesture {}
            }

            HStack(spacing: 18) {
                // button-element-content-label-capitalization: first word lowercase.
                Button("submit now") {}
                // label-at-front: accessible name does not START WITH the visible text.
                Button("Submit") {}.accessibilityLabel("Tap here to Submit")
                // label-in-name: accessible name does not CONTAIN the visible text.
                Button("Confirm") {}.accessibilityLabel("Send form")
            }

            HStack(spacing: 18) {
                // special-character-element-content-label: emoji in the accessible name.
                Button("Notifications") {}.accessibilityLabel("Notifications 🔔")
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
