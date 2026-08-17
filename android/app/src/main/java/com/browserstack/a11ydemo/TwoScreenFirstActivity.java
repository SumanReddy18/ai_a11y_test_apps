package com.browserstack.a11ydemo;

import android.content.Intent;
import android.os.Bundle;

/**
 * Two-screen compact fixture, screen 1 of 2: the visual & label rules (images with text,
 * imageview label, interactive label, missing heading, incorrect heading) jam-packed into
 * ~1.5 viewports. The only non-violating element is the "Continue to page 2" button at the
 * bottom, which opens {@link TwoScreenSecondActivity} (order & input rules).
 */
public class TwoScreenFirstActivity extends BaseChildActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_two_screen_first);

        findViewById(R.id.continueToPage2).setOnClickListener(v ->
                startActivity(new Intent(this, TwoScreenSecondActivity.class)));
    }
}
