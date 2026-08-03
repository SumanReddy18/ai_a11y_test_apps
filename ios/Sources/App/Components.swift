import SwiftUI
import UIKit

// MARK: - Screen scaffolding (mirrors styles.xml ScreenRoot / ScreenH1 / ScreenSub)

/// Standard violation-screen wrapper: scrollable, padded, with an H1 title + subtitle
/// and a grey explanatory footer — matching the Android BaseChildActivity screens.
struct RuleScreen<Content: View>: View {
    let title: String
    let subtitle: String
    let footer: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                    .padding(.bottom, 4)
                    // Real screen heading — correctly exposed as a header.
                    .accessibilityAddTraits(.isHeader)

                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.bottom, 14)

                content()

                Text(footer)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.top, 14)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Theme.bg)
    }
}

/// Red "VIOLATION N: …" badge — the Android SectionLabel + badge_red drawable.
struct SectionBadge: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Theme.violationRed)
            .cornerRadius(4)
    }
}

/// White rounded card — the Android card_bg drawable.
struct Card<Content: View>: View {
    var alignment: HorizontalAlignment = .leading
    @ViewBuilder var content: () -> Content
    var body: some View {
        VStack(alignment: alignment, spacing: 0, content: content)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.cardBorder, lineWidth: 1))
            .cornerRadius(12)
    }
}

// MARK: - Real artwork whose PIXELS contain text (rule 1)

/// Bitmaps drawn with `UIGraphicsImageRenderer`, so the words genuinely live in image pixels.
///
/// The previous fixture faked this with a SwiftUI `Text` inside a coloured `ZStack` wearing the
/// `.isImage` trait. There was no image anywhere — not in the pixels, not in the render tree — so
/// the scanner saw a styled label rather than "a graphic carrying information as text", and rule 1
/// never fired on iOS. (Android passes because its tiles are real JPEGs.) Each helper renders a
/// DIFFERENT kind of text-bearing graphic — promo banner, a CTA that is entirely an image, a
/// chart, a screenshot of a paragraph, a data table, a logo wordmark — rather than six tinted
/// rectangles, so detection does not hinge on one example being recognised.
enum TextArtwork {
    private static let width: CGFloat = 1000

    /// Promo banner — sale copy baked into the artwork.
    static func banner(_ headline: String, _ sub: String, bg: UIColor) -> UIImage {
        render(height: 220) { _ in
            fill(bg, height: 220)
            draw(headline, x: 40, y: 52, size: 76, weight: .heavy, color: .white)
            draw(sub, x: 40, y: 148, size: 34, color: UIColor(hex: 0xFFE0C2))
        }
    }

    /// A call-to-action button that IS an image — its label exists only in pixels.
    static func cta(_ label: String, bg: UIColor) -> UIImage {
        render(height: 180) { ctx in
            fill(.white, height: 180)
            ctx.setFillColor(bg.cgColor)
            ctx.addPath(UIBezierPath(roundedRect: CGRect(x: 30, y: 25, width: width - 60, height: 130),
                                     cornerRadius: 24).cgPath)
            ctx.fillPath()
            draw(label, x: width / 2, y: 60, size: 52, weight: .bold, color: .white, anchor: .center)
        }
    }

    /// Bar chart — the values and axis labels are pixels, unavailable to a screen reader.
    static func chart(_ title: String, labels: [String], pct: [Int]) -> UIImage {
        render(height: 300) { ctx in
            fill(.white, height: 300)
            draw(title, x: 32, y: 20, size: 40, weight: .bold, color: UIColor(hex: 0x111111))
            let base: CGFloat = 240, barW: CGFloat = 140
            for (i, label) in labels.enumerated() {
                let x = 60 + CGFloat(i) * (barW + 60)
                let h = CGFloat(pct[i]) * 1.2
                // Re-set every pass: drawing the labels below leaves the context's fill colour
                // set to the text colour.
                ctx.setFillColor(UIColor(hex: 0x1F6FEB).cgColor)
                ctx.fill(CGRect(x: x, y: base - h, width: barW, height: h))
                draw("\(pct[i])%", x: x, y: base - h - 40, size: 30, weight: .bold,
                     color: UIColor(hex: 0x111111))
                draw(label, x: x, y: base + 12, size: 30, color: UIColor(hex: 0x333333))
            }
        }
    }

    /// Screenshot-of-text — a whole paragraph flattened into a picture.
    static func paragraph(_ title: String, lines: [String]) -> UIImage {
        render(height: 300) { _ in
            fill(.white, height: 300)
            draw(title, x: 32, y: 20, size: 44, weight: .bold, color: UIColor(hex: 0x111111))
            for (i, line) in lines.enumerated() {
                draw(line, x: 32, y: 96 + CGFloat(i) * 48, size: 34, color: UIColor(hex: 0x333333))
            }
        }
    }

    /// Data table — label/value rows, the way a screenshot of an order summary looks.
    static func receipt(_ title: String, rows: [(String, String)]) -> UIImage {
        render(height: 260) { ctx in
            fill(UIColor(hex: 0xF5F6FA), height: 260)
            draw(title, x: 32, y: 18, size: 42, weight: .bold, color: UIColor(hex: 0x111111))
            for (i, row) in rows.enumerated() {
                let y = 96 + CGFloat(i) * 56
                draw(row.0, x: 32, y: y, size: 32, color: UIColor(hex: 0x5A5A66))
                draw(row.1, x: width - 32, y: y, size: 32, weight: .bold,
                     color: UIColor(hex: 0x111111), anchor: .right)
                // Re-set every pass: the text drawn above leaves its own colour on the context.
                ctx.setFillColor(UIColor(hex: 0xE5E5EA).cgColor)
                ctx.fill(CGRect(x: 32, y: y + 44, width: width - 64, height: 1))
            }
        }
    }

    /// Logo wordmark plus tagline — brand text that exists only as artwork.
    static func wordmark(_ brand: String, _ tagline: String, bg: UIColor) -> UIImage {
        render(height: 180) { ctx in
            fill(bg, height: 180)
            ctx.setFillColor(UIColor(hex: 0xFF6B00).cgColor)
            ctx.fillEllipse(in: CGRect(x: 36, y: 56, width: 68, height: 68))
            draw(brand, x: 126, y: 40, size: 56, weight: .heavy, color: .white)
            draw(tagline, x: 128, y: 116, size: 30, color: UIColor(hex: 0x9A9AA6))
        }
    }

    // ------------------------------------------------------------------ drawing primitives

    private enum Anchor { case left, center, right }

    private static func render(height: CGFloat, _ body: (CGContext) -> Void) -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
            .image { body($0.cgContext) }
    }

    private static func fill(_ color: UIColor, height: CGFloat) {
        color.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 0, width: width, height: height)).fill()
    }

    /// `y` is the TOP of the text, not its baseline.
    private static func draw(_ s: String, x: CGFloat, y: CGFloat, size: CGFloat,
                             weight: UIFont.Weight = .regular, color: UIColor,
                             anchor: Anchor = .left) {
        let str = NSAttributedString(string: s, attributes: [
            .font: UIFont.systemFont(ofSize: size, weight: weight),
            .foregroundColor: color,
        ])
        let originX: CGFloat
        switch anchor {
        case .left:   originX = x
        case .center: originX = x - str.size().width / 2
        case .right:  originX = x - str.size().width
        }
        str.draw(at: CGPoint(x: originX, y: y))
    }
}

/// UIKit twin of `Color(hex:)` in Theme.swift, so the artwork uses the same palette.
extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red:   CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue:  CGFloat(hex & 0xFF) / 255,
                  alpha: 1)
    }
}

// MARK: - Accessibility helpers for image-label violations

extension View {
    /// Treat this view as a single IMAGE element with the given (deliberately bad)
    /// accessible name. Pass `nil` for the "missing label" case — the element still
    /// exists and is focusable, it just has no name.
    func asImageElement(label: String?) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityAddTraits(.isImage)
            .modifier(OptionalLabel(label: label))
    }
}

private struct OptionalLabel: ViewModifier {
    let label: String?
    func body(content: Content) -> some View {
        if let label { content.accessibilityLabel(Text(label)) }
        else { content }
    }
}
