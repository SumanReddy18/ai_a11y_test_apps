package com.browserstack.a11yallrules;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;

/**
 * missing-view-type-in-spoken-output: clickable custom view with a label but no role —
 * TalkBack announces "Delete item" with no "Button"-like type word in the spoken output.
 */
public class TapArea extends View {

    public TapArea(Context context, AttributeSet attrs) {
        super(context, attrs);
    }
}
