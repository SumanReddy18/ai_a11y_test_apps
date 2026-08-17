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
    private static let initialDelay: Double = 5    // settle before the first hop (matches Android)
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
        }
        .background(Theme.bg)
        .navigationTitle("All violations")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Next") { advance() }
            }
        }
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
