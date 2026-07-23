# iOS fixture (`ios/`) — the `.ipa` counterpart of the Android app

Native **SwiftUI** port of the Android accessibility demo in this repo. It deliberately
violates the **same 8 BrowserStack App Accessibility rules**, so the iOS
[Issue Detection Agent](https://www.browserstack.com/docs/app-accessibility/ai-powered-testing/issue-detection-agent)
can be validated the same way the APK validates the Android agent.

Why a rewrite and not a "conversion": an APK is Android bytecode + XML; an IPA is iOS
native. Nothing transfers. And the whole point of this fixture is **accessibility
semantics**, which are a completely different API on each platform — so each violation is
reproduced with the iOS trait the scanner actually inspects (see the mapping below).

## ⚠️ You need full Xcode (this machine only has Command Line Tools)

There is **no iOS SDK, no simulator, and no signing identity** under Command Line Tools,
so an `.ipa` (or even a simulator build) **cannot be produced here as-is**. To build it:

1. Install **Xcode** from the App Store (~15 GB), then:
   ```bash
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   xcodebuild -version         # should now work
   ```
2. Install the project generator (one-time):
   ```bash
   brew install xcodegen
   ```

## Generate the Xcode project

```bash
cd ios
xcodegen generate          # reads project.yml → creates A11yDemo.xcodeproj
open A11yDemo.xcodeproj
```

`A11yDemo.xcodeproj` is generated, so it is **not** committed — regenerate it any time from
`project.yml`.

## Build & run

**Simulator (no Apple account needed):**
```bash
xcodebuild -project A11yDemo.xcodeproj -scheme A11yDemo \
  -destination 'platform=iOS Simulator,name=iPhone 15' build
```

**Device-installable, signed `.ipa`** (needs an Apple Developer account / team):
```bash
# archive
xcodebuild -project A11yDemo.xcodeproj -scheme A11yDemo \
  -destination 'generic/platform=iOS' \
  -archivePath build/A11yDemo.xcarchive archive \
  DEVELOPMENT_TEAM=<YOUR_TEAM_ID> -allowProvisioningUpdates

# export .ipa (create exportOptions.plist with your method, e.g. development)
xcodebuild -exportArchive -archivePath build/A11yDemo.xcarchive \
  -exportPath build/ipa -exportOptionsPlist exportOptions.plist
```
Check whether the BrowserStack iOS Issue Detection Agent accepts an **unsigned / simulator**
build before paying for signing — if it does, you can skip the Developer Program entirely.

## Flavors → targets (the same "one build per rule" model)

The Android app ships one APK **flavor** per rule (distinct `applicationId`, launches
straight into that one screen). Here that maps to one **target** per rule in `project.yml`,
each with its own bundle id and an `A11Y_RULE` value baked into `Info.plist`:

| Android flavor | iOS scheme/target | Bundle id | Launches |
|---|---|---|---|
| `full` | `A11yDemo` | `com.browserstack.a11ydemo` | Home + all rules |
| `allViolations` | `A11yDemo-AllViolations` | `…allviolations` | Combined screen |
| `imagesText` | `A11yDemo-ImagesText` | `…imagestext` | Rule 1 only |
| `imageviewLabel` | `A11yDemo-ImageViewLabel` | `…imageviewlabel` | Rule 2 only |
| `interactiveLabel` | `A11yDemo-InteractiveLabel` | `…interactivelabel` | Rule 3 only |
| `readingOrder` | `A11yDemo-ReadingOrder` | `…readingorder` | Rule 4 only |
| `visualOrder` | `A11yDemo-VisualOrder` | `…visualorder` | Rule 5 only |
| `missingHeading` | `A11yDemo-MissingHeading` | `…missingheading` | Rule 6 only |
| `incorrectHeading` | `A11yDemo-IncorrectHeading` | `…incorrectheading` | Rule 7 only |
| `linkTextPurpose` | `A11yDemo-LinkTextPurpose` | `…linktextpurpose` | Rule 8 only |

Build a single-issue one by naming its scheme, e.g. `-scheme A11yDemo-LinkTextPurpose`.
For a quick local run you can also override the selection without a per-target build by
setting the `A11Y_RULE` environment variable in the scheme's Run action (any value from the
`Rule` enum, or `full` / `all`).

## How each rule maps to an iOS accessibility semantic

The scanner classifies by platform semantics, not looks (same gotcha as CLAUDE.md). The
iOS equivalents used here:

| # | Rule | Android mechanism | iOS mechanism (this port) |
|---|---|---|---|
| 1 | Images with text | `ImageView` w/ bad `contentDescription` | image element (`.isImage`) w/ missing/generic/empty label |
| 2 | Image a11y label | `contentDescription`, `importantForAccessibility="no"` | `accessibilityLabel`, `.accessibilityHidden(true)` |
| 3 | Interactive label | `ImageButton`/`Switch`/`EditText` labels | `Button`/`Toggle`/`TextField` w/ missing/generic/wrong `accessibilityLabel` |
| 4 | Reading order | `accessibilityTraversalAfter` | `.accessibilitySortPriority(_)` (scrambled) |
| 5 | Visual order | scrambled layout order | scrambled `VStack` order (layout only) |
| 6 | Missing heading | no `accessibilityHeading="true"` | plain `Text`, **no** `.isHeader` trait |
| 7 | Incorrect heading | `accessibilityHeading="true"` on body/error/button | `.accessibilityAddTraits(.isHeader)` on the wrong elements |
| 8 | Link text purpose | `ClickableSpan` w/ vague text | `AttributedString` `.link` run w/ vague text |

## Layout

```
ios/
  project.yml                 # XcodeGen — targets, versions, bundle ids (the important file)
  App/Info.plist              # shared; A11Y_RULE=$(A11Y_RULE) selects the launch screen
  Sources/App/
    A11yDemoApp.swift         # @main + RootView (reads A11yRuleSelection)
    Rule.swift                # 8-rule catalog + flavor-equivalent selection logic
    Theme.swift               # colours mirrored from Android colors.xml
    Components.swift          # RuleScreen / Card / SectionBadge / TextTile + a11y helpers
    HomeView.swift            # home nav (≈ MainActivity)
    AllViolationsView.swift   # combined screen (≈ AllViolationsActivity)
    Screens/*.swift           # one view per rule (≈ the Android Activities/layouts)
```

## Status

All Swift type-checks cleanly against the macOS SDK (the only iOS-specific APIs it flags —
`keyboardType`, `navigationBarTitleDisplayMode` — are valid on iOS). It has **not** been
compiled or run on a real iOS SDK/simulator on this machine because full Xcode isn't
installed here — do a first build in Xcode and sanity-check the screens.
