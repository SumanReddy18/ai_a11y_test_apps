package com.browserstack.a11yallrules;

import android.app.Activity;
import android.os.Bundle;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.text.style.URLSpan;
import android.widget.TextView;

public class Page3Activity extends BasePageActivity {

    @Override
    protected int layout() {
        return R.layout.page3;
    }

    @Override
    protected Class<? extends Activity> next() {
        return Page1Activity.class;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // link-text-purpose: the URLSpan must cover the WHOLE text — the rule judges the
        // element's full speakable text, so the phrase alone must be the element, spanned
        // end-to-end, to be an exact stop-word match ("click here", "read more").
        linkify(R.id.link_click_here, "Click here", "https://example.com/policy");
        linkify(R.id.link_read_more, "Read more", "https://example.com/changelog");
    }

    private void linkify(int id, String phrase, String url) {
        TextView tv = findViewById(id);
        SpannableString s = new SpannableString(phrase);
        s.setSpan(new URLSpan(url), 0, phrase.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        tv.setText(s);
        tv.setMovementMethod(LinkMovementMethod.getInstance());
    }
}
