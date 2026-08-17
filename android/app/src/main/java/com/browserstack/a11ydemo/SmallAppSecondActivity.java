package com.browserstack.a11ydemo;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;

/**
 * "All violations (small)" fixture, screen 2 of 2: the order & input rules (meaningful
 * reading order, meaningful visual order, link text purpose, input field labels + input
 * type). Links are whole-text-spanned via {@link LinkTextPurposeActivity#linkifyWholeText}
 * so each phrase is the element's exact accessible name (see that class's doc for why).
 * After one full auto-scroll pass it loops back to {@link SmallAppFirstActivity}.
 */
public class SmallAppSecondActivity extends BaseChildActivity {

    private final Handler advanceHandler = new Handler(Looper.getMainLooper());

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_smallapp_second);

        LinkTextPurposeActivity.linkifyWholeText(findViewById(R.id.tsLinkClickHere));
        LinkTextPurposeActivity.linkifyWholeText(findViewById(R.id.tsLinkReadMore));
        LinkTextPurposeActivity.linkifyWholeText(findViewById(R.id.tsLinkRawUrl));

        advanceHandler.postDelayed(() -> {
            startActivity(new Intent(this, SmallAppFirstActivity.class));
            finish();
        }, SmallAppFirstActivity.ADVANCE_AFTER_MS);
    }

    @Override
    protected void onDestroy() {
        advanceHandler.removeCallbacksAndMessages(null);
        super.onDestroy();
    }
}
