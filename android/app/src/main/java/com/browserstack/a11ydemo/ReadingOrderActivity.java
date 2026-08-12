package com.browserstack.a11ydemo;

import android.os.Bundle;

public class ReadingOrderActivity extends BaseChildActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_reading_order);
    }

    /**
     * Reading order is evaluated against ONE snapshot: the rule intersects the TalkBack focus
     * caption with elements that have non-zero bounds, then bails outright if the surviving uid
     * list contains a duplicate -- emitting no candidate at all. A screen that scrolls underneath
     * that capture drops elements from the intersection, which is why the rule fired on some runs
     * and not others. This screen is sized to one viewport instead, so it can stay still.
     */
    @Override
    protected boolean autoScrollsContent() {
        return false;
    }
}
