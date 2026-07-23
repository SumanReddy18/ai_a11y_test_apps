import SwiftUI

/// Rule 2 — Meaningful accessibility label for image.
///
/// Ten meaningful images (portraits, products, status icons) with missing / empty /
/// generic / filename / mismatched labels, plus one hidden from VoiceOver entirely
/// (`.accessibilityHidden(true)` — the iOS analogue of importantForAccessibility="no").
/// Mirrors activity_imageview_label.xml.
struct ImageViewLabelView: View {
    private let columns = [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)]

    // SF Symbol | (bad) label | hidden-from-VoiceOver | tint
    private let items: [(symbol: String, label: String?, hidden: Bool, tint: Color)] = [
        ("person.crop.circle.fill", nil,                        false, Theme.infoBlue),      // 1: no label
        ("person.crop.circle.fill", "image",                    false, Theme.infoBlue),      // 2: generic
        ("person.crop.circle.fill", "",                         false, Theme.infoBlue),      // 3: empty hides identity
        ("person.crop.circle.fill", "avatar_04.jpg",            false, Theme.infoBlue),      // 4: filename
        ("shoe.fill",               "photo",                    false, Theme.brandDark),     // 5: generic
        ("shoe.fill",               "Nike Air sneaker, white",  true,  Theme.brandDark),     // 6: hidden from VoiceOver
        ("applewatch",              "Shop now",                 false, Theme.textPrimary),   // 7: wrong/marketing
        ("exclamationmark.triangle.fill", "icon",               false, Theme.warnYellow),    // 8: single word
        ("exclamationmark.octagon.fill",  "graphic",            false, Theme.violationRed),  // 9: generic
        ("flame.fill",              "picture",                  false, Theme.violationRed),  // 10: generic
    ]

    var body: some View {
        RuleScreen(
            title: Rule.imageviewLabel.title,
            subtitle: Rule.imageviewLabel.desc,
            footer: "Violations: (1) Missing — absent or empty accessibilityLabel. (2) Inadequate — generic (\"image\"/\"photo\"/\"icon\"/\"picture\"/\"graphic\"), filename, or mismatched copy. (3) Inaccessible — image hidden from VoiceOver. WCAG 1.1.1."
        ) {
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, it in
                    ZStack {
                        Theme.card
                        Image(systemName: it.symbol)
                            .resizable()
                            .scaledToFit()
                            .padding(20)
                            .foregroundColor(it.tint)
                    }
                    .frame(height: 96)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.cardBorder, lineWidth: 1))
                    .cornerRadius(8)
                    .asImageElement(label: it.label)
                    .accessibilityHidden(it.hidden)
                }
            }
        }
    }
}
