import SwiftUI

/// Every violation, one full screen at a time — the iOS analogue of AllViolationsActivity.
///
/// Renders ONLY the current rule's screen. Auto-scroll advances to the next one on a loop so a
/// continuous accessibility scan captures each violation in full, one at a time (rather than a
/// scrambled merge of half-screens). A manual "Next" button also advances. It loops because the
/// scan starts well after launch — any full cycle covers every rule.
///
/// Deliberately NOT a paged `TabView`: that builds all 9 screens up front (~27 UIKit-backed
/// TextFields/Toggles + 10 images), which is what made this screen slow to open and janky to
/// advance. Trade-off: no swipe gesture and no page dots — use "Next", or wait for the timer.
struct AllViolationsView: View {
    // 7s, not 5: the app must sit still while it loads so the first capture is a settled screen
    // rather than one mid-scroll. Matches AllViolationsActivity.
    private static let initialDelay: Double = 7    // settle before the first hop
    // One dwell per rule, not per viewport. RuleScreen no longer scrolls itself, so there is
    // nothing to wait for beyond the scan capturing this screen once. It used to be
    // RulePaging.fullPassSeconds (41s), which made a full cycle of nine rules take over six
    // minutes; at 9s a cycle is ~86s.
    private static let dwell: Double = RulePaging.dwell

    @State private var index = 0
    private let rules = Array(Rule.allCases)

    var body: some View {
        VStack(spacing: 0) {
            // Which violation is on screen right now.
            Text("Violation \(index + 1) of \(rules.count)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Theme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Theme.bg)
                .accessibilityHidden(true)

            // .id() gives each rule a fresh identity, so its @State starts clean on every pass.
            rules[index].screen
                .id(index)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Manual advance lives in its own bar BELOW the content, mirroring the Android
            // port's bottom bar. It was a navigationBarTrailing toolbar item, but that put a
            // labelled harness control into the accessibility tree at the top-right of every
            // rule screen, and scans judged that chrome against the fixture content's order
            // (spurious visual-order findings on screens that plant no order violation).
            // Hidden from the tree like the caption above: harness chrome, not fixture content.
            HStack {
                Spacer()
                Button("Next section") { advance() }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(Theme.brandPrimary)
                    .cornerRadius(8)
            }
            .padding(10)
            .background(Theme.bg)
            .accessibilityHidden(true)
        }
        .background(Theme.bg)
        .navigationTitle("All violations")
        .navigationBarTitleDisplayMode(.inline)
        // Hands-free auto-advance loop; cancelled automatically when the view goes away.
        .task {
            try? await Task.sleep(nanoseconds: UInt64(Self.initialDelay * 1_000_000_000))
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(Self.dwell * 1_000_000_000))
                advance()
            }
        }
    }

    // Hard cut, no cross-fade: a scan firing mid-transition would capture a blend of two screens.
    private func advance() {
        index = (index + 1) % rules.count
    }
}
