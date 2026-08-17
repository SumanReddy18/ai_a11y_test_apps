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
    static let dwell: Double = 9             // seconds held per viewport
    static let pages = 4                     // covers the tallest screen here (~3 viewports)

    /// How long one screen needs to page through itself once.
    static var fullPassSeconds: Double { initialDelay + Double(pages) * dwell }

    static func markerID(_ i: Int) -> String { "rulePage\(i)" }
}

struct RuleScreen<Content: View>: View {
    /// Set `false` for screens whose rule reads POSITION or FOCUS ORDER.
    ///
    /// Paging is a net win on most screens (it drags below-the-fold violations into a captured
    /// viewport), but meaningful-reading-order and meaningful-visual-order are whole-tree rules
    /// evaluated against one snapshot: reading order intersects the focus caption with elements
    /// that have non-zero bounds, and visual order sorts by y/x. If the screen moves between the
    /// caption capture and the tree capture, elements scroll out of bounds and drop from the
    /// sequence — and reading order bails outright when the surviving uid list contains a
    /// duplicate. A still screen that fits one viewport is what makes those two fire every run.
    var paged: Bool = true
    @ViewBuilder var content: () -> Content
    @State private var page = 0

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                // Spacing here (rather than a padding on every card) is what the deleted
                // "VIOLATION N" badges used to provide between sections.
                VStack(alignment: .leading, spacing: 14, content: content)
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    // Invisible page markers to scroll to. A Color is not an accessibility
                    // element, so paging costs the tree nothing.
                    .overlay(alignment: .top) { markers }
            }
            // Most rule screens are 2–3 viewports tall and the scan captures the viewport
            // without scrolling, so violations below the fold were never looked at — which is
            // why "Input type for input fields" (bottom of the input screen) was rarely
            // reported while the label violations at the top always were. Page down on a loop;
            // it loops because the scan starts well after launch.
            .task {
                guard paged else { return }
                try? await Task.sleep(nanoseconds: UInt64(RulePaging.initialDelay * 1_000_000_000))
                while !Task.isCancelled {
                    page = (page + 1) % RulePaging.pages
                    withAnimation { proxy.scrollTo(RulePaging.markerID(page), anchor: .top) }
                    try? await Task.sleep(nanoseconds: UInt64(RulePaging.dwell * 1_000_000_000))
                }
            }
        }
        .background(Theme.bg)
    }

    /// Markers spread evenly down the content (the overlay is content-height, so the spacers
    /// distribute them). `Color` is not an accessibility element, so paging costs the tree nothing.
    private var markers: some View {
        VStack(spacing: 0) {
            ForEach(0..<RulePaging.pages, id: \.self) { i in
                Color.clear
                    .frame(height: 1)
                    .id(RulePaging.markerID(i))
                if i < RulePaging.pages - 1 { Spacer(minLength: 0) }
            }
        }
        .allowsHitTesting(false)
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

/// Names the AI task a screen is for, the on-device rules that feed it, and any other task
/// that is expected to appear anyway — so the expected result can be read off a screenshot
/// instead of the source.
///
/// NOT hidden from VoiceOver. missing-heading has no isAccessible guard — it fires on any
/// visible static-text leaf carrying text — so `.accessibilityHidden(true)` did not keep these
/// out of its candidate set. It only made them hidden text that the AI then judged "should be a
/// heading", producing a junk missing-heading violation at the top of every screen. The title
/// line is a real heading instead, which is what it visually is; the detail line stays plain
/// body text, small and clearly subordinate, so it should pass on its own merits.
struct AiCaption: View {
    let task: String
    let rules: String
    var also: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(task)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(Theme.brandPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(rules)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(Theme.textSecondary)
            if let also {
                Text(also)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
