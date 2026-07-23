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
 * A plain clickable TextView is NOT a link to Android accessibility services —
 * it reports as a generic clickable view, so the "Link text purpose" rule never
 * applies. An element is only treated as a link when its text carries a
 * ClickableSpan/URLSpan. We therefore wrap each vague phrase in a ClickableSpan
 * (and attach LinkMovementMethod) so the scanner sees real link elements whose
 * text fails to convey their destination.
 */
public class LinkTextPurposeActivity extends BaseChildActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_link_text_purpose);

        // VIOLATION 1: article footer links
        linkify(R.id.linkClickHere, "click here");
        linkify(R.id.linkReadMore, "Read more");
        linkify(R.id.linkHere, "here");

        // VIOLATION 2: repeated, indistinguishable "Learn more" links
        linkify(R.id.linkLearnMore1, "Learn more");
        linkify(R.id.linkLearnMore2, "Learn more");
        linkify(R.id.linkLearnMore3, "Learn more");

        // VIOLATION 3: raw URL as the link text
        linkify(R.id.linkRawUrl,
                "https://www.browserstack.com/docs/app-accessibility/overview?ref=demo&src=apk");

        // VIOLATION 4: more ambiguous phrases
        linkify(R.id.linkTapHere, "tap here");
        linkify(R.id.linkThis, "this");
        linkify(R.id.linkMore, "More");
    }

    /**
     * Wraps the first occurrence of {@code linkText} inside the TextView's text
     * in a ClickableSpan, turning that portion into a real, screen-reader-visible
     * link whose accessible name is exactly {@code linkText}.
     */
    private void linkify(int viewId, String linkText) {
        TextView tv = findViewById(viewId);
        String full = tv.getText().toString();
        int start = full.indexOf(linkText);
        if (start < 0) {
            return;
        }
        int end = start + linkText.length();

        SpannableString span = new SpannableString(full);
        span.setSpan(new ClickableSpan() {
            @Override
            public void onClick(@NonNull View widget) {
                // No-op: this is a demo of inaccessible link text, not navigation.
            }
        }, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

        tv.setText(span);
        tv.setMovementMethod(LinkMovementMethod.getInstance());
    }
}
