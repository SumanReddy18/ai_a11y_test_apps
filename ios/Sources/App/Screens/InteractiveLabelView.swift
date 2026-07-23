import SwiftUI

/// Rule 3 — Interactive element accessibility label.
///
/// Buttons, toggles, and text fields whose accessible names are missing, generic,
/// contextually wrong, or empty. Mirrors activity_interactive_label.xml (iOS has no
/// native checkbox, so the Android Switch + Checkbox groups both map to Toggle here).
struct InteractiveLabelView: View {
    @State private var toggleMissing = false
    @State private var toggleGeneric = false
    @State private var checkMissing  = false
    @State private var checkGeneric  = false
    @State private var editMissing   = ""
    @State private var editEmail     = ""

    private let columns = [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)]

    // SF Symbol | (bad) label — nil = missing entirely
    private let iconButtons: [(symbol: String, label: String?)] = [
        ("heart.fill",              nil),           // 1: missing
        ("square.and.arrow.up",     "button"),      // 2: generic
        ("trash.fill",              "share"),       // 3: contextually wrong
        ("exclamationmark.triangle","" ),           // 4: empty
        ("chevron.right",           "ic_chevron"),  // 5: filename
        ("person.circle",           "icon"),        // 6: generic
    ]

    var body: some View {
        RuleScreen(
            title: Rule.interactiveLabel.title,
            subtitle: Rule.interactiveLabel.desc,
            footer: "Every control above lacks a usable accessibility label. Buttons: missing, generic (\"button\", \"icon\"), filename, or contextually wrong. Toggles: no label or a generic one. Text fields: no label, and a visible caption not linked to the field. WCAG 1.3.1 / 2.4.6 / 4.1.2."
        ) {
            group("Interactable elements — icon buttons / tappable views") {
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(Array(iconButtons.enumerated()), id: \.offset) { _, b in
                        Button(action: {}) {
                            Image(systemName: b.symbol)
                                .resizable().scaledToFit().padding(22)
                                .frame(height: 84)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(Theme.textPrimary)
                                .background(Theme.card)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.cardBorder, lineWidth: 1))
                                .cornerRadius(8)
                        }
                        .modifier(MaybeLabel(label: b.label))
                    }

                    // 7 & 8: custom tappable coloured views with no label at all.
                    ForEach([Theme.brandPrimary, Theme.violationRed], id: \.self) { color in
                        color
                            .frame(height: 84)
                            .cornerRadius(8)
                            .onTapGesture {}
                            .accessibilityAddTraits(.isButton) // interactive, but no name
                    }
                }
            }

            group("Toggle elements") {
                Toggle("", isOn: $toggleMissing).labelsHidden()          // missing label
                Toggle("", isOn: $toggleGeneric).labelsHidden()
                    .accessibilityLabel("switch")                         // generic label
            }

            group("Checkbox-style toggles") {
                Toggle("", isOn: $checkMissing).labelsHidden()           // missing label
                Toggle("", isOn: $checkGeneric).labelsHidden()
                    .accessibilityLabel("checkbox")                       // generic label
            }

            group("Editable elements — text fields") {
                // No placeholder, no accessibility label → missing name.
                TextField("", text: $editMissing)
                    .textFieldStyle(.roundedBorder)

                // A visible "Email" caption that is NOT programmatically associated with
                // the field below it, so the field still has no accessible name.
                Text("Email")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.top, 8)
                TextField("", text: $editEmail)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
            }
        }
    }

    @ViewBuilder
    private func group<C: View>(_ heading: String, @ViewBuilder _ content: () -> C) -> some View {
        Text(heading)
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(Theme.textPrimary)
            .padding(.top, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        content()
    }
}

/// Applies an accessibility label only when one is provided (nil = leave the element unnamed).
private struct MaybeLabel: ViewModifier {
    let label: String?
    func body(content: Content) -> some View {
        if let label { content.accessibilityLabel(Text(label)) } else { content }
    }
}
