package com.browserstack.a11ydemo;

import android.os.Bundle;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.URLSpan;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;

/**
 * Link text purpose violations.
 *
 * Two things have to be true for this rule to fire, and the fixture got the second one wrong
 * for a long time:
 *
 *  1. A plain clickable TextView is NOT a link to Android accessibility services — it reports
 *     as a generic clickable view. An element only counts as a link when its text carries a
 *     ClickableSpan/URLSpan, so every phrase below is spanned (with LinkMovementMethod).
 *  2. The rule judges the element's *speakable text*, not the span's substring. A span over
 *     "click here" inside "To view our refund policy, click here" gave a detected label of the
 *     whole sentence, which does convey a purpose — so nothing was reported except the line
 *     whose sentence happened to contain a raw URL. Each link therefore lives in its own
 *     TextView containing nothing but the phrase, and the span covers all of it.
 *
 * With the phrase alone as the label, "click here"/"read more"/"here"/"learn more"/"tap here"/
 * "this"/"more" are exact matches for the rule's stop-word list — a deterministic FAIL. The raw
 * URL, the filename and "#" are not stop words and go to AI review with just the phrase.
 */
public class LinkTextPurposeActivity extends BaseChildActivity {

    /** Destination reported by every {@link URLSpan} on this screen. */
    private static final String DEMO_DESTINATION = "https://www.browserstack.com/docs/app-accessibility";

    /**
     * A real {@code URLSpan} — so the capture layer records its URL and the rule's stop-word check
     * runs — whose click does nothing.
     *
     * <p>A plain {@code URLSpan} would hand the tap to the system: a crawler that activates one
     * either leaves the app under scan (http/https) or crashes on {@code ActivityNotFoundException}
     * (unregistered custom scheme). Overriding {@code onClick} keeps {@code instanceof URLSpan} and
     * {@code getURL()} intact while making the link inert.
     */
    private static final class InertUrlSpan extends URLSpan {
        InertUrlSpan(String url) {
            super(url);
        }

        @Override
        public void onClick(@NonNull View widget) {
            // No-op: this is a demo of inaccessible link text, not navigation.
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_link_text_purpose);

        // Vague action phrases — stop words.
        linkifyWholeText(R.id.linkClickHere);
        linkifyWholeText(R.id.linkReadMore);
        linkifyWholeText(R.id.linkHere);

        // Repeated, indistinguishable "Learn more" links.
        linkifyWholeText(R.id.linkLearnMore1);
        linkifyWholeText(R.id.linkLearnMore2);
        linkifyWholeText(R.id.linkLearnMore3);

        // Machine text as the label — not stop words, so these are the ones that
        // reach AI review and prove the AI side of this rule is alive.
        linkifyWholeText(R.id.linkRawUrl);
        linkifyWholeText(R.id.linkFilename);
        linkifyWholeText(R.id.linkHash);

        // More ambiguous phrases.
        linkifyWholeText(R.id.linkTapHere);

        // Bare ClickableSpan (no URL): keeps the "clickable text that is not a
        // URL link" shape covered, which is a different branch of the rule's
        // span handling than the URLSpan links above.
        linkifyWholeText(R.id.linkThis, false);
        linkifyWholeText(R.id.linkMore, false);
    }

    /**
     * Spans the TextView's entire text with a {@link URLSpan}, so the element is a real link whose
     * accessible name is exactly that text — nothing else to dilute it.
     *
     * <p>The URL is not decoration. The capture layer only records a span's URL when the span is a
     * {@code URLSpan} (AppAccessibility.java: {@code if (span instanceof URLSpan) url = …}, else
     * {@code ""}), and the rule's stop-word check is gated on that URL being non-blank
     * (BSAIRules.kt: {@code if (!url.isNullOrBlank() && isStopWord(text)) hits.add(text)}).
     *
     * <p>With a bare {@code ClickableSpan} the URL was always empty, so {@code hits} never
     * populated and EVERY link — including the six vague phrases below — fell through to AI review.
     * The deterministic stop-word FAIL this screen documents never actually fired, which also meant
     * the screen had no violation floor: if the AI declined every link, the build reported nothing.
     */
    static void linkifyWholeText(TextView tv) {
        linkifyWholeText(tv, true);
    }

    /**
     * @param asUrlSpan {@code true} for a real {@code URLSpan} (carries a URL, so stop-word links
     *                  fail deterministically); {@code false} for a bare {@code ClickableSpan},
     *                  which keeps the "clickable text with no URL" shape covered.
     */
    static void linkifyWholeText(TextView tv, boolean asUrlSpan) {
        String full = tv.getText().toString();
        if (full.isEmpty()) {
            return;
        }

        SpannableString span = new SpannableString(full);
        Object clickable = asUrlSpan
                ? new InertUrlSpan(DEMO_DESTINATION)
                : new ClickableSpan() {
                    @Override
                    public void onClick(@NonNull View widget) {
                        // No-op: this is a demo of inaccessible link text, not navigation.
                    }
                };
        span.setSpan(clickable, 0, full.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

        tv.setText(span);
        tv.setMovementMethod(LinkMovementMethod.getInstance());
    }

    private void linkifyWholeText(int viewId) {
        linkifyWholeText((TextView) findViewById(viewId), true);
    }

    private void linkifyWholeText(int viewId, boolean asUrlSpan) {
        linkifyWholeText((TextView) findViewById(viewId), asUrlSpan);
    }
}
