import SwiftUI

/// Rule 5 — Meaningful visual order.
///
/// The on-screen top-to-bottom arrangement contradicts the logical flow: primary
/// buttons appear before their inputs, steps and line items run in reverse.
/// Purely a layout violation — no accessibility API involved. Mirrors activity_visual_order.xml.
struct VisualOrderView: View {

    var body: some View {
        RuleScreen(paged: false) {
            AiCaption(task: "AI: check_visual_order  ·  meaningful-visual-order",
                      rules: "Every screen also raises reading/visual order + missing/incorrect heading")

            // Submit before its inputs; step captions out of order.
            Card {
                cardTitle("Sign up")
                primary("Submit")
                label("Email");     field("you@example.com")
                label("Full name"); field("Your name")
                caption("Step 3 of 3"); caption("Step 1 of 3"); caption("Step 2 of 3")
            }

            // Pay before the card fields, and CVV before expiry.
            Card {
                cardTitle("Checkout")
                primary("Pay ₹4,999")
                label("Card number"); field("1234 5678 9012 3456")
                label("CVV");         field("123")
                label("Expiry");      field("MM/YY")
            }

            // Finish first, then the numbered steps counting backwards.
            Card {
                cardTitle("Set up your workspace")
                primary("Finish setup")
                caption("4. Invite teammates")
                caption("3. Choose a plan")
                caption("2. Pick an avatar")
                caption("1. Create workspace name")
            }

            // Total before the line items, and the items shuffled.
            Card {
                cardTitle("Order receipt")
                Text("Total: ₹2,400")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Theme.violationRed)
                caption("Item 3 — Phone case (₹400)")
                caption("Item 1 — USB-C cable (₹600)")
                caption("Item 2 — Charger brick (₹1,400)")
            }
        }
    }

    private func cardTitle(_ t: String) -> some View {
        Text(t).font(.system(size: 18, weight: .bold))
            .foregroundColor(Theme.textPrimary).padding(.bottom, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    /// Rendered as styled Text, not a Button, on purpose. A real Button is a candidate for
    /// interactable-element-content-label, which would make this screen report
    /// check_accessibility_label issues on top of its own AI task. It keeps its text and its
    /// place in the traversal order, which is what this screen actually tests.
    private func primary(_ t: String) -> some View {
        Text(t).foregroundColor(.white).frame(maxWidth: .infinity)
            .padding(.vertical, 10).background(Theme.brandPrimary).cornerRadius(8)
    }
    private func label(_ t: String) -> some View {
        Text(t).foregroundColor(Theme.textPrimary).padding(.top, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    /// Styled Text rather than a TextField: an editable feeds both
    /// editable-element-content-label and the input-field rules, so a real field here would
    /// add check_accessibility_label and check_input_field_purpose to this screen's report.
    private func field(_ placeholder: String) -> some View {
        Text(placeholder)
            .foregroundColor(Theme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Theme.card)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.cardBorder, lineWidth: 1))
    }
    private func caption(_ t: String) -> some View {
        Text(t).font(.system(size: 12)).foregroundColor(Theme.textSecondary)
            .padding(.top, 6).frame(maxWidth: .infinity, alignment: .leading)
    }
}
