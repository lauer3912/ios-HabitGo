import SwiftUI

struct CalendarHistoryView: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    @State private var selectedHabitId: UUID?

    init() {
        let now = Date()
        let calendar = Calendar.current
        _selectedYear = State(initialValue: calendar.component(.year, from: now))
        _selectedMonth = State(initialValue: calendar.component(.month, from: now))
    }

    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    private let monthNames = [
        "January","February","March","April","May","June",
        "July","August","September","October","November","December"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Habit filter
                if !habitVM.habits.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(
                                title: "All Habits",
                                isSelected: selectedHabitId == nil,
                                colorHex: "#34C759"
                            ) {
                                selectedHabitId = nil
                            }

                            ForEach(habitVM.habits) { habit in
                                FilterChip(
                                    title: "\(habit.icon) \(habit.name)",
                                    isSelected: selectedHabitId == habit.id,
                                    colorHex: habit.colorHex
                                ) {
                                    selectedHabitId = habit.id
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .background(Color(.systemBackground))
                }

                // Month navigation
                HStack {
                    Button {
                        changeMonth(-1)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.bold())
                            .foregroundStyle(Color(hex: "#34C759"))
                    }

                    Spacer()

                    Text("\(monthNames[selectedMonth - 1]) \(selectedYear)")
                        .font(.headline)

                    Spacer()

                    Button {
                        changeMonth(1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title3.bold())
                            .foregroundStyle(Color(hex: "#34C759"))
                    }
                    .disabled(isCurrentMonth)
                }
                .padding()

                // Calendar grid
                VStack(spacing: 4) {
                    // Weekday headers
                    HStack(spacing: 4) {
                        ForEach(weekdays, id: \.self) { day in
                            Text(day)
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }

                    // Days grid
                    let days = daysInMonth()
                    let firstWeekday = firstWeekdayOfMonth()

                    ForEach(0..<6, id: \.self) { week in
                        HStack(spacing: 4) {
                            ForEach(0..<7, id: \.self) { weekday in
                                let index = week * 7 + weekday
                                let dayNumber = index - firstWeekday + 1

                                if dayNumber >= 1 && dayNumber <= days {
                                    let dayKey = String(format: "%04d-%02d-%02d", selectedYear, selectedMonth, dayNumber)
                                    let isCompleted = isDayCompleted(dayKey)

                                    CalendarDayView(
                                        day: dayNumber,
                                        isCompleted: isCompleted,
                                        isToday: isToday(dayNumber)
                                    )
                                } else {
                                    Color.clear
                                        .frame(height: 44)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Legend
                HStack(spacing: 16) {
                    LegendItem(color: Color(hex: "#34C759"), label: "Completed")
                    LegendItem(color: Color(.systemGray5), label: "Missed")
                }
                .padding()

                // Monthly summary
                if let habitId = selectedHabitId, let habit = habitVM.habits.first(where: { $0.id == habitId }) {
                    monthlySummary(habit: habit)
                } else {
                    monthlySummaryAll()
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func monthlySummary(habit: Habit) -> some View {
        VStack(spacing: 8) {
            Divider()
            HStack {
                VStack(alignment: .leading) {
                    Text("\(habit.name)")
                        .font(.headline)
                    Text("\(monthNames[selectedMonth - 1]) \(selectedYear)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(habit.totalCompletions)")
                        .font(.title2.bold())
                        .foregroundStyle(Color(hex: habit.colorHex))
                    Text("total completions")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    private func monthlySummaryAll() -> some View {
        VStack(spacing: 8) {
            Divider()
            let completions = habitVM.completionsForMonth(year: selectedYear, month: selectedMonth)
            let completedDays = completions.count
            HStack {
                VStack(alignment: .leading) {
                    Text("All Habits")
                        .font(.headline)
                    Text("\(monthNames[selectedMonth - 1]) \(selectedYear)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(completedDays)")
                        .font(.title2.bold())
                        .foregroundStyle(Color(hex: "#34C759"))
                    Text("active days")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    private var isCurrentMonth: Bool {
        let now = Date()
        let calendar = Calendar.current
        return calendar.component(.year, from: now) == selectedYear &&
               calendar.component(.month, from: now) == selectedMonth
    }

    private func changeMonth(_ delta: Int) {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1
        if let date = Calendar.current.date(from: components) {
            let newDate = Calendar.current.date(byAdding: .month, value: delta, to: date)!
            let calendar = Calendar.current
            selectedYear = calendar.component(.year, from: newDate)
            selectedMonth = calendar.component(.month, from: newDate)
        }
    }

    private func daysInMonth() -> Int {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        if let date = Calendar.current.date(from: components) {
            return Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 30
        }
        return 30
    }

    private func firstWeekdayOfMonth() -> Int {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1
        if let date = Calendar.current.date(from: components) {
            let weekday = Calendar.current.component(.weekday, from: date)
            return weekday - 1  // 0-indexed (Sunday = 0)
        }
        return 0
    }

    private func isDayCompleted(_ dayKey: String) -> Bool {
        if let habitId = selectedHabitId {
            let completions = habitVM.habitCompletionForMonth(habitId: habitId, year: selectedYear, month: selectedMonth)
            return completions[dayKey] == true
        } else {
            let completions = habitVM.completionsForMonth(year: selectedYear, month: selectedMonth)
            return completions[dayKey] == true
        }
    }

    private func isToday(_ day: Int) -> Bool {
        let now = Date()
        let calendar = Calendar.current
        return calendar.component(.year, from: now) == selectedYear &&
               calendar.component(.month, from: now) == selectedMonth &&
               calendar.component(.day, from: now) == day
    }
}

struct CalendarDayView: View {
    let day: Int
    let isCompleted: Bool
    let isToday: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
                .frame(height: 44)

            if isCompleted {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "#34C759").opacity(0.8))
                    .frame(height: 44)
                Text("\(day)")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
            } else {
                Text("\(day)")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }

            if isToday && !isCompleted {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color(hex: "#34C759"), lineWidth: 2)
                    .frame(height: 44)
            }
        }
    }

    private var backgroundColor: Color {
        if isCompleted {
            return Color.clear
        }
        return Color(.systemGray6)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let colorHex: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected
                        ? Color(hex: colorHex).opacity(0.2)
                        : Color(.systemGray6)
                )
                .foregroundStyle(
                    isSelected
                        ? Color(hex: colorHex)
                        : .secondary
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 14, height: 14)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
