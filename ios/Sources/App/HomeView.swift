import SwiftUI

/// Home / quick-jump nav — the iOS analogue of MainActivity in the `full` flavor.
/// Includes the numbered quick-jump grid (1–8) that mirrors the Android NumBtn row.
struct HomeView: View {
    private let numberCols = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("BrowserStack Issue Detection Agent")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text("8 AI-enhanced accessibility rules — each violated on its own screen.")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)

                // ---- Quick jump: numbered circles 1–8 (mirrors Android NumBtn rows) ----
                Text("QUICK JUMP")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.top, 4)

                LazyVGrid(columns: numberCols, spacing: 10) {
                    ForEach(Array(Rule.allCases.enumerated()), id: \.offset) { i, rule in
                        NavigationLink {
                            rule.screen.navigationTitle(rule.title)
                        } label: {
                            Text("\(i + 1)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 52, height: 52)
                                .background(Circle().fill(Theme.brandPrimary))
                        }
                        .accessibilityLabel("Open rule \(i + 1): \(rule.title)")
                    }
                }
                .padding(.bottom, 4)

                NavigationLink {
                    AllViolationsView()
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("See all 8 violations on one page →")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text("One scan, all rules fire.")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Theme.brandPrimary)
                    .cornerRadius(12)
                }

                ForEach(Rule.allCases) { rule in
                    NavigationLink {
                        rule.screen.navigationTitle(rule.title)
                    } label: {
                        Card {
                            Text(rule.title)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(Theme.textPrimary)
                            Text(rule.desc)
                                .font(.system(size: 13))
                                .foregroundColor(Theme.textSecondary)
                                .padding(.top, 4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .background(Theme.bg)
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
    }
}
