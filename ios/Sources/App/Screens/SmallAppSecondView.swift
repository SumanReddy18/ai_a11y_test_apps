import SwiftUI

/// allViolationsSmall build, page 2 of 2 — order & input violations jam-packed:
///
///  * **Meaningful reading order** — VoiceOver visits Buy → Price → Description → Title while
///    the eye reads Title → Price → Description → Buy (`accessibilitySortPriority` scramble,
///    same pattern as ReadingOrderView).
///  * **Meaningful visual order** — an inherently ordered checkout flow laid out 3 → 1 → 2.
///  * **Link text purpose** — native `Link`s named "Click here" / "Read more" (deterministic
///    stop words) plus one whose whole name is a raw URL. Each phrase is its own element;
///    an inline attributed link inside a sentence would never fire (see LinkTextPurposeView).
///  * **Input field labels** — a visible "Email" caption a scan cannot associate with the
///    unnamed `TextField("")` below it (empty placeholder = genuinely unnamed).
///  * **Input type** — a card-number `SecureField` (number-purpose label on a secure field)
///    and a password taken through a plain `TextField`.
struct SmallAppSecondView: View {
    private static let dest = URL(string: "a11ydemo://destination")!

    @State private var email = ""
    @State private var card = ""
    @State private var password = ""

    var body: some View {
        RuleScreen {
            // Meaningful reading order: sortPriority contradicts the visual order.
            Card {
                orderedLine("Wireless Keyboard K3", size: 18, bold: true,
                            color: Theme.textPrimary, priority: 3)
                orderedLine("₹2,499  (was ₹3,999)", size: 15, bold: true,
                            color: Theme.violationRed, priority: 1, top: 6)
                orderedLine("Low-profile keys, three-device Bluetooth pairing and six months of battery on one charge.",
                            size: 14, bold: false, color: Theme.textSecondary, priority: 2, top: 10)
                Button(action: {}) {
                    Text("Buy now")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24).padding(.vertical, 10)
                        .background(Theme.brandPrimary)
                        .cornerRadius(8)
                }
                .padding(.top, 12)
                .accessibilitySortPriority(4)
            }
            .accessibilityElement(children: .contain)

            // Meaningful visual order: steps of one flow scattered 3 → 1 → 2 down the page.
            Card {
                HStack { Spacer(); step("3. Confirm order") }
                HStack { step("1. Add to cart"); Spacer() }
                    .padding(.top, 10)
                HStack { Spacer(); step("2. Enter address"); Spacer() }
                    .padding(.top, 10)
            }

            // Link text purpose: each phrase is its own real link element.
            Card {
                linkRow("To view our refund policy,", "Click here")
                linkRow("New pricing is now live.", "Read more", top: 12)
                linkRow("Setup guide:",
                        "https://www.browserstack.com/docs/app-accessibility/overview?ref=smallapp",
                        top: 12)
            }

            // Input field labels: caption + unnamed field (nothing associates the two).
            Card {
                Text("Email")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.textSecondary)
                inputBox(TextField("", text: $email))

                // Input type: number-purpose label on a secure field…
                Text("Card number")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.top, 12)
                inputBox(SecureField("Card number", text: $card))

                // …and a password through a plain TextField (wrong element type entirely).
                Text("Password")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.top, 12)
                inputBox(TextField("", text: $password))
            }
        }
    }

    private func orderedLine(_ text: String, size: CGFloat, bold: Bool,
                             color: Color, priority: Double, top: CGFloat = 0) -> some View {
        Text(text)
            .font(.system(size: size, weight: bold ? .bold : .regular))
            .foregroundColor(color)
            .padding(.top, top)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilitySortPriority(priority)
    }

    private func step(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(Theme.textPrimary)
    }

    private func linkRow(_ context: String, _ phrase: String, top: CGFloat = 0) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(context)
                .font(.system(size: 14))
                .foregroundColor(Theme.textPrimary)
            Link(destination: Self.dest) {
                Text(phrase)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.brandPrimary)
                    .underline()
            }
        }
        .padding(.top, top)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func inputBox<Field: View>(_ field: Field) -> some View {
        field
            .font(.system(size: 15))
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(Theme.card)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.cardBorder, lineWidth: 1))
            .cornerRadius(8)
            .padding(.top, 4)
    }
}
