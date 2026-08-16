package com.browserstack.a11yallrules;

import android.app.Activity;

public class Page2Activity extends BasePageActivity {

    @Override
    protected int layout() {
        return R.layout.page2;
    }

    @Override
    protected Class<? extends Activity> next() {
        return Page3Activity.class;
    }
}
