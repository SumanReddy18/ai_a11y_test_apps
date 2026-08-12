package com.browserstack.a11ydemo;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.widget.Button;
import android.widget.ScrollView;
import android.widget.TextView;

public class AllViolationsActivity extends BaseChildActivity {

    // Section anchors, top-to-bottom: rule 1's grid, then the 1dp divider that opens each
    // later rule. They deliberately sit on containers/dividers rather than on a heading
    // TextView — this screen carries no chrome, so nothing but violations is in the
    // accessibility tree. The "Next ↓" button jumps to the next one below the current
    // scroll position.
    private static final int[] SECTION_ANCHORS = {
            R.id.sec1, R.id.sec2, R.id.sec3, R.id.sec4,
            R.id.sec5, R.id.sec6, R.id.sec7, R.id.sec8,
            R.id.sec9
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

    // This screen walks its own section anchors, so the base class's viewport paging stays off.
    @Override
    protected boolean autoScrollsContent() {
        return false;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_all_violations);

        final ScrollView scroll = findViewById(R.id.allScroll);
        Button next = findViewById(R.id.btnNextViolation);
        next.setOnClickListener(v -> scrollToNextSection(scroll));
        startAutoScroll(scroll);

        // Rule 8 — Link text purpose. Each phrase is its own TextView, spanned end-to-end, so
        // the element's speakable text IS the vague phrase (see LinkTextPurposeActivity for why
        // spanning a substring of a sentence made this rule silently pass).
        for (int id : new int[] {
                R.id.av_linkClickHere, R.id.av_linkReadMore, R.id.av_linkHere,
                R.id.av_linkLearnMore1, R.id.av_linkLearnMore2, R.id.av_linkLearnMore3,
                R.id.av_linkRawUrl,
                R.id.av_linkTapHere, R.id.av_linkThis, R.id.av_linkMore }) {
            LinkTextPurposeActivity.linkifyWholeText((TextView) findViewById(id));
        }
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

}
