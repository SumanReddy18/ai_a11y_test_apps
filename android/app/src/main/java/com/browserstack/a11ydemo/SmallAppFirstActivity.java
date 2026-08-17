package com.browserstack.a11ydemo;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;

/**
 * "All violations (small)" fixture, screen 1 of 2: the visual & label rules (images with
 * text, imageview label, interactive label, missing heading, incorrect heading) jam-packed
 * into ~1.5 viewports. No manual navigation: after one full auto-scroll pass (inherited
 * from BaseChildActivity) the activity advances to {@link SmallAppSecondActivity} on its
 * own, and the pair cycles forever — the scan just watches.
 */
public class SmallAppFirstActivity extends BaseChildActivity {

    /** Settle (5s) + two auto-scroll hops (2x9s) + margin: one full pass of a 1.5-viewport page. */
    static final long ADVANCE_AFTER_MS = 30_000;

    private final Handler advanceHandler = new Handler(Looper.getMainLooper());

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_smallapp_first);
        advanceHandler.postDelayed(() -> {
            startActivity(new Intent(this, SmallAppSecondActivity.class));
            finish();
        }, ADVANCE_AFTER_MS);
    }

    @Override
    protected void onDestroy() {
        advanceHandler.removeCallbacksAndMessages(null);
        super.onDestroy();
    }
}
