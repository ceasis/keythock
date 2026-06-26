import SwiftUI

struct KeySoundsView: View {
    @EnvironmentObject private var model: AppModel
    @State private var selectedKey = KeyboardLayout.defaultSelectedKey

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HeaderView(title: "Keys", subtitle: "Assign a recorded sample to each physical key in the active sound pack.")

            Panel {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 12) {
                        Picker("Sound Pack", selection: Binding(
                            get: { model.settings.currentPackId },
                            set: { model.selectPack(model.packs.pack(with: $0)) }
                        )) {
                            ForEach(model.packs.allPacks) { pack in
                                Text(pack.name).tag(pack.id)
                            }
                        }
                        .frame(width: 260)

                        Spacer()

                        Button {
                            model.previewConfiguredKey(keyCode: selectedKey.keyCode, category: selectedKey.category)
                        } label: {
                            Label("Preview", systemImage: "play.fill")
                        }

                        Button {
                            model.shuffleAutomaticSamples()
                        } label: {
                            Label("Shuffle Auto", systemImage: "shuffle")
                        }
                        .disabled(model.settings.samplePlaybackMode != .stablePerKey)
                        .help("Shuffle automatic per-key sample choices")

                        Button {
                            model.clearConfiguredKey(keyCode: selectedKey.keyCode)
                        } label: {
                            Label("Clear Key", systemImage: "xmark.circle")
                        }

                        Button(role: .destructive) {
                            model.clearConfiguredKeysForCurrentPack()
                        } label: {
                            Label("Clear Pack", systemImage: "trash")
                        }
                    }

                    VStack(spacing: 6) {
                        ForEach(Array(KeyboardLayout.rows.enumerated()), id: \.offset) { _, row in
                            KeyboardRowView(
                                keys: row,
                                selectedKey: selectedKey,
                                assignmentText: assignmentText(for:),
                                isAssigned: isAssigned(_:),
                                action: selectAndAdvance(_:)
                            )
                        }
                    }

                    HStack(spacing: 10) {
                        Label(selectedKey.label, systemImage: "keyboard")
                            .font(.headline)
                        Text(statusText(for: selectedKey))
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(model.currentPack.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func selectAndAdvance(_ key: KeyboardKeyDefinition) {
        selectedKey = key
        model.cycleKeySample(keyCode: key.keyCode, category: key.category)
    }

    private func isAssigned(_ key: KeyboardKeyDefinition) -> Bool {
        model.assignedSampleIndex(keyCode: key.keyCode) != nil
    }

    private func assignmentText(for key: KeyboardKeyDefinition) -> String {
        guard let sampleIndex = model.assignedSampleIndex(keyCode: key.keyCode) else {
            switch model.settings.samplePlaybackMode {
            case .stablePerKey:
                guard let autoIndex = model.automaticSampleIndex(keyCode: key.keyCode, category: key.category) else {
                    return "Auto"
                }
                return "Auto S\(autoIndex + 1)"
            case .singleSample:
                return "S1"
            case .randomEveryPress:
                return "Rand"
            }
        }
        return "S\(sampleIndex + 1)"
    }

    private func statusText(for key: KeyboardKeyDefinition) -> String {
        let count = model.sampleCount(for: key.category)
        guard count > 0 else { return "No press samples in this pack" }
        guard let sampleIndex = model.assignedSampleIndex(keyCode: key.keyCode) else {
            switch model.settings.samplePlaybackMode {
            case .stablePerKey:
                guard let autoIndex = model.automaticSampleIndex(keyCode: key.keyCode, category: key.category) else {
                    return "Auto from \(count) samples"
                }
                return "Auto sample \(autoIndex + 1) of \(count)"
            case .singleSample:
                return "Single sample 1 of \(count)"
            case .randomEveryPress:
                return "Random across \(count) samples"
            }
        }
        return "Sample \(min(sampleIndex, count - 1) + 1) of \(count)"
    }
}

private struct KeyboardRowView: View {
    let keys: [KeyboardKeyDefinition]
    let selectedKey: KeyboardKeyDefinition
    let assignmentText: (KeyboardKeyDefinition) -> String
    let isAssigned: (KeyboardKeyDefinition) -> Bool
    let action: (KeyboardKeyDefinition) -> Void

    private let spacing: CGFloat = 6
    private let height: CGFloat = 46

    var body: some View {
        GeometryReader { geometry in
            let totalUnits = keys.reduce(CGFloat(0)) { $0 + $1.widthUnits }
            let availableWidth = max(0, geometry.size.width - spacing * CGFloat(max(0, keys.count - 1)))
            let unitWidth = max(24, availableWidth / max(totalUnits, 1))

            HStack(spacing: spacing) {
                ForEach(keys) { key in
                    KeyboardKeyButton(
                        key: key,
                        sampleText: assignmentText(key),
                        selected: key == selectedKey,
                        assigned: isAssigned(key),
                        action: { action(key) }
                    )
                    .frame(width: unitWidth * key.widthUnits, height: height)
                }
            }
        }
        .frame(height: height)
    }
}

private struct KeyboardKeyButton: View {
    let key: KeyboardKeyDefinition
    let sampleText: String
    let selected: Bool
    let assigned: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(key.label)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                Text(sampleText)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(background)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(borderColor, lineWidth: selected || assigned ? 1.5 : 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .help("\(key.label) \(sampleText)")
    }

    private var background: some ShapeStyle {
        selected ? Color.accentColor.opacity(0.22) : Color.secondary.opacity(0.10)
    }

    private var borderColor: Color {
        if selected { return .accentColor }
        if assigned { return .accentColor.opacity(0.6) }
        return .secondary.opacity(0.2)
    }
}

private struct KeyboardKeyDefinition: Identifiable, Equatable {
    let label: String
    let keyCode: Int
    let widthUnits: CGFloat

    var id: Int { keyCode }
    var category: KeyCategory { KeyClassifier.classify(keyCode: keyCode) }
}

private enum KeyboardLayout {
    static let defaultSelectedKey = key("A", 0)

    static let rows: [[KeyboardKeyDefinition]] = [
        [
            key("Esc", 53, 1.35), key("F1", 122), key("F2", 120), key("F3", 99), key("F4", 118),
            key("F5", 96), key("F6", 97), key("F7", 98), key("F8", 100), key("F9", 101),
            key("F10", 109), key("F11", 103), key("F12", 111)
        ],
        [
            key("`", 50), key("1", 18), key("2", 19), key("3", 20), key("4", 21), key("5", 23),
            key("6", 22), key("7", 26), key("8", 28), key("9", 25), key("0", 29), key("-", 27),
            key("=", 24), key("Del", 51, 1.8)
        ],
        [
            key("Tab", 48, 1.5), key("Q", 12), key("W", 13), key("E", 14), key("R", 15),
            key("T", 17), key("Y", 16), key("U", 32), key("I", 34), key("O", 31), key("P", 35),
            key("[", 33), key("]", 30), key("\\", 42, 1.5)
        ],
        [
            key("Caps", 57, 1.8), key("A", 0), key("S", 1), key("D", 2), key("F", 3),
            key("G", 5), key("H", 4), key("J", 38), key("K", 40), key("L", 37), key(";", 41),
            key("'", 39), key("Return", 36, 2.2)
        ],
        [
            key("Shift", 56, 2.3), key("Z", 6), key("X", 7), key("C", 8), key("V", 9),
            key("B", 11), key("N", 45), key("M", 46), key(",", 43), key(".", 47), key("/", 44),
            key("Shift", 60, 2.6)
        ],
        [
            key("Ctrl", 59, 1.25), key("Opt", 58, 1.25), key("Cmd", 55, 1.35),
            key("Space", 49, 6.0), key("Cmd", 54, 1.35), key("Opt", 61, 1.25),
            key("Left", 123, 1.15), key("Down", 125, 1.15), key("Up", 126, 1.15), key("Right", 124, 1.15)
        ]
    ]

    private static func key(_ label: String, _ keyCode: Int, _ widthUnits: CGFloat = 1) -> KeyboardKeyDefinition {
        KeyboardKeyDefinition(label: label, keyCode: keyCode, widthUnits: widthUnits)
    }
}
