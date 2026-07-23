import SwiftUI

/// Every violation, one full screen at a time — the iOS analogue of AllViolationsActivity.
///
/// Uses a paged `TabView`: each page is ONE rule's complete screen. Auto-scroll advances to the
/// next page on a loop so a continuous accessibility scan captures each violation in full, one at
/// a time (rather than a scrambled merge of half-screens). A manual "Next" button also advances.
/// It loops because the scan starts well after launch — any full cycle covers every rule.
struct AllViolationsView: View {
    private static let initialDelay: Double = 5    // settle before the first hop (matches Android)
    private static let dwell: Double = 14          // seconds held per screen for the scan

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

            TabView(selection: $index) {
                ForEach(Array(rules.enumerated()), id: \.offset) { i, rule in
                    rule.screen
                        .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
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

    private func advance() {
        withAnimation(.easeInOut) { index = (index + 1) % rules.count }
    }
}
