import SwiftUI
import UIKit

/// UIKit-backed fixtures.
///
/// The on-device engine keys several rules off UIKit runtime class names and capture
/// fields that SwiftUI accessibility nodes never produce: SwiftUI elements are captured
/// as `AccessibilityNode`s with NO `isHittable` key (rules gated on hittability skip
/// them), `text` set to a copy of the accessibility label (label-vs-text rules pass by
/// construction), and empty `textProperties` (contrast / truncation / clip flags are
/// extracted only from UILabel / UITextField / UITextView / UIButton instances).
/// Every fixture below exists because its rule inspects one of those UIKit-only signals.

/// UIButton wrapper. `clearTraits` empties `accessibilityTraits` — the exact shape
/// interactive-element-unsupported-type (recognised control class, empty traits) and
/// missing-view-type-in-spoken-output (caption carries no role word) both FAIL on.
struct KitButton: UIViewRepresentable {
    var title: String
    var accessibilityLabel: String? = nil
    var clearTraits = false

    func makeUIView(context: Context) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        if let label = accessibilityLabel { b.accessibilityLabel = label }
        if clearTraits { b.accessibilityTraits = [] }
        return b
    }

    func updateUIView(_ uiView: UIButton, context: Context) {}

    // Clamp to the SwiftUI-proposed size: without this, the view's
    // intrinsicContentSize (full-res image / long text line) wins over .frame()
    // and overflows the page — see the v1.0.4 screenshot bug.
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIButton, context: Context) -> CGSize? {
        guard let w = proposal.width, let h = proposal.height else { return nil }
        return CGSize(width: w, height: h)
    }
}

/// Accessible UIImageView with NO label — the deterministic
/// imageview-element-content-label FAIL (a present label only goes to AI review).
struct KitImageView: UIViewRepresentable {
    var imageName: String

    func makeUIView(context: Context) -> UIImageView {
        let iv = UIImageView(image: UIImage(named: imageName))
        iv.isAccessibilityElement = true
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {}

    // Clamp to the SwiftUI-proposed size: without this, the view's
    // intrinsicContentSize (full-res image / long text line) wins over .frame()
    // and overflows the page — see the v1.0.4 screenshot bug.
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIImageView, context: Context) -> CGSize? {
        guard let w = proposal.width, let h = proposal.height else { return nil }
        return CGSize(width: w, height: h)
    }
}

/// UILabel wrapper — the capture pass reads textColor / backgroundColor / the
/// may-clip flag off real UILabels only. `lines: 1` sets the clip flag
/// (text-truncation); `lines: 0` keeps it clear so a fixture fires one rule, not two.
struct KitLabel: UIViewRepresentable {
    var text: String
    var size: CGFloat
    var color: UIColor = .black
    var background: UIColor = .white
    var lines: Int = 0

    func makeUIView(context: Context) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: size)
        l.textColor = color
        l.backgroundColor = background
        l.numberOfLines = lines
        l.lineBreakMode = .byTruncatingTail
        return l
    }

    func updateUIView(_ uiView: UILabel, context: Context) {}

    // Clamp to the SwiftUI-proposed size: without this, the view's
    // intrinsicContentSize (full-res image / long text line) wins over .frame()
    // and overflows the page — see the v1.0.4 screenshot bug.
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UILabel, context: Context) -> CGSize? {
        guard let w = proposal.width, let h = proposal.height else { return nil }
        return CGSize(width: w, height: h)
    }
}

/// Real UIScrollView scrollable on both axes — the two-dimensional-scroll rule matches
/// `type == "UIScrollView"` literally, and checks the CHILDREN's frames overflow the
/// container on both axes, so the oversize content must be a subview with a set frame.
struct KitTwoAxisScroll: UIViewRepresentable {
    func makeUIView(context: Context) -> UIScrollView {
        let s = UIScrollView()
        let content = UIView(frame: CGRect(x: 0, y: 0, width: 2000, height: 3000))
        content.backgroundColor = .systemGray4
        s.addSubview(content)
        s.contentSize = content.frame.size
        return s
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {}

    // Clamp to the SwiftUI-proposed size: without this, the view's
    // intrinsicContentSize (full-res image / long text line) wins over .frame()
    // and overflows the page — see the v1.0.4 screenshot bug.
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIScrollView, context: Context) -> CGSize? {
        guard let w = proposal.width, let h = proposal.height else { return nil }
        return CGSize(width: w, height: h)
    }
}
