import SwiftUI

/// Rule 4 — Meaningful reading order.
///
/// VoiceOver focus order is scrambled away from the visual/logical order using
/// `.accessibilitySortPriority` (higher = visited earlier). Mirrors activity_reading_order.xml,
/// where Android used android:accessibilityTraversalAfter.
struct ReadingOrderView: View {
    var body: some View {
        RuleScreen(
            title: Rule.readingOrder.title,
            subtitle: Rule.readingOrder.desc,
            footer: "Three cards, three scrambled focus orders. A VoiceOver user is asked to buy / read / pay before knowing what, or for how much."
        ) {
            SectionBadge(text: "VIOLATION 1: product card")
            note("Visual: Title → Price → Description → Buy. VoiceOver: Buy → Title → Description → Price.")
            Card {
                orderedLine("Wireless Headphones X9", size: 18, bold: true,
                            color: Theme.textPrimary, priority: 3)
                orderedLine("₹4,999  (was ₹7,999)", size: 15, bold: true,
                            color: Theme.violationRed, priority: 1, top: 6)
                orderedLine("Active noise cancelling with 32-hour battery life and adaptive EQ tuned for podcasts and music.",
                            size: 14, bold: false, color: Theme.textSecondary, priority: 2, top: 10)
                cta("Buy now", priority: 4)
            }
            // Explicit container so VoiceOver orders the contained elements strictly by
            // sortPriority — making the traversal-vs-visual mismatch a detectable violation.
            .accessibilityElement(children: .contain)

            SectionBadge(text: "VIOLATION 2: news article card").padding(.top, 22)
            note("Visual: Headline → Byline → Body → Read more. VoiceOver: Read more → Headline → Body → Byline.")
            Card {
                orderedLine("Mars rover finds new mineral deposit", size: 18, bold: true,
                            color: Theme.textPrimary, priority: 3)
                orderedLine("By Sneha K. — 2h ago", size: 13, bold: false,
                            color: Theme.textSecondary, priority: 1, top: 6)
                orderedLine("The discovery, made by the Perseverance rover, suggests subsurface water flow continued long after the planet cooled.",
                            size: 14, bold: false, color: Theme.textPrimary, priority: 2, top: 10)
                cta("Read more", priority: 4)
            }
            .accessibilityElement(children: .contain)

            SectionBadge(text: "VIOLATION 3: invoice summary").padding(.top, 22)
            note("Visual: Invoice # → Customer → Total → Pay now. VoiceOver: Pay now → Invoice # → Total → Customer.")
            Card {
                orderedLine("Invoice #INV-2042", size: 18, bold: true,
                            color: Theme.textPrimary, priority: 3)
                orderedLine("Customer: Acme Industries Pvt Ltd", size: 13, bold: false,
                            color: Theme.textSecondary, priority: 1, top: 6)
                orderedLine("Total due: ₹38,400 (incl. GST)", size: 15, bold: true,
                            color: Theme.violationRed, priority: 2, top: 10)
                cta("Pay now", priority: 4)
            }
            .accessibilityElement(children: .contain)
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

    private func cta(_ label: String, priority: Double) -> some View {
        Button(action: {}) {
            Text(label).foregroundColor(.white).frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Theme.brandPrimary).cornerRadius(8)
        }
        .padding(.top, 14)
        .accessibilitySortPriority(priority)
    }

    private func note(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundColor(Theme.textSecondary)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
