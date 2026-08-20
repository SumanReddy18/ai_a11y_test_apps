import SwiftUI
import UIKit

/// All-rules fixture: two jam-packed pages that together violate every active
/// cross-platform rule in the App Accessibility rule engine (the rest are
/// Android-only or iOS engine dead-ends — see allrules/README.md). Pages
/// auto-advance on a loop and each page fits one viewport, so no violating
/// element is ever below the fold — the scan captures the visible viewport only
/// and the rule processor skips anything even partially off-screen.
@main
struct A11yAllRulesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView()
                // Deterministic colors for the contrast fixtures.
                .preferredColorScheme(.light)
        }
    }
}

/// Per-screen orientation control.
///
/// Pages 1–2 keep landscape support: the responsive-containers rule is killed for the
/// whole snapshot unless the current screen supports both portrait ('1') and landscape
/// ('3'). Page 3 locks to portrait — the deliberate screen-orientation violation.
/// The app-level violation (app-orientation-support) lives in Info.plist, which omits
/// UIInterfaceOrientationLandscapeRight (the rule requires BOTH landscape directions).
final class AppDelegate: NSObject, UIApplicationDelegate {
    static var lockPortrait = false

    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        Self.lockPortrait ? .portrait : [.portrait, .landscapeLeft]
    }
}

struct RootView: View {
    @State private var page = 0
    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            switch page {
            case 0: Page1View()   // former pages 1+2 merged — one dense viewport
            default: Page3View()  // forms / order / focus (portrait-locked)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white.ignoresSafeArea())
        .onReceive(timer) { _ in page = (page + 1) % 2 }
    }
}

/// Loads one of the JPEGs shared with the Android fixture (bundled as loose files,
/// so the name includes the extension — same pattern as the existing iOS port).
func bundledImage(_ name: String) -> Image {
    if let ui = UIImage(named: name) { return Image(uiImage: ui) }
    return Image(systemName: "photo")
}
