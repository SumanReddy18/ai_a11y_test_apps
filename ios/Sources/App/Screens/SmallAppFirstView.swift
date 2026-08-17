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
///  * **Meaningful reading order** — numbered steps announced 3, 1, 4, 2 with the section
///    title announced last (shuffled ordered list + heading-after-content).
///  * **Meaningful visual order** — checkout steps laid out 3 → 1 → 2.
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

            // Meaningful reading order: an ORDERED LIST announced out of sequence plus a
            // heading announced after its content — the two shapes the MRO judge's prompt
            // names as violations and does NOT whitelist (a "Buy first" card is an
            // explicitly valid pattern to that judge and always came back Not an Issue).
            // Visual: title, Step 1, 2, 3, 4. VoiceOver: Step 3 → 1 → 4 → 2 → title.
            Card {
                orderedLine("How to return an item", size: 17, bold: true,
                            color: Theme.textPrimary, priority: 1)
                orderedLine("1. Open your orders", size: 14, bold: false,
                            color: Theme.textPrimary, priority: 4, top: 8)
                orderedLine("2. Select the item and reason", size: 14, bold: false,
                            color: Theme.textPrimary, priority: 2, top: 6)
                orderedLine("3. Print the return label", size: 14, bold: false,
                            color: Theme.textPrimary, priority: 5, top: 6)
                orderedLine("4. Drop the parcel at any partner store", size: 14, bold: false,
                            color: Theme.textPrimary, priority: 3, top: 6)
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
