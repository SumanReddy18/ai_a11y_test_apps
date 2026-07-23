import SwiftUI

/// Every violation stacked on one scrolling screen — the iOS analogue of
/// AllViolationsActivity. Useful for a single scan pass over all 8 rules.
struct AllViolationsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                ForEach(Rule.allCases) { rule in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(rule.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                            .accessibilityAddTraits(.isHeader)
                        // Embed each rule's screen content inline.
                        rule.screen
                            .frame(minHeight: 200)
                    }
                }
            }
            .padding(.vertical, 12)
        }
        .background(Theme.bg)
        .navigationTitle("All violations")
        .navigationBarTitleDisplayMode(.inline)
    }
}
