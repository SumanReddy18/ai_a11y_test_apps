import SwiftUI

/// Every violation stacked on one scrolling screen — the iOS analogue of
/// AllViolationsActivity.
///
/// Auto-scroll: the screen walks itself through every section on a loop, so a continuous
/// accessibility scan captures all of them hands-free. It loops (rather than scrolling once)
/// because the scan starts well after launch — a single pass would race ahead and miss
/// sections; any full cycle covers every section. A manual "Next ↓" button also works.
struct AllViolationsView: View {
    private static let initialDelay: Double = 5    // settle before the first hop (matches Android)
    private static let dwell: Double = 14          // seconds held per section for the scan

    @State private var index = 0

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    ForEach(Array(Rule.allCases.enumerated()), id: \.offset) { i, rule in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(rule.title)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Theme.textPrimary)
                                .accessibilityAddTraits(.isHeader)
                            rule.screen
                                .frame(minHeight: 200)
                        }
                        .id(i)   // scroll anchor for this section
                    }
                }
                .padding(.vertical, 12)
            }
            // Manual "Next ↓" — jumps to the next section below the current one.
            .safeAreaInset(edge: .bottom) {
                Button {
                    advance(proxy, animated: true)
                } label: {
                    Text("Next violation ↓")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.brandPrimary)
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                }
            }
            // Hands-free auto-scroll loop; cancelled automatically when the view goes away.
            .task {
                try? await Task.sleep(nanoseconds: UInt64(Self.initialDelay * 1_000_000_000))
                while !Task.isCancelled {
                    withAnimation(.easeInOut) { proxy.scrollTo(index, anchor: .top) }
                    index = (index + 1) % Rule.allCases.count
                    try? await Task.sleep(nanoseconds: UInt64(Self.dwell * 1_000_000_000))
                }
            }
        }
        .background(Theme.bg)
        .navigationTitle("All violations")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func advance(_ proxy: ScrollViewProxy, animated: Bool) {
        index = (index + 1) % Rule.allCases.count
        if animated { withAnimation(.easeInOut) { proxy.scrollTo(index, anchor: .top) } }
        else { proxy.scrollTo(index, anchor: .top) }
    }
}
