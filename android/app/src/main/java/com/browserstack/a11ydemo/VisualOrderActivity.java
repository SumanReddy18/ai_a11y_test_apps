package com.browserstack.a11ydemo;

import android.os.Bundle;

public class VisualOrderActivity extends BaseChildActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_visual_order);
    }

    /**
     * Visual order is evaluated against ONE snapshot: the rule sorts every accessible, on-screen element by y then x. A screen that scrolls underneath
     * that capture reorders and drops elements from that sort, which is why the rule fired on some runs
     * and not others. This screen is sized to one viewport instead, so it can stay still.
     */
    @Override
    protected boolean autoScrollsContent() {
        return false;
    }
}
