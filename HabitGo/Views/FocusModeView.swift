import SwiftUI

struct FocusModeView: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var focusEnabled = false
    @State private var startHour = 22
    @State private var startMinute = 0
    @State private var endHour = 7
    @State private var endMinute = 0
    @State private var selectedDays: Set<Int> = [2, 3, 4, 5, 6] // Mon-Fri default

    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private let hours = Array(0..<24)
    private let minutes = [0, 15, 30, 45]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Enable Focus Mode", isOn: $focusEnabled)
                        .tint(ThemeManager.AppColors.primary)
                } footer: {
                    Text("When enabled, all habit reminders will be silenced during focus hours.")
                }

                if focusEnabled {
                    Section("Focus Period") {
                        HStack {
                            Text("Start")
                            Spacer()
                            timePicker(hour: $startHour, minute: $startMinute)
                        }

                        HStack {
                            Text("End")
                            Spacer()
                            timePicker(hour: $endHour, minute: $endMinute)
                        }
                    }

                    Section("Active Days") {
                        HStack(spacing: 8) {
                            ForEach(0..<7, id: \.self) { day in
                                let dayIndex = day + 1 // weekday is 1-indexed
                                Button {
                                    if selectedDays.contains(dayIndex) {
                                        selectedDays.remove(dayIndex)
                                    } else {
                                        selectedDays.insert(dayIndex)
                                    }
                                } label: {
                                    Text(weekdays[day])
                                        .font(.caption.bold())
                                        .frame(width: 36, height: 36)
                                        .background(
                                            selectedDays.contains(dayIndex)
                                                ? ThemeManager.AppColors.primary
                                                : (colorScheme == .dark ? ThemeManager.AppColors.darkTertiaryBG : ThemeManager.AppColors.lightTertiaryBG)
                                        )
                                        .foregroundStyle(selectedDays.contains(dayIndex) ? .white : .primary)
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Section {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Focus Schedule")
                                    .font(.subheadline.bold())
                                Text("\(formatHour(startHour):\(formatMinute(startMinute))) - \(formatHour(endHour)):\(formatMinute(endMinute))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(selectedDays.count) days active")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "moon.stars.fill")
                                .font(.title)
                                .foregroundStyle(.purple)
                        }
                    } header: {
                        Text("Preview")
                    }
                }
            }
            .navigationTitle("Focus Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        habitVM.setFocusMode(
                            enabled: focusEnabled,
                            startHour: startHour,
                            startMinute: startMinute,
                            endHour: endHour,
                            endMinute: endMinute,
                            days: selectedDays
                        )
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadFocusModeSettings()
            }
            .background(colorScheme == .dark ? ThemeManager.AppColors.darkBackground : ThemeManager.AppColors.lightBackground)
        }
    }

    private func timePicker(hour: Binding<Int>, minute: Binding<Int>) -> some View {
        HStack(spacing: 4) {
            Picker("Hour", selection: hour) {
                ForEach(hours, id: \.self) { h in
                    Text(String(format: "%02d", h)).tag(h)
                }
            }
            .frame(width: 70)
            Text(":")
            Picker("Minute", selection: minute) {
                ForEach(minutes, id: \.self) { m in
                    Text(String(format: "%02d", m)).tag(m)
                }
            }
            .frame(width: 70)
        }
    }

    private func formatHour(_ h: Int) -> String { String(format: "%02d", h) }
    private func formatMinute(_ m: Int) -> String { String(format: "%02d", m) }

    private func loadFocusModeSettings() {
        let defaults = UserDefaults.standard
        focusEnabled = defaults.bool(forKey: "HabitArcFlow_focusEnabled")
        startHour = defaults.integer(forKey: "HabitArcFlow_focusStartHour")
        startMinute = defaults.integer(forKey: "HabitArcFlow_focusStartMinute")
        endHour = defaults.integer(forKey: "HabitArcFlow_focusEndHour")
        endMinute = defaults.integer(forKey: "HabitArcFlow_focusEndMinute")
        if let daysData = defaults.array(forKey: "HabitArcFlow_focusDays") as? [Int] {
            selectedDays = Set(daysData)
        }
    }
}
