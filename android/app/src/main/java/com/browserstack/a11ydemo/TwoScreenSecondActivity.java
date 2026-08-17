package com.browserstack.a11ydemo;

import android.os.Bundle;

/**
 * Two-screen compact fixture, screen 2 of 2: the order & input rules (meaningful reading
 * order, meaningful visual order, link text purpose, input field labels + input type).
 * Links are whole-text-spanned via {@link LinkTextPurposeActivity#linkifyWholeText} so each
 * phrase is the element's exact accessible name (see that class's doc for why).
 */
public class TwoScreenSecondActivity extends BaseChildActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_two_screen_second);

        LinkTextPurposeActivity.linkifyWholeText(findViewById(R.id.tsLinkClickHere));
        LinkTextPurposeActivity.linkifyWholeText(findViewById(R.id.tsLinkReadMore));
        LinkTextPurposeActivity.linkifyWholeText(findViewById(R.id.tsLinkRawUrl));
    }
}
