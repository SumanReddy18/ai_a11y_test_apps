package com.browserstack.a11yallrules;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;

/**
 * interactive-element-unsupported-type: an interactive class in the app's own package
 * that deliberately does NOT override getAccessibilityClassName, so the reported class
 * name lacks a valid android/androidx prefix.
 */
public class FancyToggle extends View {

    public FancyToggle(Context context, AttributeSet attrs) {
        super(context, attrs);
    }
}
