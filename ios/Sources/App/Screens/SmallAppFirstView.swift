import SwiftUI
import UIKit

/// allViolationsSmall build, page 1 of 2 — visual & label violations jam-packed:
///
///  * **Images with text** — a flat promo banner ("50% off"), the only image class the
///    judge's classifier does not exempt; words live in pixels only.
///  * **ImageView label** — the same image element carries NO accessible name.
///  * **Interactive element label** — two icon Buttons with no name (flat-colour crops
///    are filtered out as "Blank" before scoring, so both carry icon content).
///  * **Missing heading** — 22pt-bold section titles over two 13pt body lines each, no
///    `.isHeader` (incorrect-heading lives on page 2 for the heading budget).
///  * **Meaningful reading order** — numbered steps announced 3, 1, 4, 2 with the section
///    title announced last (shuffled ordered list + heading-after-content).
///  * **Meaningful visual order** — Sign up card with the CTA ABOVE its input fields
///    (the visual judge's one named violation shape).
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
    @State private var fullName = ""
    @State private var email = ""

    var body: some View {
        RuleScreen {
            // One image, two violations: a flat PROMO banner (the judge's own named
            // Informative example — wordmarks/typographic art/document scans are all
            // exempt buckets), words in pixels only, and no accessible name at all.
            artwork("banner_offer50.jpg", label: nil)

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

                // Second unnamed icon button: a flat shape would be filtered as
                // "Blank" by the crop filter, so it must carry icon content.
                Button(action: {}) {
                    Image(systemName: "trash")
                        .resizable().scaledToFit().padding(14)
                        .frame(width: 64, height: 48)
                        .foregroundColor(.white)
                        .background(Theme.violationRed)
                        .cornerRadius(8)
                }
                .accessibilityElement(children: .ignore)
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
                Text("Contactless drop-off is available from delivery settings.")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.top, 2)
                Text("Payment Method")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                    .padding(.top, 12)
                Text("Visa ending 4242 · Next charge on the 1st of every month.")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.top, 4)
                Text("Update your card any time from the billing page.")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.top, 2)
            }

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

            // Meaningful visual order: the visual judge's one NAMED violation shape —
            // "CTA appearing before necessary input/relevant information". Create
            // account sits ABOVE the fields it submits (placeholders keep the fields
            // named, so no input rule fires here by accident).
            Card {
                Text("Sign up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                Button(action: {}) {
                    Text("Create account")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Theme.brandPrimary)
                        .cornerRadius(8)
                }
                .padding(.top, 8)
                signupField("Full name", text: $fullName)
                signupField("Email address", text: $email)
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

    private func signupField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(.system(size: 15))
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(Theme.card)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.cardBorder, lineWidth: 1))
            .cornerRadius(8)
            .padding(.top, 6)
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
