package com.browserstack.a11yallrules;

import android.content.Context;
import android.util.AttributeSet;
import android.view.accessibility.AccessibilityNodeInfo;
import android.widget.FrameLayout;

/**
 * two-dimensional-scroll: one node whose actionList carries BOTH a horizontal and a
 * vertical scroll action — the rule's exact FAIL condition.
 *
 * canScrollHorizontally/Vertically overrides are NOT enough: a plain FrameLayout never
 * vends directional scroll actions from them (that's why the first scan missed this).
 * The actions must be added to the node info explicitly. (The class name contains
 * "ScrollView" on purpose — that exempts it from interactive-element-unsupported-type.)
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

    @Override
    public void onInitializeAccessibilityNodeInfo(AccessibilityNodeInfo info) {
        super.onInitializeAccessibilityNodeInfo(info);
        info.setScrollable(true);
        info.addAction(AccessibilityNodeInfo.AccessibilityAction.ACTION_SCROLL_UP);
        info.addAction(AccessibilityNodeInfo.AccessibilityAction.ACTION_SCROLL_DOWN);
        info.addAction(AccessibilityNodeInfo.AccessibilityAction.ACTION_SCROLL_LEFT);
        info.addAction(AccessibilityNodeInfo.AccessibilityAction.ACTION_SCROLL_RIGHT);
        info.addAction(AccessibilityNodeInfo.AccessibilityAction.ACTION_SCROLL_FORWARD);
        info.addAction(AccessibilityNodeInfo.AccessibilityAction.ACTION_SCROLL_BACKWARD);
    }
}
