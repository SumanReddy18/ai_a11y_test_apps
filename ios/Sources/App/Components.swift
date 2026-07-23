import SwiftUI

// MARK: - Screen scaffolding (mirrors styles.xml ScreenRoot / ScreenH1 / ScreenSub)

/// Standard violation-screen wrapper: scrollable, padded, with an H1 title + subtitle
/// and a grey explanatory footer — matching the Android BaseChildActivity screens.
struct RuleScreen<Content: View>: View {
    let title: String
    let subtitle: String
    let footer: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                    .padding(.bottom, 4)
                    // Real screen heading — correctly exposed as a header.
                    .accessibilityAddTraits(.isHeader)

                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.bottom, 14)

                content()

                Text(footer)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.top, 14)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Theme.bg)
    }
}

/// Red "VIOLATION N: …" badge — the Android SectionLabel + badge_red drawable.
struct SectionBadge: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Theme.violationRed)
            .cornerRadius(4)
    }
}

/// White rounded card — the Android card_bg drawable.
struct Card<Content: View>: View {
    var alignment: HorizontalAlignment = .leading
    @ViewBuilder var content: () -> Content
    var body: some View {
        VStack(alignment: alignment, spacing: 0, content: content)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.cardBorder, lineWidth: 1))
            .cornerRadius(12)
    }
}

// MARK: - Image-with-text placeholder

/// A coloured tile that VISIBLY contains text — the analogue of the Android
/// `drawable/unsplash_text_0N` images whose pixels include words. The inner Text is
/// collapsed out of the accessibility tree (`.accessibilityElement(children: .ignore)`),
/// exactly like text baked into a bitmap: sighted users read it, VoiceOver does not.
struct TextTile: View {
    let caption: String
    let bg: Color

    var body: some View {
        ZStack {
            bg
            Text(caption)
                .font(.system(size: 15, weight: .heavy))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(6)
        }
        .frame(height: 96)
        .clipped()
        .cornerRadius(8)
    }
}

// MARK: - Accessibility helpers for image-label violations

extension View {
    /// Treat this view as a single IMAGE element with the given (deliberately bad)
    /// accessible name. Pass `nil` for the "missing label" case — the element still
    /// exists and is focusable, it just has no name.
    func asImageElement(label: String?) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityAddTraits(.isImage)
            .modifier(OptionalLabel(label: label))
    }
}

private struct OptionalLabel: ViewModifier {
    let label: String?
    func body(content: Content) -> some View {
        if let label { content.accessibilityLabel(Text(label)) }
        else { content }
    }
}
