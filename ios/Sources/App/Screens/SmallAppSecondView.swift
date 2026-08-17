import SwiftUI
import UIKit

/// allViolationsSmall build, page 2 of 2 — link & input violations (the two order
/// violations live on page 1, which had the spare room):
///
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

            // Images with text (second chance, mirrors page 1): the same text-bearing
            // JPEG, labelled — so only images-with-text fires on this one.
            if let image = UIImage(named: "unsplash_text_02.jpg") {
                Image(uiImage: image)
                    .resizable().scaledToFill()
                    .frame(maxWidth: .infinity, minHeight: 110, maxHeight: 110)
                    .clipped()
                    .cornerRadius(8)
                    .asImageElement(label: "Feature artwork")
            }
        }
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
