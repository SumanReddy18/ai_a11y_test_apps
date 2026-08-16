package com.browserstack.a11yallrules;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;

/**
 * interactive-element-unsupported-type: an interactive element whose reported
 * accessibility class name lacks a valid android/androidx prefix.
 *
 * getAccessibilityClassName MUST be overridden: the default implementation reports the
 * base "android.view.View" (a valid prefix, so the rule passes — this is why the first
 * scan missed it). The violation exists only when the node exposes the custom class.
 */
public class FancyToggle extends View {

    public FancyToggle(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    public CharSequence getAccessibilityClassName() {
        return getClass().getName();
    }
}
