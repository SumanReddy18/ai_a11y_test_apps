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
                // The explicit background is required — nil background is skipped.
                Text("Low contrast body copy")
                    .font(.system(size: 14))
                    .foregroundColor(Color(white: 0.6))
                    .background(Color.white)

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
                Text("Order confirmation details for your recent purchase")
                    .font(.system(size: 17))
                    .lineLimit(1)
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
                // The frame lives INSIDE the button label so the reported element
                // bounds are exactly 200x48 for both.
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
            // This embedded ScrollView is the fixture itself — nothing else sits in it.
            ScrollView([.horizontal, .vertical]) {
                Color.gray.frame(width: 2000, height: 3000)
            }
            .frame(width: 300, height: 140)
            .accessibilityElement(children: .contain)
            // SwiftUI has no .isAdjustable trait; an adjustable action adds the
            // "adjustable" trait the iOS two-dimensional-scroll gate looks for.
            .accessibilityAdjustableAction { _ in }

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
