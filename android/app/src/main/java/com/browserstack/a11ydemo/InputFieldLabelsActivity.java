package com.browserstack.a11ydemo;

import android.os.Bundle;

/**
 * Input field labels — covers BOTH input-purpose rules on one screen:
 *
 *   1. "Accessible input field labels" — inputs with no programmatic label
 *      (caption not linked via android:labelFor, no hint, no contentDescription),
 *      inputs with no label at all, and placeholder-only inputs whose hint
 *      disappears as soon as the user types.
 *   2. "Input type for input fields" — properly labelled inputs whose
 *      android:inputType contradicts the label, plus password / CVV fields
 *      that use a plain-text input type instead of a secure one.
 *
 * Everything is declarative, so there is nothing to wire up here: the violation
 * lives in the accessibility attributes of activity_input_field_labels.xml.
 */
public class InputFieldLabelsActivity extends BaseChildActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_input_field_labels);
    }
}
