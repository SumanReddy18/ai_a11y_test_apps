import SwiftUI

/// Rule 1 — Images with text.
///
/// Ten tiles that each VISIBLY contain words, but whose accessible name is missing,
/// empty, generic, a filename, or unrelated marketing copy. VoiceOver conveys none of
/// the embedded text. Mirrors activity_image_with_text.xml.
struct ImagesWithTextView: View {
    private let columns = [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)]

    // caption baked into the tile  |  the (bad) accessible label  |  tile colour
    private let tiles: [(caption: String, label: String?, hidden: Bool, bg: Color)] = [
        ("50% OFF TODAY",        nil,             false, Theme.brandPrimary),   // 1: no label
        ("FLASH SALE",           "image",         false, Theme.violationRed),    // 2: generic
        ("Gate B12 · 09:40",     "A diagram",     false, Theme.infoBlue),        // 3: ignores embedded text
        ("BALANCE ₹4,999",       "",              false, Theme.brandDark),       // 4: empty
        ("BUY 1 GET 1",          "photo",         false, Theme.okGreen),         // 5: generic
        ("TERMINAL 2",           "img_06.jpg",    false, Theme.warnYellow),      // 6: filename
        ("WELCOME BACK",         "Welcome banner",false, Theme.brandPrimary),   // 7: marketing hides text
        ("OTP 4821",             "graphic",       false, Theme.violationRed),    // 8: single word
        ("LOW BATTERY 5%",       "icon",          false, Theme.brandDark),       // 9: generic
        ("SOLD OUT",             "picture",       false, Theme.infoBlue),        // 10: generic
    ]

    var body: some View {
        RuleScreen(
            title: Rule.imagesText.title,
            subtitle: Rule.imagesText.desc,
            footer: "Each tile visibly contains text. VoiceOver gets nothing, \"image\", \"photo\", \"graphic\", an empty string, a filename, or unrelated copy — Issue Detection Agent should flag every one."
        ) {
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Array(tiles.enumerated()), id: \.offset) { _, t in
                    TextTile(caption: t.caption, bg: t.bg)
                        .asImageElement(label: t.label)
                        .accessibilityHidden(t.hidden)
                }
            }
        }
    }
}
