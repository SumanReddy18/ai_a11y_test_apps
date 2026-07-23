package com.browserstack.a11ydemo;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.view.View;
import android.widget.Button;
import android.widget.ScrollView;
import android.widget.TextView;

import androidx.annotation.NonNull;

public class AllViolationsActivity extends BaseChildActivity {

    // Section anchors (each rule's heading), top-to-bottom. The "Next ↓" button
    // jumps to the next one below the current scroll position.
    private static final int[] SECTION_ANCHORS = {
            R.id.sec1, R.id.sec2, R.id.sec3, R.id.sec4,
            R.id.sec5, R.id.sec6, R.id.sec7, R.id.sec8
    };

    // Auto-scroll: the screen walks itself through every section, on a loop, so a
    // continuous accessibility scan captures all of them without any taps. It loops
    // (rather than scrolling once) because the scan is started by the harness only
    // after app upload + config — well after launch — so a single pass would race
    // ahead and miss sections. Looping means any full cycle covers every section.
    // Dwell long enough per section for the scan to capture the viewport. (The
    // manual "Next ↓" button still works for hand testing.)
    private static final long AUTOSCROLL_INITIAL_DELAY_MS = 5000;  // settle before the first hop
    private static final long AUTOSCROLL_STEP_DELAY_MS = 14000;    // dwell per section for the scan
    private final Handler autoScrollHandler = new Handler(Looper.getMainLooper());
    private int autoScrollIndex = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_all_violations);

        final ScrollView scroll = findViewById(R.id.allScroll);
        Button next = findViewById(R.id.btnNextViolation);
        next.setOnClickListener(v -> scrollToNextSection(scroll));
        startAutoScroll(scroll);

        // Rule 8 — Link text purpose. A plain clickable TextView is NOT a link to
        // accessibility services, so the rule never fires. Wrap each vague phrase in
        // a ClickableSpan so the scanner sees real link elements whose text fails to
        // convey their destination (mirrors LinkTextPurposeActivity).
        // VIOLATION 1: article footer links
        linkify(R.id.av_linkClickHere, "click here");
        linkify(R.id.av_linkReadMore, "Read more");
        linkify(R.id.av_linkHere, "here");
        // VIOLATION 2: repeated, indistinguishable "Learn more" links
        linkify(R.id.av_linkLearnMore1, "Learn more");
        linkify(R.id.av_linkLearnMore2, "Learn more");
        linkify(R.id.av_linkLearnMore3, "Learn more");
        // VIOLATION 3: raw URL as the link text
        linkify(R.id.av_linkRawUrl,
                "https://www.browserstack.com/docs/app-accessibility/overview?ref=demo&src=apk");
        // VIOLATION 4: more ambiguous phrases
        linkify(R.id.av_linkTapHere, "tap here");
        linkify(R.id.av_linkThis, "this");
        linkify(R.id.av_linkMore, "More");
    }

    /**
     * Walks through every section on a timer, looping back to the top after the
     * last one, so a continuous scan captures each section hands-free regardless
     * of when scanning starts. Each section is held for
     * {@code AUTOSCROLL_STEP_DELAY_MS} before advancing.
     */
    private void startAutoScroll(ScrollView scroll) {
        autoScrollHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                View anchor = findViewById(SECTION_ANCHORS[autoScrollIndex]);
                if (anchor != null) {
                    scroll.smoothScrollTo(0, anchor.getTop());
                }
                autoScrollIndex = (autoScrollIndex + 1) % SECTION_ANCHORS.length;
                autoScrollHandler.postDelayed(this, AUTOSCROLL_STEP_DELAY_MS);
            }
        }, AUTOSCROLL_INITIAL_DELAY_MS);
    }

    @Override
    protected void onDestroy() {
        autoScrollHandler.removeCallbacksAndMessages(null);
        super.onDestroy();
    }

    /**
     * Smooth-scrolls to the first section heading below the current scroll
     * position. Once past the last section, wraps back to the top.
     */
    private void scrollToNextSection(ScrollView scroll) {
        int currentY = scroll.getScrollY();
        for (int id : SECTION_ANCHORS) {
            View anchor = findViewById(id);
            // Anchors are direct children of the ScrollView's content LinearLayout,
            // so getTop() is the absolute scroll offset of that section.
            if (anchor.getTop() > currentY + 8) {
                scroll.smoothScrollTo(0, anchor.getTop());
                return;
            }
        }
        scroll.smoothScrollTo(0, 0);
    }

    /**
     * Wraps the first occurrence of {@code linkText} inside the TextView's text in a
     * ClickableSpan, turning that portion into a real, screen-reader-visible link
     * whose accessible name is exactly {@code linkText}.
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
