import SwiftUI

/// Rule 5 — Meaningful visual order.
///
/// The on-screen top-to-bottom arrangement contradicts the logical flow: primary
/// buttons appear before their inputs, steps and line items run in reverse.
/// Purely a layout violation — no accessibility API involved. Mirrors activity_visual_order.xml.
struct VisualOrderView: View {
    @State private var email = ""
    @State private var name = ""
    @State private var card = ""
    @State private var cvv = ""
    @State private var expiry = ""

    var body: some View {
        RuleScreen {
            // Submit before its inputs; step captions out of order.
            Card {
                cardTitle("Sign up")
                primary("Submit")
                label("Email");     field($email, "you@example.com")
                label("Full name"); field($name, "Your name")
                caption("Step 3 of 3"); caption("Step 1 of 3"); caption("Step 2 of 3")
            }

            // Pay before the card fields, and CVV before expiry.
            Card {
                cardTitle("Checkout")
                primary("Pay ₹4,999")
                label("Card number"); field($card, "1234 5678 9012 3456")
                label("CVV");         field($cvv, "123")
                label("Expiry");      field($expiry, "MM/YY")
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
    private func primary(_ t: String) -> some View {
        Button(action: {}) {
            Text(t).foregroundColor(.white).frame(maxWidth: .infinity)
                .padding(.vertical, 10).background(Theme.brandPrimary).cornerRadius(8)
        }
    }
    private func label(_ t: String) -> some View {
        Text(t).foregroundColor(Theme.textPrimary).padding(.top, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    private func field(_ text: Binding<String>, _ placeholder: String) -> some View {
        TextField(placeholder, text: text).textFieldStyle(.roundedBorder)
    }
    private func caption(_ t: String) -> some View {
        Text(t).font(.system(size: 12)).foregroundColor(Theme.textSecondary)
            .padding(.top, 6).frame(maxWidth: .infinity, alignment: .leading)
    }
}
