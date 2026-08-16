package com.browserstack.a11yallrules;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

public class Page1Activity extends BasePageActivity {

    @Override
    protected int layout() {
        return R.layout.page1;
    }

    @Override
    protected Class<? extends Activity> next() {
        return Page2Activity.class;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // traversal-order-cycle: A before B and B before A — a 2-node traversal cycle
        // the on-device engine flags via traversalBeforeCycle/traversalAfterCycle.
        TextView a = findViewById(R.id.node_a);
        TextView b = findViewById(R.id.node_b);
        a.setAccessibilityTraversalBefore(R.id.node_b);
        b.setAccessibilityTraversalBefore(R.id.node_a);
    }
}
