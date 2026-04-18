import SwiftUI

struct AddHabitView: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedIcon = "checkmark"
    @State private var selectedColor = "#34C759"
    @State private var selectedFrequency: HabitFrequency = .daily

    private let iconOptions = [
        "checkmark", "book.fill", "dumbbell.fill", "drop.fill",
        "moon.fill", "figure.walk", "pencil", "heart.fill",
        "star.fill", "flame.fill", "leaf.fill", "brain.head.profile",
        "bed.double.fill", "cup.and.saucer.fill", "pill.fill", "bolt.fill"
    ]

    private let colorOptions = [
        "#34C759", "#007AFF", "#FF9500", "#FF3B30",
        "#AF52DE", "#5856D6", "#00C7BE", "#FF2D55"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Habit Name") {
                    TextField("e.g. Morning Exercise", text: $name)
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(selectedIcon == icon ? Color(hex: selectedColor).opacity(0.2) : Color.clear)
                                        .frame(width: 36, height: 36)
                                    Text(icon)
                                        .font(.title3)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                        ForEach(colorOptions, id: \.self) { color in
                            Button {
                                selectedColor = color
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: color))
                                        .frame(width: 32, height: 32)
                                    if selectedColor == color {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Frequency") {
                    Picker("Repeat", selection: $selectedFrequency) {
                        ForEach(HabitFrequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    HStack {
                        Spacer()
                        previewCard
                        Spacer()
                    }
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        habitVM.addHabit(
                            name: name,
                            icon: selectedIcon,
                            colorHex: selectedColor,
                            frequency: selectedFrequency
                        )
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private var previewCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: selectedColor).opacity(0.15))
                    .frame(width: 48, height: 48)
                Text(selectedIcon)
                    .font(.title2)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(name.isEmpty ? "Habit Name" : name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(name.isEmpty ? .secondary : .primary)
                Text(selectedFrequency.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Circle()
                .strokeBorder(Color(hex: selectedColor), lineWidth: 2)
                .frame(width: 32, height: 32)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}
