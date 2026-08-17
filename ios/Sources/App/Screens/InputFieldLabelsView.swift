import SwiftUI
import UIKit

/// Rule 9 — Input field labels, reshaped so the violation is decided by the AI judge
/// rather than by a deterministic engine branch.
///
/// This screen is engine-implementation-coupled. Read before editing:
///
/// The two input-purpose rules (`accessible-input-field-label`,
/// `input-type-for-input-field`) are STATIC-ONLY — they sit in the engine's
/// `standard_rules` bucket, appear in none of the eight `AI_TASKS`, and never return
/// `RuleStatus::AI_REVIEW`. No fixture can make them produce an AI verdict.
///
/// `editable-element-content-label` can:
///   * no content label  → `RuleStatus::FAIL` (static, the AI never runs)
///   * content label set → `RuleStatus::AI_REVIEW` (the AI judges whether it is meaningful)
///
/// So every field below deliberately SATISFIES both static input rules and carries a
/// junk `accessibilityLabel`, which is the only shape that reaches the AI judge:
///
///   * **No placeholder.** The iOS branch of the label rule FAILs on
///     `placeholder.present?` for any accessible `UITextField` — a placeholder is treated
///     as a label used in lieu of a real one, regardless of what else is on screen. Every
///     field is therefore built as `TextField("", …)` with a separate visible caption.
///   * **`SecureField` for secrets.** On iOS the type rule is only eligible for
///     `SecureTextField`, and `IOS_TYPE_TO_CATEGORY` maps the Password category to exactly
///     that type — so a masked field captioned "Password" / "Card CVV" passes, while a
///     plain `TextField` is simply not eligible.
///   * **Meaningless `accessibilityLabel`.** Present, so the rule reaches AI_REVIEW; junk,
///     so the judge scores it a violation — and the visible caption is absent from the
///     accessible name, which is a label-in-name failure too.
///
/// Do NOT "strengthen" this screen by stripping labels. A bare field short-circuits to a
/// static FAIL and the AI is never consulted.
///
/// Mirrors activity_input_field_labels.xml.
struct InputFieldLabelsView: View {
    @State private var name = ""
    @State private var surname = ""
    @State private var phone = ""
    @State private var code1 = ""
    @State private var code2 = ""
    @State private var code3 = ""
    @State private var address1 = ""
    @State private var address2 = ""
    @State private var email = ""
    @State private var city = ""
    @State private var dob = ""
    @State private var mobile = ""
    @State private var amount = ""
    @State private var url = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var cvv = ""

    var body: some View {
        RuleScreen {
            // Sign-up form.
            Card {
                caption("Full name")
                field($name, axLabel: "field 1")
                caption("Surname", top: 14)
                field($surname, axLabel: "field 2")
                caption("Phone number", top: 14)
                field($phone, axLabel: "field 3", keyboard: .phonePad)
            }

            // Verification code — one caption per box, mirroring the Android labelFor pairing.
            Card {
                Text("Enter the 3-digit code we sent you")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                HStack(spacing: 8) {
                    digit("Digit 1", $code1, axLabel: "field 4")
                    digit("Digit 2", $code2, axLabel: "field 5")
                    digit("Digit 3", $code3, axLabel: "field 6")
                }
                .padding(.top, 6)

                caption("Address line 1", top: 14)
                field($address1, axLabel: "field 7")
                caption("Address line 2", top: 14)
                field($address2, axLabel: "field 8")
            }

            // Contact details.
            Card {
                caption("Email address")
                field($email, axLabel: "field 9", keyboard: .emailAddress)
                caption("City", top: 14)
                field($city, axLabel: "field 10")
                caption("Date of birth", top: 14)
                field($dob, axLabel: "field 11")
            }

            // Payment and profile fields.
            Card {
                caption("Mobile number")
                field($mobile, axLabel: "field 12", keyboard: .phonePad)
                caption("Amount (USD)", top: 14)
                field($amount, axLabel: "field 13", keyboard: .decimalPad)
                caption("Website URL", top: 14)
                field($url, axLabel: "field 14")
            }

            // Secrets, properly masked so the type rule passes.
            Card {
                caption("Password")
                secureField($password, axLabel: "field 15")
                caption("Confirm password", top: 14)
                secureField($confirmPassword, axLabel: "field 16")
                caption("Card CVV", top: 14)
                secureField($cvv, axLabel: "field 17")
            }
        }
    }

    /// A visible caption above its field. iOS has no `labelFor` equivalent; the label rule
    /// reads the element's own placeholder and accessible name, not the association.
    private func caption(_ text: String, top: CGFloat = 0) -> some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundColor(Theme.textPrimary)
            .padding(.top, top)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// An input with an EMPTY placeholder — a placeholder alone is a static FAIL on iOS —
    /// and a present-but-meaningless accessible name, which is what the AI judges.
    private func field(
        _ text: Binding<String>,
        axLabel: String,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        TextField("", text: text)
            .keyboardType(keyboard)
            .inputBox()
            .accessibilityLabel(axLabel)
    }

    /// One box of the verification code, with its own caption.
    private func digit(
        _ label: String,
        _ text: Binding<String>,
        axLabel: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Theme.textPrimary)
            TextField("", text: text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .inputBox()
                .accessibilityLabel(axLabel)
        }
    }

    /// A masked field. `SecureTextField` is the only iOS type the input-type rule accepts
    /// for a password-category caption, so these pass it.
    private func secureField(_ text: Binding<String>, axLabel: String) -> some View {
        SecureField("", text: text)
            .inputBox()
            .accessibilityLabel(axLabel)
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
