import SwiftUI
import Charts

struct HabitDetailView: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    let habit: Habit

    @State private var showNoteEditor = false
    @State private var selectedDate: Date = Date()
    @State private var noteForDate: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header stats
                    statsHeader

                    // Quick toggle
                    quickToggleCard

                    // Notes section
                    notesSection

                    // Monthly chart
                    if #available(iOS 16.0, *) {
                        monthlyChartSection
                    }

                    // Habit info
                    habitInfoSection
                }
                .padding()
            }
            .navigationTitle(habit.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .background(colorScheme == .dark ? ThemeManager.AppColors.darkBackground : ThemeManager.AppColors.lightBackground)
            .sheet(isPresented: $showNoteEditor) {
                NoteEditorView(habit: habit, dateKey: Habit.dayKey(from: selectedDate)) { note in
                    habitVM.addNote(note)
                }
            }
        }
    }

    private var statsHeader: some View {
        HStack(spacing: 16) {
            StatBox(title: "Current", value: "\(habit.currentStreak)", subtitle: "day streak", color: .orange)
            StatBox(title: "Best", value: "\(habit.longestStreak)", subtitle: "day record", color: ThemeManager.AppColors.primary)
            StatBox(title: "Total", value: "\(habit.totalCompletions)", subtitle: "completions", color: .blue)
        }
    }

    private var quickToggleCard: some View {
        Button {
            habitVM.toggleHabit(habit)
        } label: {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(hex: habit.colorHex).opacity(0.15))
                        .frame(width: 56, height: 56)
                    Image(systemName: habit.icon)
                        .font(.title)
                }

                VStack(alignment: .leading) {
                    Text(habit.isCompletedToday ? "Completed Today!" : "Mark as Done")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(habit.isCompletedToday ? "Tap to undo" : "Tap to complete")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if habit.isCompletedToday {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(ThemeManager.AppColors.primary)
                } else {
                    Circle()
                        .strokeBorder(Color(hex: habit.colorHex), lineWidth: 3)
                        .frame(width: 40, height: 40)
                }
            }
            .padding()
            .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Notes & Reflections")
                    .font(.headline)
                Spacer()
                Button {
                    selectedDate = Date()
                    showNoteEditor = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(ThemeManager.AppColors.primary)
                }
            }

            let notes = habitVM.notes(for: habit.id)
            if notes.isEmpty {
                Text("No notes yet. Tap + to add one.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(notes.prefix(5)) { note in
                    NoteRow(note: note)
                }
            }
        }
    }

    @available(iOS 16.0, *)
    private var monthlyChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Month")
                .font(.headline)

            let completions = habitVM.habitCompletionForMonth(habitId: habit.id, year: Calendar.current.component(.year, from: Date()), month: Calendar.current.component(.month, from: Date()))

            Chart {
                ForEach(monthDataPoints(completions: completions), id: \.day) { point in
                    BarMark(
                        x: .value("Day", point.day),
                        y: .value("Done", point.completed ? 1 : 0.3)
                    )
                    .foregroundStyle(point.completed ? Color(hex: habit.colorHex) : Color.gray.opacity(0.3))
                }
            }
            .frame(height: 120)
            .chartXAxis(.hidden)
            .padding()
            .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func monthDataPoints(completions: [String: Bool]) -> [(day: Int, completed: Bool)] {
        let calendar = Calendar.current
        let now = Date()
        let daysInMonth = calendar.range(of: .day, in: .month, for: now)?.count ?? 30
        let today = calendar.component(.day, from: now)
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)

        return (1...min(daysInMonth, today)).map { day in
            let key = String(format: "%04d-%02d-%02d", year, month, day)
            return (day, completions[key] == true)
        }
    }

    private var habitInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)

            VStack(spacing: 0) {
                InfoRow(label: "Frequency", value: habit.frequency.rawValue)
                Divider()
                InfoRow(label: "Created", value: formatDate(habit.createdAt))
                if let h = habit.reminderHour, let m = habit.reminderMinute {
                    Divider()
                    InfoRow(label: "Reminder", value: String(format: "%02d:%02d", h, m))
                }
                if let target = habit.weeklyGoalTarget {
                    Divider()
                    InfoRow(label: "Weekly Goal", value: "\(target) times")
                }
            }
            .padding()
            .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title.bold())
                .foregroundStyle(color)
            Text(title)
                .font(.caption.bold())
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct NoteRow: View {
    let note: HabitNote
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let mood = note.mood {
                Image(systemName: mood.icon)
                    .font(.title3)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(note.content)
                    .font(.subheadline)
                Text(formatDateKey(note.dateKey))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func formatDateKey(_ key: String) -> String {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return key }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        if let date = Calendar.current.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2])) {
            return formatter.string(from: date)
        }
        return key
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
        .font(.subheadline)
        .padding(.vertical, 4)
    }
}

struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let habit: Habit
    let dateKey: String
    let onSave: (HabitNote) -> Void

    @State private var content = ""
    @State private var selectedMood: Mood?

    var body: some View {
        NavigationStack {
            Form {
                Section("How did it go?") {
                    TextField("Write your reflection...", text: $content, axis: .vertical)
                        .lineLimit(4...8)
                }

                Section("Mood") {
                    HStack(spacing: 16) {
                        ForEach(Mood.allCases, id: \.self) { mood in
                            Button {
                                selectedMood = mood
                            } label: {
                                VStack {
                                    Image(systemName: mood.icon)
                                        .font(.title)
                                    Text(mood.rawValue.capitalized)
                                        .font(.caption2)
                                }
                                .foregroundStyle(selectedMood == mood ? Color(hex: mood.colorHex) : .secondary)
                                .padding(8)
                                .background(selectedMood == mood ? Color(hex: mood.colorHex).opacity(0.15) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let note = HabitNote(habitId: habit.id, dateKey: dateKey, content: content, mood: selectedMood)
                        onSave(note)
                        dismiss()
                    }
                    .disabled(content.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
