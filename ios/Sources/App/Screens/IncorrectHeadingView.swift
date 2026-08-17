import SwiftUI

/// Rule 7 — Incorrect heading.
///
/// Body copy, an inline error, every list row, an ad blurb, and even a button are all
/// marked WITH the `.isHeader` trait — so the VoiceOver heading rotor lands on noise
/// instead of real sections. Mirrors activity_incorrect_heading.xml.
struct IncorrectHeadingView: View {

    var body: some View {
        RuleScreen {
            AiCaption(task: "AI: check_incorrect_heading  ·  incorrect-heading",
                      rules: "missing-heading always fires too — same eligibility, shared ai:mis-head hash")

            // Body paragraph as heading.
            Card {
                heading("Terms of service", size: 18)
                // Long body copy wrongly marked as a heading.
                heading("By continuing you agree that any data captured by this demo app may be used to train internal QA models, that you understand this is a synthetic accessibility test fixture, and that you will not redistribute the bundled builds outside your organization.",
                        size: 14, top: 8)
            }

            // Inline error labelled as heading.
            Card {
                Text("Email").foregroundColor(Theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                // Styled Text rather than a TextField — a real editable would add
                // check_accessibility_label and check_input_field_purpose to this screen.
                Text("you@example.com")
                    .foregroundColor(Theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Theme.card)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.cardBorder, lineWidth: 1))
                // Transient error state wrongly marked as a heading.
                Text("Email is required.")
                    .font(.system(size: 12)).foregroundColor(Theme.violationRed)
                    .padding(.top, 4).frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
            }

            // Every list row is a heading.
            Card {
                heading("Inbox", size: 18)
                heading("Anya — your invoice is ready", size: 14, top: 10)
                heading("GitHub — 3 new pull requests on app-apk", size: 14, top: 6)
                heading("Mum — call me when you land", size: 14, top: 6)
                heading("Zomato — 30% off this weekend", size: 14, top: 6)
            }

            // Ad / promo flagged as heading.
            Card {
                heading("Articles", size: 18)
                heading("Sponsored — Try Cloud Plus free for 30 days. No credit card needed.",
                        size: 13, top: 10, color: Theme.textSecondary)
                heading("Why mobile accessibility matters in 2026", size: 15, top: 14)
                Text("5 min read · BrowserStack engineering")
                    .font(.system(size: 12)).foregroundColor(Theme.textSecondary)
                    .padding(.top, 2).frame(maxWidth: .infinity, alignment: .leading)
            }

            // Button label as heading.
            Card {
                heading("Confirm booking", size: 18)
                Text("Mumbai → Goa · Sat 9:40 AM · 2 passengers")
                    .font(.system(size: 14)).foregroundColor(Theme.textPrimary)
                    .padding(.top, 8).frame(maxWidth: .infinity, alignment: .leading)
                // A call-to-action wrongly carrying the header trait. Styled Text rather
                // than a Button: a real Button would add check_accessibility_label here.
                Text("Pay ₹12,450").foregroundColor(.white).frame(maxWidth: .infinity)
                    .padding(.vertical, 10).background(Theme.brandPrimary).cornerRadius(8)
                    .padding(.top, 14)
                    .accessibilityAddTraits(.isHeader)
            }
        }
    }

    private func heading(_ t: String, size: CGFloat, top: CGFloat = 0,
                         color: Color = Theme.textPrimary) -> some View {
        Text(t)
            .font(.system(size: size, weight: .bold))
            .foregroundColor(color)
            .padding(.top, top)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader) // wrongly applied — this is the violation
    }
}
