import SwiftUI
import UIKit

/// Rule 1 — Images with text.
///
/// Six REAL bitmaps (see `TextArtwork`) whose pixels contain words, each a different kind of
/// text-bearing graphic, and each with a missing / empty / generic / filename / mismatched
/// accessible name. VoiceOver conveys none of the embedded text. Mirrors
/// activity_image_with_text.xml.
///
/// NOTE (the gotcha): this screen previously drew coloured `ZStack`s containing a SwiftUI `Text`
/// and tagged them `.isImage`. Nothing about that is an image — the words are live text in the
/// render tree, not pixels — so the scanner found no image to read text out of and the rule never
/// fired. The artwork must be an actual rasterised `UIImage`.
struct ImagesWithTextView: View {
    // Rendered once, not per body evaluation.
    private static let tiles: [(image: UIImage, label: String?)] = [
        // 1: no accessible name at all
        (TextArtwork.banner("FLAT 50% OFF", "Use code SAVE50 · Ends Sunday midnight",
                            bg: UIColor(hex: 0xD72638)), nil),
        // 2: generic name — the button's whole label is trapped in the picture
        (TextArtwork.cta("CONTINUE TO PAYMENT", bg: UIColor(hex: 0xFF6B00)), "button"),
        // 3: names the chart type, none of the data it renders as text
        (TextArtwork.chart("Crash-free sessions by quarter",
                           labels: ["Q1", "Q2", "Q3", "Q4"], pct: [42, 61, 78, 94]), "chart"),
        // 4: empty name — a full paragraph of policy text, silent to VoiceOver
        (TextArtwork.paragraph("Refund policy", lines: [
            "Cancel within 24 hours for a full refund.",
            "After dispatch, return shipping is deducted.",
            "Digital licences are refundable only if unused.",
            "Refunds arrive within 5-7 business days."]), ""),
        // 5: filename used as the name
        (TextArtwork.receipt("Order #4821", rows: [
            ("Wireless Headphones X9", "Rs 4,999"),
            ("Delivery", "Fri, 8 Aug"),
            ("Total paid", "Rs 4,999")]), "img_05.jpg"),
        // 6: generic name that ignores the tagline baked beside the mark
        (TextArtwork.wordmark("BrowserStack", "Test on 3000+ real devices",
                              bg: UIColor(hex: 0x1B1B1F)), "logo"),
    ]

    var body: some View {
        RuleScreen(
            title: Rule.imagesText.title,
            subtitle: Rule.imagesText.desc,
            footer: "Six different kinds of image carry their information as pixels: a promo banner, a CTA that is entirely a picture, a chart, a screenshot of a paragraph, an order table, and a logo wordmark. VoiceOver gets nothing, \"button\", \"chart\", an empty string, a filename, or \"logo\" — Issue Detection Agent should flag every one."
        ) {
            // Tight spacing so all six tiles land in one viewport — a single-rule scan captures
            // whatever is on screen, it does not scroll.
            VStack(spacing: 8) {
                ForEach(Array(Self.tiles.enumerated()), id: \.offset) { _, t in
                    Image(uiImage: t.image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(8)
                        .asImageElement(label: t.label)
                }
            }
        }
    }
}
