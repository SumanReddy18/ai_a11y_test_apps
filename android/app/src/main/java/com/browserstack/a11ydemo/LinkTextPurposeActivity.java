package com.browserstack.a11ydemo;

import android.os.Bundle;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
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

        // Machine text as the label.
        linkifyWholeText(R.id.linkRawUrl);
        linkifyWholeText(R.id.linkFilename);
        linkifyWholeText(R.id.linkHash);

        // More ambiguous phrases.
        linkifyWholeText(R.id.linkTapHere);
        linkifyWholeText(R.id.linkThis);
        linkifyWholeText(R.id.linkMore);
    }

    /**
     * Spans the TextView's entire text with a ClickableSpan, so the element is a real link whose
     * accessible name is exactly that text — nothing else to dilute it.
     */
    static void linkifyWholeText(TextView tv) {
        String full = tv.getText().toString();
        if (full.isEmpty()) {
            return;
        }

        SpannableString span = new SpannableString(full);
        span.setSpan(new ClickableSpan() {
            @Override
            public void onClick(@NonNull View widget) {
                // No-op: this is a demo of inaccessible link text, not navigation.
            }
        }, 0, full.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

        tv.setText(span);
        tv.setMovementMethod(LinkMovementMethod.getInstance());
    }

    private void linkifyWholeText(int viewId) {
        linkifyWholeText((TextView) findViewById(viewId));
    }
}
