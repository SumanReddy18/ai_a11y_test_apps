import SwiftUI

/// Rule 4 — Meaningful reading order. Mirrors activity_reading_order.xml.
///
/// The violation IS the layout order. There is no `.accessibilitySortPriority` scrambling here
/// on purpose: a signup form has one logical sequence — name, then password, then confirm it,
/// then submit — and this screen lays that out upside down. VoiceOver follows layout order, so
/// it reaches "Signup now" first and "Enter name" last, asking the user to submit before being
/// given anything to fill in.
///
/// That is what the judge reports: "the focus order follows an illogical bottom-to-top sequence
/// instead of a logical top-to-bottom reading path".
///
/// Every element is INTERACTIVE (two Buttons, three text fields). The rule evaluates the focus
/// order of interactive elements, so this is a stronger test than static text with traversal
/// overrides. Expect the editable-element / input-label rules to report here too — the fields
/// are named only by their placeholders, which is what makes the form read as shown.
struct ReadingOrderView: View {
    @State private var confirmPassword = ""
    @State private var password = ""
    @State private var name = ""

    var body: some View {
        RuleScreen {
            Card {
                // 1st in focus order, last in logic: submit, before anything has been entered.
                cta("Signup now")

                // Confirm a password that has not been asked for yet.
                SecureField("Confirm password", text: $confirmPassword)
                    .inputRow()

                cta("Login now", top: 18)

                SecureField("Enter password", text: $password)
                    .inputRow()

                // Last in focus order, first in logic.
                TextField("Enter name", text: $name)
                    .inputRow()
            }
        }
    }

    private func cta(_ label: String, top: CGFloat = 0) -> some View {
        Button(action: {}) {
            Text(label).foregroundColor(.white).frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Theme.brandPrimary).cornerRadius(8)
        }
        .padding(.top, top)
    }
}

private extension View {
    func inputRow() -> some View {
        self
            .font(.system(size: 15))
            .foregroundColor(Theme.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .background(Theme.card)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.cardBorder, lineWidth: 1))
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .padding(.top, 18)
    }
}
