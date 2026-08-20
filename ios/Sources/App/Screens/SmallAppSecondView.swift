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
        VStack(alignment: .leading, spacing: 8) {
            // Link text purpose: each phrase is its own real link element.
            Card {
                linkRow("Click here")
                linkRow("Read more", top: 12)
                linkRow("https://www.browserstack.com/docs/app-accessibility/overview?ref=smallapp",
                        top: 12)
            }

            // Input field labels: a completely bare field — no caption, no placeholder.
            // A visible "Email" caption above it would SATISFY the input-label judge
            // ("persistent visible text holds precedence"). The boxed inputBox styling
            // keeps the crop from being filtered as "Blank".
            Card {
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

            // Incorrect heading (moved from page 1 for the heading budget): body prose
            // and a vague one-worder, both wrongly carrying the header trait.
            Card {
                Text("Delivery partners may call you from a masked number before arriving.")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text("Info")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textPrimary)
                    .padding(.top, 8)
                    .accessibilityAddTraits(.isHeader)
            }

            // Images with text (second chance, mirrors page 1): another flat promo
            // banner, labelled — so only images-with-text fires on this one.
            if let image = UIImage(named: "banner_freedelivery.jpg") {
                Image(uiImage: image)
                    .resizable().scaledToFill()
                    .frame(maxWidth: .infinity, minHeight: 92, maxHeight: 92)
                    .clipped()
                    .cornerRadius(8)
                    .asImageElement(label: "Feature artwork")
            }
        }
    }

    private func linkRow(_ phrase: String, top: CGFloat = 0) -> some View {
        // Bare link, deliberately NO surrounding sentence: the link judge's 80-90 band
        // lets nearby context rescue a stop-word phrase.
        Link(destination: Self.dest) {
            Text(phrase)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(red: 0.043, green: 0.341, blue: 0.816)) // #0B57D0, >=4.5:1
                .underline()
        }
        .padding(.top, top)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func inputBox<Field: View>(_ field: Field) -> some View {
        field
            .font(.system(size: 15))
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(Theme.card)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.cardBorder, lineWidth: 1))
            .cornerRadius(8)
            .padding(.top, 4)
    }
}
