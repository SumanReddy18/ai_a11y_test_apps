import SwiftUI
import UIKit

/// Rule 2 — Meaningful accessibility label for image.
///
/// The SAME ten photographs the Android fixture uses (`meaningful_img_01…10`, referenced straight
/// out of `android/app/src/main/res/drawable` — see project.yml), with the same ten missing /
/// empty / generic / filename / mismatched accessible names, plus one hidden from VoiceOver
/// entirely (`.accessibilityHidden(true)` — the iOS analogue of importantForAccessibility="no").
/// Mirrors activity_imageview_label.xml.
///
/// NOTE (the gotcha): this screen used to draw SF Symbols. The rule asks the AI whether a label
/// meaningfully describes the image, and judging "Shop now" against a monochrome watch glyph is
/// not the same question as judging it against a product photo — so the same nominal fixture
/// produced different verdicts on iOS and Android, and the filename case ("avatar_04.jpg" on a
/// portrait) lost its point entirely. Same pixels as Android now, same question.
struct ImageViewLabelView: View {
    private let columns = [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)]

    // Same order, same images and same (bad) labels as activity_imageview_label.xml.
    // image | label — nil = no accessible name at all | hidden from VoiceOver
    private let items: [(image: Int, label: String?, hidden: Bool)] = [
        (1,  nil,                       false),  // 1: portrait, no label
        (2,  "image",                   false),  // 2: generic
        (3,  "",                        false),  // 3: empty name hides identity
        (4,  "avatar_04.jpg",           false),  // 4: filename as the name
        (5,  "photo",                   false),  // 5: generic
        (6,  "Nike Air sneaker, white", true),   // 6: meaningful image hidden from VoiceOver
        (7,  "Shop now",                false),  // 7: marketing copy, not a description
        (8,  "icon",                    false),  // 8: single generic word
        (9,  "graphic",                 false),  // 9: generic
        (10, "picture",                 false),  // 10: generic
    ]

    var body: some View {
        RuleScreen {
            AiCaption(task: "AI: check_image_label  ·  imageview-element-content-label",
                      rules: "Every screen also raises reading/visual order + missing/incorrect heading")

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, it in
                    Image(uiImage: Self.artwork(it.image))
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, minHeight: 96, maxHeight: 96)
                        .clipped()
                        .cornerRadius(8)
                        .asImageElement(label: it.label)
                        .accessibilityHidden(it.hidden)
                }
            }
        }
    }

    /// Loose bundle resource, so the name must carry its extension. Fail loudly: a silently blank
    /// tile looks exactly like "the rule wasn't detected", which is the bug this fixture exists to
    /// avoid.
    private static func artwork(_ n: Int) -> UIImage {
        let name = String(format: "meaningful_img_%02d.jpg", n)
        guard let image = UIImage(named: name) else {
            fatalError("\(name) is not in the app bundle — check the resources entry in ios/project.yml")
        }
        return image
    }
}
