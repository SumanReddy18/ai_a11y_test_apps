import SwiftUI
import UIKit

/// Page 3 — form, order and focus violations (11 fixtures), plus the per-screen
/// orientation violation: this page (only) locks to portrait via AppDelegate.
struct Page3View: View {
    @State private var email = ""
    @State private var address = ""
    @State private var card = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // editable-element-content-label: the caption is not programmatically
            // associated, and the EMPTY placeholder leaves the field with no
            // accessible name at all.
            Text("Email")
            TextField("", text: $email)
                .textFieldStyle(.roundedBorder)
                .frame(width: 280)

            // accessible-input-field-label: the iOS engine FAILs "placeholder used in
            // lieu of a label" — so this field needs a NON-empty placeholder and no
            // accessibility label (the opposite shape of the field above).
            TextField("Enter shipping address", text: $address)
                .textFieldStyle(.roundedBorder)
                .frame(width: 280)

            // input-type-for-input-field: a SecureTextField whose label matches the
            // Number-Input regex first → expected types exclude SecureTextField → FAIL.
            SecureField("Card number", text: $card)
                .textFieldStyle(.roundedBorder)
                .frame(width: 280)

            // meaningful-reading-order: VoiceOver order 2, 3, 1 vs visual 1, 2, 3
            // (higher sort priority is focused first).
            Text("Step 1: Enter your name").accessibilitySortPriority(1)
            Text("Step 2: Enter your email").accessibilitySortPriority(3)
            Text("Step 3: Confirm").accessibilitySortPriority(2)

            // meaningful-visual-order: inherently ordered content laid out scrambled.
            HStack { Spacer(); Text("3. Confirm order") }
            HStack { Text("1. Add to cart"); Spacer() }
            HStack { Spacer(); Text("2. Enter address"); Spacer() }

            // focus-order-for-interactive-elements: a button-trait element with a label
            // that VoiceOver never focuses (the container ignores its children), so it
            // is absent from the captured focus order. "Checkout now" must appear
            // nowhere else on screen — a caption substring match would rescue it.
            VStack {
                Text("Checkout")
                    .frame(width: 200, height: 44)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel("Checkout now")
            }
            .accessibilityElement(children: .ignore)

            // keyboard-focus-for-interactive-elements: accessible button reporting
            // accessibilityRespondsToUserInteraction == false. UIKit-only property
            // (no SwiftUI modifier), hence the representable. NOT disabled — the
            // notEnabled trait would exempt it.
            NonRespondingButton()
                .frame(width: 200, height: 44)

            // missing-view-type-in-spoken-output: a native control class (UIButton)
            // with EMPTY traits, so its caption carries no role word. A trait-bearing
            // element can never fail this rule — the capture appends trait words to the
            // caption, so .isButton always announces "button". Also fires
            // interactive-element-unsupported-type (recognised control, empty traits).
            KitButton(title: "Delete item", clearTraits: true)
                .frame(width: 200, height: 48)

            // link-text-purpose: native links whose labels are exactly stop words.
            Link("Click here", destination: URL(string: "https://example.com/policy")!)
            Link("Read more", destination: URL(string: "https://example.com/terms")!)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        // screen-orientation: portrait-only while this page is up. Pages 1-2 keep
        // landscape so responsive-containers (page 2) stays applicable.
        .onAppear { AppDelegate.lockPortrait = true }
        .onDisappear { AppDelegate.lockPortrait = false }
    }
}

/// UIKit-backed fixture for keyboard-focus-for-interactive-elements.
struct NonRespondingButton: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let v = UIView()
        v.backgroundColor = .systemTeal
        v.isAccessibilityElement = true
        v.accessibilityLabel = "Continue setup"
        v.accessibilityTraits = .button
        v.accessibilityRespondsToUserInteraction = false
        return v
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
