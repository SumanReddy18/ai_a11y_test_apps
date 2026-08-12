import SwiftUI

/// Rule 8 — Link text purpose.
///
/// Every coloured phrase is a real link element whose accessible name — "click here", "Read more",
/// "here", three identical "Learn more", a raw URL, a filename, "#", an arrow — fails to convey its
/// destination. Mirrors activity_link_text_purpose.xml + LinkTextPurposeActivity.java, where
/// Android wraps each phrase in a ClickableSpan.
///
/// NOTE (the gotcha, twice over):
///  1. An inline `AttributedString.link` inside a larger `Text` is NOT exposed as a separate link
///     element — the whole sentence becomes one text element and the rule never fires. Each link
///     must be its own view.
///  2. `Text(phrase).accessibilityAddTraits(.isLink)` is not enough either: that is static text
///     merely *claiming* the trait, with no activation behind it, so a scanner looking for real
///     link elements skips it. This screen uses SwiftUI's native `Link` — a genuine link element
///     with a destination — and, in the last section, `Button`/`Image` carrying `.isLink`, so the
///     fixture offers several element shapes rather than betting on one.
///
/// The destination uses an unregistered custom scheme: the links are real to accessibility, but a
/// crawler that taps one cannot navigate away from the app under scan.
struct LinkTextPurposeView: View {
    private static let dest = URL(string: "a11ydemo://destination")!

    var body: some View {
        RuleScreen {
            // Vague action phrases.
            Card {
                link("To view our refund policy,", "click here")
                link("New pricing is now live.", "Read more", top: 14)
                link("Full release notes are available", "here", top: 14)
                link("To update your billing details,", "tap here", top: 14)
            }

            // Identical text, different destinations.
            Card {
                link("Automate tests on real devices.", "Learn more")
                link("Catch accessibility issues early.", "Learn more", top: 14)
                link("Scale your CI pipeline.", "Learn more", top: 14)
            }

            // Machine text as the link label.
            Card {
                link("Documentation:",
                     "https://www.browserstack.com/docs/app-accessibility/overview?ref=demo&src=apk")
                link("Signed agreement:", "policy_v2_final.pdf", top: 14)
                link("Skip to the pricing table:", "#", top: 14)
            }

            // Links with no useful text at all.
            Card {
                // Same violation via other element shapes: a Button and an Image wearing .isLink.
                buttonLink("Continue to the next chapter", "→")
                buttonLink("Manage your subscription", "Click", top: 14)
                imageLink("Open the help centre", top: 14)
            }
        }
    }

    // MARK: - Link shapes

    /// A context line plus a native `Link` — a genuine link element whose accessible name is
    /// exactly `phrase`.
    private func link(_ context: String, _ phrase: String, top: CGFloat = 0) -> some View {
        row(context, top: top) {
            Link(destination: Self.dest) {
                Text(phrase)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.brandPrimary)
                    .underline()
            }
        }
    }

    /// A tappable control carrying the link trait — the shape a scanner filtering on interactive
    /// elements will pick up.
    private func buttonLink(_ context: String, _ phrase: String, top: CGFloat = 0) -> some View {
        row(context, top: top) {
            Button(action: {}) {
                Text(phrase)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.brandPrimary)
                    .underline()
            }
            .accessibilityAddTraits(.isLink)
        }
    }

    /// A link whose only label is the word "link" on an icon — no destination information at all.
    private func imageLink(_ context: String, top: CGFloat = 0) -> some View {
        row(context, top: top) {
            Image(systemName: "arrow.up.forward.square.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 26, height: 26)
                .foregroundColor(Theme.brandPrimary)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("link")
                .accessibilityAddTraits(.isLink)
        }
    }

    private func row<Content: View>(_ context: String, top: CGFloat,
                                    @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(context)
                .font(.system(size: 14))
                .foregroundColor(Theme.textPrimary)
            content()
        }
        .padding(.top, top)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
