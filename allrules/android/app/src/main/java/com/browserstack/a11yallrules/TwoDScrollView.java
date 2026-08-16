package com.browserstack.a11yallrules;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.FrameLayout;

/**
 * two-dimensional-scroll: reporting canScrollHorizontally AND canScrollVertically makes
 * the framework add all four ACTION_SCROLL_* accessibility actions to this one node,
 * which is exactly the rule's FAIL condition. (The class name contains "ScrollView" on
 * purpose — that exempts it from interactive-element-unsupported-type.)
 */
public class TwoDScrollView extends FrameLayout {

    public TwoDScrollView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    public boolean canScrollHorizontally(int direction) {
        return true;
    }

    @Override
    public boolean canScrollVertically(int direction) {
        return true;
    }
}
