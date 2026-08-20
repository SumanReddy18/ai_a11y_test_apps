import SwiftUI

/// Page 2 — text, contrast and geometry violations (11 fixtures). This page must
/// NOT sit in a ScrollView: responsive-containers passes any element that has a
/// ScrollView ancestor, and this page carries that fixture. The page also keeps
/// landscape support (see AppDelegate) — the responsive-containers rule is killed
/// for the whole snapshot on an orientation-locked screen.
struct Page2View: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 28) {
                // text-color-contrast: #999999 on white at 14pt ≈ 2.85:1 (< 4.5:1).
                // UIKit-backed: the capture extracts textColor/backgroundColor swatches
                // from real UILabels only — SwiftUI Text gets none and the rule abstains.
                // lines: 0 keeps the may-clip flag off so this doesn't also fire truncation.
                KitLabel(text: "Low contrast body copy", size: 14,
                         color: UIColor(white: 0.6, alpha: 1), lines: 0)
                    .frame(width: 190, height: 20)

                // non-text-contrast: light-grey glyph on white ≈ 2.0:1 (< 3.0:1).
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(white: 0.73))
                    .background(Color.white)
                    .accessibilityLabel("Next")
            }

            // text-magnification: fixed-size custom font — no Dynamic Type support.
            // Full opacity is required: alpha < 1.0 truncates to 0 and skips the element.
            Text("This text will not scale")
                .font(.custom("Helvetica", size: 17))

            HStack(spacing: 44) {
                // text-truncation: fixed 140pt frame clips the line at large type sizes.
                // UIKit-backed: the may-clip flag is computed from UILabel.numberOfLines —
                // SwiftUI Text never gets textProperties, so the rule abstains on it.
                KitLabel(text: "Order confirmation details for your recent purchase",
                         size: 17, lines: 1)
                    .frame(width: 140, height: 20)

                // touch-target-size: 30pt < 44pt on both axes; isolated so the
                // spacing rule (24pt + neighbour proximity) does not also fire here.
                Button(action: {}) {
                    Image(systemName: "xmark").frame(width: 30, height: 30)
                }
                .accessibilityLabel("Close")
            }

            // responsive-containers: StaticText with a fixed-frame ancestor chain and
            // no ScrollView/Table/CollectionView anywhere above it.
            VStack { Text("Reflow violation sample") }
                .frame(width: 300, height: 60)

            HStack(spacing: 44) {
                // touch-target-size-and-spacing: two 20pt targets touching (centres
                // 20pt apart < 24pt). Labels differ so the same-label ancestor
                // exemption cannot apply.
                HStack(spacing: 0) {
                    Button(action: {}) {
                        Image(systemName: "hand.thumbsup").frame(width: 20, height: 20)
                    }
                    .accessibilityLabel("Like")
                    Button(action: {}) {
                        Image(systemName: "hand.thumbsdown").frame(width: 20, height: 20)
                    }
                    .accessibilityLabel("Dislike")
                }

                // overlapping-interactive-elements: two buttons, byte-identical frames.
                // KNOWN ENGINE DEAD-END on iOS: the rule filters on hittable(), and
                // hittability is a hitTest at the element's centre — of two views sharing
                // a frame, at most ONE can own the shared centre pixel, so a same-bounds
                // pair never survives the filter (and only the first UIWindow is
                // serialized, ruling out the two-window trick). Kept for the day the
                // engine drops or softens the hittable gate.
                ZStack {
                    Button(action: {}) {
                        Text("Buy now").frame(width: 200, height: 48)
                    }
                    Button(action: {}) {
                        Color.clear.frame(width: 200, height: 48)
                    }
                    .accessibilityLabel("Buy now overlay")
                }
            }

            // two-dimensional-scroll: one scroll container scrollable on both axes.
            // UIKit-backed: the rule matches type == "UIScrollView" literally, and
            // SwiftUI's ScrollView is backed by a different class name.
            KitTwoAxisScroll().frame(width: 300, height: 140)

            // missing-heading: heading-styled text (title2 bold over footnote body)
            // with NO .isHeader trait anywhere on this page's section titles.
            Text("Order Summary").font(.title2.bold())
            Text("3 items · Delivered Friday").font(.footnote)
            Text("Payment Method").font(.title2.bold())
            Text("Visa ending 4242").font(.footnote)

            // incorrect-heading: small body text wrongly carrying the header trait.
            Text("Info")
                .font(.footnote)
                .accessibilityAddTraits(.isHeader)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
