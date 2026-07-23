import SwiftUI

/// Rule 8 — Link text purpose.
///
/// Each coloured phrase is a REAL link (a `.link` attribute inside the string, which
/// VoiceOver exposes as a link element) whose accessible name — "click here", "Read more",
/// "here", three identical "Learn more", a raw URL, "tap here", "this", "More" — fails to
/// convey its destination. Mirrors activity_link_text_purpose.xml + LinkTextPurposeActivity.java,
/// where Android wrapped each phrase in a ClickableSpan.
struct LinkTextPurposeView: View {
    var body: some View {
        RuleScreen(
            title: Rule.linkTextPurpose.title,
            subtitle: Rule.linkTextPurpose.desc,
            footer: "Every coloured phrase above is a real link, but its label (\"click here\", \"Read more\", \"here\", three identical \"Learn more\", a raw URL, \"tap here\", \"this\", \"More\") fails to describe its destination out of context."
        ) {
            SectionBadge(text: "VIOLATION 1: article footer links")
            Card {
                link("To view our refund policy, ", "click here")
                link("New pricing is now live. ", "Read more", top: 14)
                link("Full release notes are available ", "here", top: 14)
            }

            SectionBadge(text: "VIOLATION 2: repeated 'Learn more' links").padding(.top, 18)
            Card {
                link("Automate tests on real devices. ", "Learn more")
                link("Catch accessibility issues early. ", "Learn more", top: 14)
                link("Scale your CI pipeline. ", "Learn more", top: 14)
            }

            SectionBadge(text: "VIOLATION 3: raw URL as link text").padding(.top, 18)
            Card {
                link("Documentation: ",
                     "https://www.browserstack.com/docs/app-accessibility/overview?ref=demo&src=apk",
                     url: "https://www.browserstack.com/docs/app-accessibility/overview")
            }

            SectionBadge(text: "VIOLATION 4: more ambiguous links").padding(.top, 18)
            Card {
                link("To update your billing details, ", "tap here")
                link("For onboarding steps, see ", "this", top: 14)
                link("Integrations are expanding every week. ", "More", top: 14)
            }
        }
    }

    /// Renders `prefix` as plain text followed by `phrase` as a genuine link element
    /// whose accessible name is exactly `phrase`.
    private func link(_ prefix: String, _ phrase: String,
                      url: String = "https://example.com", top: CGFloat = 0) -> some View {
        var attr = AttributedString(prefix)

        var linkPart = AttributedString(phrase)
        linkPart.link = URL(string: url)   // makes this run a real link element
        attr.append(linkPart)

        // The plain prefix uses textPrimary; the link run renders in the app's
        // brand tint automatically, so no per-run colour attributes are needed.
        return Text(attr)
            .font(.system(size: 14))
            .foregroundColor(Theme.textPrimary)
            .padding(.top, top)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
