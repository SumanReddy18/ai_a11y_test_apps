package com.browserstack.a11ydemo;

import android.os.Bundle;

/**
 * "All violations (small)": all 9 rules jam-packed into two viewports of ONE activity.
 * BaseChildActivity's auto-scroll pages between the two viewports on a loop — the same
 * single-window model as AllViolationsActivity, which is the shape where the focus-order
 * capture (and therefore meaningful-reading-order) provably works. Do NOT split this
 * back into auto-advancing activities: recreating the window every N seconds serves
 * scans a stale TalkBack traversal cache and starves MRO (see activity_smallapp.xml).
 */
public class SmallAppActivity extends BaseChildActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_smallapp);

        LinkTextPurposeActivity.linkifyWholeText(findViewById(R.id.tsLinkClickHere));
        LinkTextPurposeActivity.linkifyWholeText(findViewById(R.id.tsLinkReadMore));
        LinkTextPurposeActivity.linkifyWholeText(findViewById(R.id.tsLinkRawUrl));
    }
}
