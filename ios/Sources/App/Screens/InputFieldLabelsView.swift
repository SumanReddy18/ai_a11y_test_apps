import SwiftUI

/// Rule 9 — Input field labels. Covers BOTH input-purpose checks on one screen:
///
///  * **Accessible input field labels** (violations 1–3) — text fields whose visible caption is
///    only a neighbouring `Text` (nothing associates the two), fields with no name at all, and
///    fields named only by a placeholder, which vanishes the moment the user types.
///  * **Input type for input fields** (violations 4–5) — fields that ARE labelled correctly but
///    whose `keyboardType` / `textContentType` contradicts that label, and sensitive fields
///    entered through a plain `TextField` instead of a `SecureField`.
///
/// Mirrors activity_input_field_labels.xml. NOTE (the gotcha): a SwiftUI `TextField`'s
/// placeholder string becomes its accessibility label, so a field must be created with an EMPTY
/// placeholder (`TextField("", …)`) to be genuinely unnamed to VoiceOver.
struct InputFieldLabelsView: View {
    @State private var name = ""
    @State private var surname = ""
    @State private var phone = ""
    @State private var code1 = ""
    @State private var code2 = ""
    @State private var code3 = ""
    @State private var address1 = ""
    @State private var address2 = ""
    @State private var emailHint = ""
    @State private var cityHint = ""
    @State private var dobHint = ""
    @State private var emailTyped = ""
    @State private var mobileTyped = ""
    @State private var amountTyped = ""
    @State private var urlTyped = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var cvv = ""

    var body: some View {
        RuleScreen {
            AiCaption(task: "AI: check_input_field_purpose",
                      rules: "accessible-input-field-label + input-type-for-input-field · also raises check_accessibility_label (any editable)")

            // ---- Sub-rule A: accessible input field labels -------------------------------
            // Sign-up form: captions not linked to their inputs.
            Card {
                caption("Full name")
                field($name)
                caption("Surname", top: 14)
                field($surname)
                // Caption says "Phone number", the field takes free text.
                caption("Phone number", top: 14)
                field($phone)
            }

            // No label at all — bare inputs.
            Card {
                Text("Enter the 3-digit code we sent you")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                HStack(spacing: 8) {
                    field($code1).multilineTextAlignment(.center)
                    field($code2).multilineTextAlignment(.center)
                    field($code3).multilineTextAlignment(.center)
                }
                .padding(.top, 6)

                // Two address lines, completely unnamed.
                field($address1).padding(.top, 14)
                field($address2).padding(.top, 8)
            }

            // Placeholder used instead of a label.
            Card {
                // The placeholder is the ONLY thing naming these fields, and it is gone as
                // soon as there is any text — the label is not persistent.
                TextField("Email", text: $emailHint).inputBox()
                TextField("City", text: $cityHint).inputBox().padding(.top, 10)
                TextField("DD / MM / YYYY", text: $dobHint).inputBox().padding(.top, 10)
            }

            // ---- Sub-rule B: input type for input fields ---------------------------------
            // Input type contradicts the label.
            Card {
                // These fields ARE named properly (visible caption + accessibilityLabel), so
                // the label sub-rule passes. What fails is the TYPE: the keyboard and content
                // type are wrong for the data the label asks for.
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

                caption("Amount (USD)", top: 14)
                TextField("0.00", text: $amountTyped)
                    .keyboardType(.default)
                    .textContentType(.name)
                    .inputBox()
                    .accessibilityLabel("Amount in US dollars")

                caption("Website URL", top: 14)
                TextField("https://example.com", text: $urlTyped)
                    .keyboardType(.decimalPad)
                    .inputBox()
                    .accessibilityLabel("Website URL")
            }

            // Sensitive fields without a secure input type.
            Card {
                // Passwords and the CVV go through a plain TextField, so characters are not
                // masked and the element is a text field rather than a secure one — the half of
                // this sub-rule iOS reliably exposes (keyboardType is not in the AX tree, the
                // .secureTextField element type is). Each one also *declares* a sensitive
                // autofill purpose via textContentType, which contradicts the plain entry.
                caption("Password")
                TextField("Enter your password", text: $password)
                    .textContentType(.password)
                    .inputBox()
                    .accessibilityLabel("Password")

                // Password purpose, email keyboard, no masking.
                caption("Confirm password", top: 14)
                TextField("Re-enter your password", text: $confirmPassword)
                    .textContentType(.password)
                    .keyboardType(.emailAddress)
                    .inputBox()
                    .accessibilityLabel("Confirm password")

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
