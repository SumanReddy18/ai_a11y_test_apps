import SwiftUI

/// Rule 6 — Missing heading.
///
/// Section titles that functionally introduce a new section but are rendered as plain
/// body text WITHOUT the `.isHeader` trait — so the VoiceOver heading rotor skips them.
/// Mirrors activity_missing_heading.xml (Android: no android:accessibilityHeading="true").
struct MissingHeadingView: View {
    var body: some View {
        RuleScreen {
            // Settings page sections.
            Card {
                sectionTitle("Account")
                body("Manage email, password, and linked devices.")
                sectionTitle("Notifications", top: 14)
                body("Choose what you get pushed and emailed.")
                sectionTitle("Privacy", top: 14)
                body("Control who can see your activity and profile.")
            }

            // Blog article sections.
            Card {
                sectionTitle("Why mobile accessibility matters")
                body("More than 1 in 7 users rely on assistive tech on mobile. Apps that ignore them lock out paying customers and risk legal exposure.", top: 10)
                sectionTitle("The business case", top: 16)
                body("Inclusive apps consistently see higher retention and stronger app-store reviews.", top: 4)
                sectionTitle("The legal case", top: 16)
                body("Inaccessible apps have triggered ADA and EU EAA complaints in every major market.", top: 4)
            }

            // Order summary sections.
            Card {
                sectionTitle("Items")
                body("Noise cancelling headphones · ₹4,999")
                sectionTitle("Shipping", top: 14)
                body("221B Baker Street, Mumbai · arrives Fri")
                sectionTitle("Payment", top: 14)
                body("Visa ending 4242 · UPI fallback enabled")
            }

            // Dashboard card titles.
            Card {
                sectionTitle("Active users today");  body("38,402")
                sectionTitle("Crash-free sessions", top: 14); body("99.78%")
                sectionTitle("Revenue this week", top: 14);    body("₹12.4 L")
            }
        }
    }

    /// Looks like a heading (weight/size) but is deliberately NOT exposed as one.
    private func sectionTitle(_ t: String, top: CGFloat = 0) -> some View {
        Text(t)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Theme.textPrimary)
            .padding(.top, top)
            .frame(maxWidth: .infinity, alignment: .leading)
            // NOTE: no .accessibilityAddTraits(.isHeader) — that omission is the violation.
    }
    private func body(_ t: String, top: CGFloat = 2) -> some View {
        Text(t)
            .font(.system(size: 13))
            .foregroundColor(Theme.textSecondary)
            .padding(.top, top)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
