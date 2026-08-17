import SwiftUI

// MARK: - Screen scaffolding

/// Standard violation-screen wrapper: a scrollable, padded surface and nothing else.
///
/// Deliberately bare. It used to add a screen title, subtitle, "VIOLATION N" badges and an
/// explanatory footer; every one of those is a real element in the accessibility tree, so each
/// scanned screen was mostly text that isn't a violation — and the title carried `.isHeader`,
/// which handed the missing-heading build a perfectly correct heading. The reference fixture
/// (browserstack/app-accessibility-ios-app @ app-for-issue-details) ships violating elements
/// and nothing else, and gets every violation reported off one screen.
///
/// Explanations belong in each screen's doc comment, where the scanner can't see them.
/// Auto-paging timings, shared with `AllViolationsView` so its per-rule dwell can't drift
/// below the time one screen needs to show all of itself. Mirrors BaseChildActivity on Android.
enum RulePaging {
    static let initialDelay: Double = 5      // settle before the first hop
    static let dwell: Double = 9             // seconds a screen is held before the next one

    /// Retained for `SmallAppRootView`, which uses it as the interval for swapping its two
    /// halves. It used to mean "how long one screen needs to page through itself once"
    /// (initialDelay + pages * dwell = 41s); with per-screen paging gone there is no self-pass
    /// to wait for, so this is just a dwell long enough for the scan to capture one half —
    /// matching the 14s per-section dwell AllViolationsActivity uses on Android.
    static var fullPassSeconds: Double { initialDelay + dwell }
}

/// A rule screen. Deliberately does NOT scroll itself.
///
/// This used to page down through its own height on a loop (4 pages x 9s), because screens were
/// 2-3 viewports tall and the scan captures the viewport without scrolling. That made
/// `AllViolationsView` crawl: it had to hold every rule for a full self-pass (41s), so one cycle
/// through nine rules took over six minutes.
///
/// The fix is the reference fixture's approach, described above: ship violating elements and
/// nothing else, so each screen fits one viewport and no internal scrolling is needed. Keep new
/// screens short enough to fit — if a screen needs scrolling to show all its violations, split it
/// or cut it down rather than reintroducing an auto-scroll here.
///
/// The `ScrollView` stays so nothing is clipped or unreachable by hand if a screen does overflow.
struct RuleScreen<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        ScrollView {
            // Spacing here (rather than a padding on every card) is what the deleted
            // "VIOLATION N" badges used to provide between sections.
            VStack(alignment: .leading, spacing: 14, content: content)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Theme.bg)
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
