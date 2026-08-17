import SwiftUI

/// Rule 4 — Meaningful reading order.
///
/// VoiceOver focus order is scrambled away from the visual/logical order using
/// `.accessibilitySortPriority` (higher = visited earlier). Mirrors activity_reading_order.xml,
/// where Android used android:accessibilityTraversalAfter.
///
/// `paged: false`, and the copy is kept short so all twelve elements fit one viewport. This rule
/// is evaluated against a single snapshot — it intersects the focus caption with elements that
/// have non-zero bounds, and bails outright if the surviving uid list contains a duplicate. A
/// screen that scrolls underneath the capture drops elements from that intersection, which is
/// why the rule did not fire on every run.
struct ReadingOrderView: View {
    var body: some View {
        RuleScreen(paged: false) {
            AiCaption(task: "AI: check_reading_order  ·  meaningful-reading-order",
                      rules: "Every screen also raises reading/visual order + missing/incorrect heading")

            // Visual: Title → Price → Description → Buy. VoiceOver: Buy → Title → Description → Price.
            Card {
                orderedLine("Wireless Headphones X9", size: 18, bold: true,
                            color: Theme.textPrimary, priority: 3)
                orderedLine("₹4,999  (was ₹7,999)", size: 15, bold: true,
                            color: Theme.violationRed, priority: 1, top: 6)
                orderedLine("Active noise cancelling, 32-hour battery.",
                            size: 14, bold: false, color: Theme.textSecondary, priority: 2, top: 10)
                cta("Buy now", priority: 4)
            }
            // Explicit container so VoiceOver orders the contained elements strictly by
            // sortPriority — making the traversal-vs-visual mismatch a detectable violation.
            .accessibilityElement(children: .contain)

            // Visual: Headline → Byline → Body → Read more. VoiceOver: Read more → Headline → Body → Byline.
            Card {
                orderedLine("Mars rover finds new mineral deposit", size: 18, bold: true,
                            color: Theme.textPrimary, priority: 3)
                orderedLine("By Sneha K. — 2h ago", size: 13, bold: false,
                            color: Theme.textSecondary, priority: 1, top: 6)
                orderedLine("Perseverance data suggests subsurface water flow.",
                            size: 14, bold: false, color: Theme.textPrimary, priority: 2, top: 10)
                cta("Read more", priority: 4)
            }
            .accessibilityElement(children: .contain)
            .padding(.top, 10)

            // Visual: Invoice # → Customer → Total → Pay now. VoiceOver: Pay now → Invoice # → Total → Customer.
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
            .padding(.top, 10)
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

    /// Rendered as styled Text, not a Button, on purpose. A real Button is a candidate for
    /// interactable-element-content-label, which would make this screen report
    /// check_accessibility_label issues on top of its own AI task. It keeps its text and its
    /// place in the traversal order, which is what this screen actually tests.
    private func cta(_ label: String, priority: Double) -> some View {
        Text(label).foregroundColor(.white).frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Theme.brandPrimary).cornerRadius(8)
            .padding(.top, 14)
            .accessibilitySortPriority(priority)
    }
}
