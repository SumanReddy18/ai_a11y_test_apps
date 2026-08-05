import SwiftUI
import UIKit

/// Rule 1 — Images with text.
///
/// The SAME ten JPEGs the Android fixture uses (`unsplash_text_01…10`, referenced straight out of
/// `android/app/src/main/res/drawable` — see project.yml), in the same 2-column grid, with the same
/// ten missing / empty / generic / filename / mismatched accessible names. Android detects on these
/// bitmaps, so iOS uses the identical pixels rather than artwork of its own.
///
/// NOTE (the gotcha): the words must live in image PIXELS. An earlier version drew coloured
/// `ZStack`s containing a SwiftUI `Text` tagged `.isImage` — no image anywhere, nothing for the
/// scanner to read text out of, so the rule never fired.
struct ImagesWithTextView: View {
    private let columns = [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)]

    // Same order and same (bad) labels as activity_image_with_text.xml.
    private let tiles: [(image: Int, label: String?)] = [
        (1,  nil),               // no accessible name at all
        (2,  "image"),           // generic
        (3,  "A diagram"),       // description ignores the embedded text
        (4,  ""),                // empty name
        (5,  "photo"),           // generic
        (6,  "img_06.jpg"),      // filename used as the name
        (7,  "Welcome banner"),  // marketing copy hides the text
        (8,  "graphic"),         // single generic word
        (9,  "icon"),            // generic
        (10, "picture"),         // generic
    ]

    var body: some View {
        RuleScreen(
            title: Rule.imagesText.title,
            subtitle: Rule.imagesText.desc,
            footer: "Each image visibly contains text. VoiceOver gets nothing, \"image\", \"photo\", \"graphic\", an empty string, a filename, or unrelated copy — Issue Detection Agent should flag every one."
        ) {
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Array(tiles.enumerated()), id: \.offset) { _, t in
                    Image(uiImage: Self.artwork(t.image))
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, minHeight: 104, maxHeight: 104)
                        .clipped()
                        .cornerRadius(8)
                        .asImageElement(label: t.label)
                }
            }
        }
    }

    /// Loose bundle resource, so the name must carry its extension. Fail loudly: a silently
    /// blank tile looks exactly like "the rule wasn't detected", which is the bug this fixture
    /// exists to avoid.
    private static func artwork(_ n: Int) -> UIImage {
        let name = String(format: "unsplash_text_%02d.jpg", n)
        guard let image = UIImage(named: name) else {
            fatalError("\(name) is not in the app bundle — check the resources entry in ios/project.yml")
        }
        return image
    }
}
