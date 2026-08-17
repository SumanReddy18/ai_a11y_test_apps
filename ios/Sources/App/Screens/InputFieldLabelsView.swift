import SwiftUI

/// Rule 9 — Input field labels. Covers BOTH input-purpose checks on one screen:
///
///  * **Accessible input field labels** — fields whose visible caption is only a neighbouring
///    `Text` (nothing associates the two), a field with no name at all, and fields named only by
///    a placeholder, which vanishes the moment the user types.
///  * **Input type for input fields** — fields that ARE labelled correctly but whose
///    `keyboardType` / `textContentType` contradicts that label, and sensitive fields entered
///    through a plain `TextField` instead of a `SecureField`.
///
/// Sized to ONE viewport on purpose. `RuleScreen` no longer scrolls itself, so anything that does
/// not fit is never captured. This is the same nine-field, four-card set the Android
/// all-violations screen uses, which is known to fit a single viewport while still covering all
/// four sub-cases. Trimmed down from eighteen fields; if you add one, drop another.
///
/// NOTE (the gotcha): a SwiftUI `TextField`'s placeholder string becomes its accessibility label,
/// so a field must be created with an EMPTY placeholder (`TextField("", …)`) to be genuinely
/// unnamed to VoiceOver. The iOS label rule also FAILs on `placeholder.present?` for any
/// accessible text field, which is what makes the placeholder-only card the violation here.
struct InputFieldLabelsView: View {
    @State private var name = ""
    @State private var phone = ""
    @State private var bare = ""
    @State private var emailHint = ""
    @State private var cityHint = ""
    @State private var emailTyped = ""
    @State private var mobileTyped = ""
    @State private var password = ""
    @State private var cvv = ""

    var body: some View {
        RuleScreen {
            // Captions not linked to their inputs — the caption sits above, nothing associates them.
            Card {
                caption("Full name")
                field($name)
                // Caption says "Phone number", the field takes free text.
                caption("Phone number", top: 14)
                field($phone)
            }

            // No name at all, then two named only by a placeholder that disappears on typing.
            Card {
                field($bare)
                TextField("Email", text: $emailHint).inputBox().padding(.top, 10)
                TextField("City", text: $cityHint).inputBox().padding(.top, 10)
            }

            // Named properly, so the label check passes; the TYPE contradicts the label.
            Card {
                caption("Email address")
                TextField("you@example.com", text: $emailTyped)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .inputBox()
                    .accessibilityLabel("Email address")

                caption("Mobile number", top: 14)
                TextField("+91 98765 43210", text: $mobileTyped)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .inputBox()
                    .accessibilityLabel("Mobile number")
            }

            // Sensitive fields through a plain TextField: not masked, and the element is a text
            // field rather than a secure one — the half of this sub-rule iOS reliably exposes
            // (keyboardType is not in the AX tree, the .secureTextField element type is).
            Card {
                caption("Password")
                TextField("Enter your password", text: $password)
                    .textContentType(.password)
                    .inputBox()
                    .accessibilityLabel("Password")

                caption("Card CVV", top: 14)
                TextField("3 digits on the back of your card", text: $cvv)
                    .textContentType(.creditCardNumber)   // label says CVV, purpose says card number
                    .keyboardType(.default)
                    .inputBox()
                    .accessibilityLabel("Card CVV")
            }
        }
    }

    /// A visible caption. It sits above the field but nothing associates the two — the iOS
    /// analogue of a TextView with no `android:labelFor`.
    private func caption(_ text: String, top: CGFloat = 0) -> some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundColor(Theme.textPrimary)
            .padding(.top, top)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// An input with an EMPTY placeholder — no accessible name at all.
    private func field(_ text: Binding<String>) -> some View {
        TextField("", text: text).inputBox()
    }
}

private extension View {
    /// Bordered text-field chrome shared by every input on this screen.
    func inputBox() -> some View {
        self
            .font(.system(size: 15))
            .foregroundColor(Theme.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .background(Theme.card)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.cardBorder, lineWidth: 1))
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .padding(.top, 4)
    }
}
