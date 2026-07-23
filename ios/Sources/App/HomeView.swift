import SwiftUI

/// Home / quick-jump nav — the iOS analogue of MainActivity in the `full` flavor.
struct HomeView: View {
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
                    .padding(.bottom, 4)

                NavigationLink {
                    AllViolationsView()
                } label: {
                    HStack {
                        Text("All violations on one screen")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(.white)
                    }
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
