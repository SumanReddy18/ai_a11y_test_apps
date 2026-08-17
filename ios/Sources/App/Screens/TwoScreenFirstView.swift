import SwiftUI
import UIKit

/// twoScreens build, page 1 of 2 — visual & label violations jam-packed:
///
///  * **Images with text** — two of the shared unsplash JPEGs (same pixels Android detects on),
///    with decent human labels; the violation is the text living in pixels only.
///  * **ImageView label** — a meaningful image exposed as an image element with NO name.
///  * **Interactive element label** — an icon Button with no name and a coloured tappable
///    shape whose name is empty.
///  * **Missing heading** — two 22pt-bold section titles over 13pt body, no `.isHeader`.
///  * **Incorrect heading** — footnote body text wrongly carrying `.isHeader`.
///
/// The "Continue to page 2" link at the bottom is deliberately clean (proper label) so the
/// only issues a scan finds here are the planted ones.
struct TwoScreenFirstView: View {
    var body: some View {
        RuleScreen {
            // Images with text: words exist only in the JPEG pixels, never as text elements.
            HStack(spacing: 8) {
                artwork("unsplash_text_01.jpg", label: "Summer sale banner")
                artwork("unsplash_text_02.jpg", label: "Quarterly results chart")
            }

            // ImageView label: a real image element, focusable, with no accessible name.
            Image(systemName: "person.crop.circle.fill")
                .resizable().scaledToFit()
                .frame(width: 84, height: 84)
                .foregroundColor(Theme.textSecondary)
                .asImageElement(label: nil)

            // Interactive element label: unnamed icon button + empty-named tappable shape.
            HStack(spacing: 14) {
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .resizable().scaledToFit().padding(16)
                        .frame(width: 64, height: 64)
                        .foregroundColor(Theme.textPrimary)
                        .background(Theme.card)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.cardBorder, lineWidth: 1))
                        .cornerRadius(8)
                }
                .accessibilityElement(children: .ignore) // strips the SF symbol's implicit name

                Theme.brandPrimary
                    .frame(width: 120, height: 48)
                    .cornerRadius(8)
                    .onTapGesture {}
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel("")
            }

            // Missing heading: heading-styled text over body copy, no .isHeader anywhere.
            Card {
                Text("Order Summary")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                Text("3 items · Arriving Friday before 9 pm. Signature required on delivery.")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.top, 4)
                Text("Payment Method")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                    .padding(.top, 12)
                Text("Visa ending 4242 · Next charge on the 1st of every month.")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.top, 4)
            }

            // Incorrect heading: 13pt body text claiming the header trait.
            Text("Prices include all applicable taxes.")
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)
                .accessibilityAddTraits(.isHeader)

            // Clean, properly-labelled navigation to the second screen.
            NavigationLink {
                TwoScreenSecondView()
            } label: {
                Text("Continue to page 2")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Theme.brandDark)
                    .cornerRadius(8)
            }
        }
    }

    private func artwork(_ name: String, label: String) -> some View {
        guard let image = UIImage(named: name) else {
            fatalError("\(name) is not in the app bundle — check the resources entry in ios/project.yml")
        }
        return Image(uiImage: image)
            .resizable().scaledToFill()
            .frame(maxWidth: .infinity, minHeight: 110, maxHeight: 110)
            .clipped()
            .cornerRadius(8)
            .asImageElement(label: label)
    }
}
