import SwiftUI

/// BrowserStack App Accessibility iOS demo fixture.
///
/// Deliberately violates the same 8 accessibility rules as the Android app in this repo,
/// so the BrowserStack Issue Detection Agent can be validated on iOS. Which screen launches
/// is decided by `A11yRuleSelection` (env var for local runs, Info.plist for built .ipa) —
/// the iOS equivalent of the Android Gradle flavors.
@main
struct A11yDemoApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .tint(Theme.brandPrimary) // links & controls render in the brand orange
        }
    }
}

struct RootView: View {
    var body: some View {
        switch A11yRuleSelection.current {
        case .full:
            NavigationStack { HomeView() }
        case .all:
            NavigationStack { AllViolationsView() }
        case .single(let rule):
            // Single-issue build: launch straight into that one violation screen, no home.
            NavigationStack { rule.screen.navigationTitle(rule.title) }
        }
    }
}
