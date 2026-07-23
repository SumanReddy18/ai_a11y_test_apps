import SwiftUI

/// One accessibility rule the fixture deliberately violates.
///
/// `id` values match the Gradle flavor names in the Android app (`app/build.gradle`)
/// so a per-rule iOS build can be selected the same way a flavor is on Android —
/// see `A11yRuleSelection`.
enum Rule: String, CaseIterable, Identifiable {
    case imagesText
    case imageviewLabel
    case interactiveLabel
    case readingOrder
    case visualOrder
    case missingHeading
    case incorrectHeading
    case linkTextPurpose

    var id: String { rawValue }

    /// "1. Images with text", … — mirrors ruleN_title in strings.xml.
    var title: String {
        switch self {
        case .imagesText:       return "1. Images with text"
        case .imageviewLabel:   return "2. Meaningful a11y label for image"
        case .interactiveLabel: return "3. Interactive element accessibility label"
        case .readingOrder:     return "4. Meaningful reading order"
        case .visualOrder:      return "5. Meaningful visual order"
        case .missingHeading:   return "6. Missing heading"
        case .incorrectHeading: return "7. Incorrect heading"
        case .linkTextPurpose:  return "8. Link text purpose"
        }
    }

    /// Mirrors ruleN_desc in strings.xml.
    var desc: String {
        switch self {
        case .imagesText:
            return "Image carries informational text, but the alt label is missing or generic."
        case .imageviewLabel:
            return "Non-decorative Image elements must have a clear accessibilityLabel. Violations: missing, empty, inadequate (generic/filename/mismatched), or hidden from VoiceOver."
        case .interactiveLabel:
            return "Every interactive element needs a non-empty, descriptive label. Covers buttons, toggles, and text fields. Violations: missing, generic, or contextually inaccurate label."
        case .readingOrder:
            return "VoiceOver focus order does not match the logical reading order."
        case .visualOrder:
            return "Visual arrangement contradicts the natural top-to-bottom flow."
        case .missingHeading:
            return "Section titles look like headings visually but are not exposed as headers to VoiceOver — heading rotor navigation skips them."
        case .incorrectHeading:
            return "Body copy, ads, or error states are marked as headers — heading rotor lands on noise instead of real sections."
        case .linkTextPurpose:
            return "Links labelled \"click here\", \"read more\", or a raw URL don't convey their destination out of context."
        }
    }

    @ViewBuilder
    var screen: some View {
        switch self {
        case .imagesText:       ImagesWithTextView()
        case .imageviewLabel:   ImageViewLabelView()
        case .interactiveLabel: InteractiveLabelView()
        case .readingOrder:     ReadingOrderView()
        case .visualOrder:      VisualOrderView()
        case .missingHeading:   MissingHeadingView()
        case .incorrectHeading: IncorrectHeadingView()
        case .linkTextPurpose:  LinkTextPurposeView()
        }
    }
}

/// Which screen the app launches into — the iOS equivalent of picking a Gradle flavor.
///
/// Resolution order (first hit wins):
///   1. `A11Y_RULE` environment variable  — set per-scheme in Xcode for local runs.
///   2. `A11Y_RULE` key in Info.plist      — baked into the built .app/.ipa (the real
///                                            "flavor" mechanism for a scan on device).
///   3. default → `.full` (home screen with every rule, like the `full` flavor).
///
/// Recognised values: any Rule.rawValue, plus `full` (home nav) and `all` (combined screen).
enum A11yRuleSelection {
    case full
    case all
    case single(Rule)

    static var current: A11yRuleSelection {
        let raw = ProcessInfo.processInfo.environment["A11Y_RULE"]
            ?? (Bundle.main.object(forInfoDictionaryKey: "A11Y_RULE") as? String)
            ?? "full"

        switch raw {
        case "full", "": return .full
        case "all", "allViolations": return .all
        default:
            if let rule = Rule(rawValue: raw) { return .single(rule) }
            return .full
        }
    }
}
