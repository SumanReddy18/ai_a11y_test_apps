package com.browserstack.a11ydemo;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ScrollView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;

public abstract class BaseChildActivity extends AppCompatActivity {

    // Most rule screens are 2–3 viewports tall, and the scan captures the viewport without
    // scrolling — so anything below the fold was never looked at. (That is why the "Input type
    // for input fields" violations, which sit at ~960dp on the input screen, were rarely
    // reported while the label violations at the top always were.) So every scrollable rule
    // screen walks itself down on a loop, the same trick AllViolationsActivity uses for its
    // sections. It loops because the scan starts well after launch; any full cycle covers the
    // whole screen.
    private static final long AUTOSCROLL_INITIAL_DELAY_MS = 5000;   // settle before the first hop
    private static final long AUTOSCROLL_STEP_DELAY_MS = 9000;      // dwell per viewport
    private static final double AUTOSCROLL_PAGE_FRACTION = 0.85;    // overlap, so nothing straddles

    private final Handler autoScrollHandler = new Handler(Looper.getMainLooper());

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ActionBar bar = getSupportActionBar();
        if (bar != null) {
            boolean showUp = !isTaskRoot();
            bar.setDisplayHomeAsUpEnabled(showUp);
            bar.setDisplayShowHomeEnabled(showUp);
        }
    }

    /** AllViolationsActivity scrolls itself by section anchor, so it opts out of the paging loop. */
    protected boolean autoScrollsContent() {
        return true;
    }

    // Fires once the subclass calls setContentView, which is where the ScrollView appears.
    @Override
    public void onContentChanged() {
        super.onContentChanged();
        if (!autoScrollsContent()) {
            return;
        }
        ScrollView scroll = findScrollView(findViewById(android.R.id.content));
        if (scroll != null) {
            startAutoScroll(scroll);
        }
    }

    @Override
    protected void onDestroy() {
        autoScrollHandler.removeCallbacksAndMessages(null);
        super.onDestroy();
    }

    @Override
    public boolean onSupportNavigateUp() {
        finish();
        return true;
    }

    private void startAutoScroll(final ScrollView scroll) {
        autoScrollHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                View content = scroll.getChildAt(0);
                if (content != null) {
                    int page = (int) (scroll.getHeight() * AUTOSCROLL_PAGE_FRACTION);
                    int max = Math.max(0, content.getHeight() - scroll.getHeight());
                    int next = scroll.getScrollY() + page;
                    scroll.smoothScrollTo(0, next > max ? 0 : next);  // wrap to the top
                }
                autoScrollHandler.postDelayed(this, AUTOSCROLL_STEP_DELAY_MS);
            }
        }, AUTOSCROLL_INITIAL_DELAY_MS);
    }

    @Nullable
    private static ScrollView findScrollView(View root) {
        if (root instanceof ScrollView) {
            return (ScrollView) root;
        }
        if (root instanceof ViewGroup) {
            ViewGroup group = (ViewGroup) root;
            for (int i = 0; i < group.getChildCount(); i++) {
                ScrollView found = findScrollView(group.getChildAt(i));
                if (found != null) {
                    return found;
                }
            }
        }
        return null;
    }
}
