package com.browserstack.a11ydemo;

import android.content.Intent;
import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        wire(R.id.btn1, ImageWithTextActivity.class);
        wire(R.id.btn2, ImageViewLabelActivity.class);
        wire(R.id.btn3, InteractiveLabelActivity.class);
        wire(R.id.btn4, ReadingOrderActivity.class);
        wire(R.id.btn5, VisualOrderActivity.class);
        wire(R.id.btn6, MissingHeadingActivity.class);
        wire(R.id.btn7, IncorrectHeadingActivity.class);

        wire(R.id.btnAll, AllViolationsActivity.class);

        wire(R.id.num1, ImageWithTextActivity.class);
        wire(R.id.num2, ImageViewLabelActivity.class);
        wire(R.id.num3, InteractiveLabelActivity.class);
        wire(R.id.num4, ReadingOrderActivity.class);
        wire(R.id.num5, VisualOrderActivity.class);
        wire(R.id.num6, MissingHeadingActivity.class);
        wire(R.id.num7, IncorrectHeadingActivity.class);
    }

    private void wire(int id, Class<?> target) {
        findViewById(id).setOnClickListener(v ->
            startActivity(new Intent(this, target)));
    }
}
