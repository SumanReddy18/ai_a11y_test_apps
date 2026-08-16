package com.browserstack.a11yallrules;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.widget.ScrollView;

/**
 * Shared page mechanics: the scan captures only the visible viewport and never scrolls,
 * so each page scrolls itself down viewport-by-viewport, then advances to the next page
 * (P1 -> P2 -> P3 -> P1, forever). Plain android.app.Activity on purpose — AppCompat
 * would wrap widgets and change the class names the class-gated rules key off.
 */
public abstract class BasePageActivity extends Activity {

    private static final long INITIAL_DELAY_MS = 5000; // settle before the first hop
    private static final long DWELL_MS = 8000;         // per-viewport dwell
    private static final int HOPS = 3;                 // covers ~1.5 viewports + slack

    private final Handler handler = new Handler(Looper.getMainLooper());
    private int hop;

    private final Runnable step = new Runnable() {
        @Override
        public void run() {
            ScrollView pager = findViewById(R.id.pager);
            hop++;
            if (hop <= HOPS) {
                pager.smoothScrollBy(0, pager.getHeight());
                handler.postDelayed(this, DWELL_MS);
            } else {
                startActivity(new Intent(BasePageActivity.this, next()));
                overridePendingTransition(0, 0);
                finish();
            }
        }
    };

    protected abstract int layout();

    protected abstract Class<? extends Activity> next();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(layout());
    }

    @Override
    protected void onResume() {
        super.onResume();
        hop = 0;
        handler.postDelayed(step, INITIAL_DELAY_MS);
    }

    @Override
    protected void onPause() {
        super.onPause();
        handler.removeCallbacks(step);
    }
}
