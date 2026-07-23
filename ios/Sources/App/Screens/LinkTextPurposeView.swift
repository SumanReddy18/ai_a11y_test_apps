import SwiftUI

/// Rule 8 — Link text purpose.
///
/// Each coloured phrase is a distinct accessibility element carrying the `.isLink` trait, whose
/// accessible name — "click here", "Read more", "here", three identical "Learn more", a raw URL,
/// "tap here", "this", "More" — fails to convey its destination. Mirrors
/// activity_link_text_purpose.xml + LinkTextPurposeActivity.java, where Android wrapped each
/// phrase in a ClickableSpan.
///
/// NOTE (the gotcha): an inline `AttributedString.link` inside a larger `Text` is NOT exposed as a
/// separate link element to iOS accessibility — the whole sentence becomes one text element and the
/// rule never fires. So each link must be its OWN view with `.accessibilityAddTraits(.isLink)`.
struct LinkTextPurposeView: View {
    var body: some View {
        RuleScreen(
            title: Rule.linkTextPurpose.title,
            subtitle: Rule.linkTextPurpose.desc,
            footer: "Every coloured phrase above is a real link (an element with the Link trait), but its label (\"click here\", \"Read more\", \"here\", three identical \"Learn more\", a raw URL, \"tap here\", \"this\", \"More\") fails to describe its destination out of context."
        ) {
            SectionBadge(text: "VIOLATION 1: article footer links")
            Card {
                link("To view our refund policy,", "click here")
                link("New pricing is now live.", "Read more", top: 14)
                link("Full release notes are available", "here", top: 14)
            }

            SectionBadge(text: "VIOLATION 2: repeated 'Learn more' links").padding(.top, 18)
            Card {
                link("Automate tests on real devices.", "Learn more")
                link("Catch accessibility issues early.", "Learn more", top: 14)
                link("Scale your CI pipeline.", "Learn more", top: 14)
            }

            SectionBadge(text: "VIOLATION 3: raw URL as link text").padding(.top, 18)
            Card {
                link("Documentation:",
                     "https://www.browserstack.com/docs/app-accessibility/overview?ref=demo&src=apk")
            }

            SectionBadge(text: "VIOLATION 4: more ambiguous links").padding(.top, 18)
            Card {
                link("To update your billing details,", "tap here")
                link("For onboarding steps, see", "this", top: 14)
                link("Integrations are expanding every week.", "More", top: 14)
            }
        }
    }

    /// A context line (plain text) plus the vague phrase as its OWN accessibility element with the
    /// `.isLink` trait, so the scanner sees a link whose accessible name is exactly `phrase`.
    private func link(_ context: String, _ phrase: String, top: CGFloat = 0) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(context)
                .font(.system(size: 14))
                .foregroundColor(Theme.textPrimary)
            Text(phrase)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Theme.brandPrimary)
                .underline()
                .accessibilityAddTraits(.isLink)   // <- this is what makes it a "link" to the scanner
        }
        .padding(.top, top)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
