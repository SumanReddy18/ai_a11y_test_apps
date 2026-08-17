import SwiftUI
import UIKit

/// allViolationsSmall build, page 1 of 2 — visual & label violations jam-packed:
///
///  * **Images with text** — one shared unsplash JPEG whose words live in pixels only.
///  * **ImageView label** — the same image element carries NO accessible name.
///  * **Interactive element label** — an icon Button with no name and a coloured tappable
///    shape whose name is empty.
///  * **Missing heading** — two 22pt-bold section titles over 13pt body, no `.isHeader`.
///  * **Incorrect heading** — footnote body text wrongly carrying `.isHeader`.
///
/// No manual navigation: `SmallAppRootView` swaps to page 2 after one full auto-scroll
/// pass and the pair cycles forever — the scan just watches.
struct SmallAppRootView: View {
    @State private var onSecondPage = false

    var body: some View {
        Group {
            if onSecondPage { SmallAppSecondView() } else { SmallAppFirstView() }
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(RulePaging.fullPassSeconds * 1_000_000_000))
                onSecondPage.toggle()
            }
        }
    }
}

struct SmallAppFirstView: View {
    var body: some View {
        RuleScreen {
            // One image, two violations: the page's words exist only in the JPEG pixels,
            // never as text elements (images with text), and the element has no
            // accessible name at all (imageview label).
            artwork("unsplash_text_02.jpg", label: nil)

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
        }
    }

    private func artwork(_ name: String, label: String?) -> some View {
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
