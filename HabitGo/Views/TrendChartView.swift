import SwiftUI
import Charts

struct TrendChartView: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedHabitId: UUID?
    @State private var selectedPeriod: Period = .month

    enum Period: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }

    private var selectedHabit: Habit? {
        habitVM.habits.first { $0.id == selectedHabitId }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Habit selector
                    habitSelector

                    // Period selector
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(Period.allCases, id: \.self) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    if let habit = selectedHabit {
                        // Completion rate chart
                        completionRateChart(habit: habit)

                        // Streak history
                        streakHistory(habit: habit)

                        // Best performing day
                        bestDaySection(habit: habit)
                    } else {
                        // Overall stats when no habit selected
                        overallTrendChart
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Trends")
            .background(colorScheme == .dark ? ThemeManager.AppColors.darkBackground : ThemeManager.AppColors.lightBackground)
        }
    }

    private var habitSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    selectedHabitId = nil
                } label: {
                    Text("All Habits")
                        .font(.caption.bold())
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(selectedHabitId == nil ? ThemeManager.AppColors.primary : (colorScheme == .dark ? ThemeManager.AppColors.darkTertiaryBG : ThemeManager.AppColors.lightTertiaryBG))
                        .foregroundStyle(selectedHabitId == nil ? .white : .primary)
                        .clipShape(Capsule())
                }

                ForEach(habitVM.habits) { habit in
                    Button {
                        selectedHabitId = habit.id
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: habit.icon)
                            Text(habit.name)
                        }
                        .font(.caption.bold())
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(selectedHabitId == habit.id ? Color(hex: habit.colorHex) : (colorScheme == .dark ? ThemeManager.AppColors.darkTertiaryBG : ThemeManager.AppColors.lightTertiaryBG))
                        .foregroundStyle(selectedHabitId == habit.id ? .white : .primary)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    @available(iOS 16.0, *)
    private func completionRateChart(habit: Habit) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Completion Rate")
                .font(.headline)
                .padding(.horizontal)

            Chart {
                ForEach(chartData(for: habit), id: \.label) { item in
                    LineMark(
                        x: .value("Period", item.label),
                        y: .value("Rate", item.rate)
                    )
                    .foregroundStyle(Color(hex: habit.colorHex))
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Period", item.label),
                        y: .value("Rate", item.rate)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: habit.colorHex).opacity(0.3), Color(hex: habit.colorHex).opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
            }
            .frame(height: 200)
            .chartYScale(domain: 0...1)
            .chartYAxis {
                AxisMarks(values: [0, 0.5, 1]) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text("\(Int(v * 100))%")
                                .font(.caption2)
                        }
                    }
                }
            }
            .padding()
            .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }

    private func chartData(for habit: Habit) -> [(label: String, rate: Double)] {
        let calendar = Calendar.current
        let today = Date()
        var data: [(String, Double)] = []

        switch selectedPeriod {
        case .week:
            for i in (0..<7).reversed() {
                if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                    let key = Habit.dayKey(from: date)
                    let completed = habit.completions[key] == true
                    let weekday = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
                    data.append((weekday, completed ? 1.0 : 0.0))
                }
            }
        case .month:
            let daysInMonth = calendar.range(of: .day, in: .month, for: today)?.count ?? 30
            for i in (0..<min(daysInMonth, 30)).reversed() {
                if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                    let key = Habit.dayKey(from: date)
                    let completed = habit.completions[key] == true
                    let day = "\(calendar.component(.day, from: date))"
                    data.append((day, completed ? 1.0 : 0.0))
                }
            }
        case .year:
            for i in (0..<12).reversed() {
                if let date = calendar.date(byAdding: .month, value: -i, to: today) {
                    let month = calendar.shortMonthSymbols[calendar.component(.month, from: date) - 1]
                    let year = calendar.component(.year, from: date)
                    let monthCompletions = habit.completions.filter { key, val in
                        val && key.hasPrefix("\(year)-") && key.hasPrefix("-\(String(format: "%02d", calendar.component(.month, from: date)))-")
                    }.count
                    let total = habit.frequency == .daily ? 30 : 4
                    data.append((month, min(Double(monthCompletions) / Double(total), 1.0)))
                }
            }
        }
        return data
    }

    private var overallTrendChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overall Progress")
                .font(.headline)

            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(weeklyOverallData) { item in
                        BarMark(
                            x: .value("Week", item.week),
                            y: .value("Completions", item.total)
                        )
                        .foregroundStyle(ThemeManager.AppColors.primary.gradient)
                    }
                }
                .frame(height: 200)
                .padding()
                .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.horizontal)
    }

    private var weeklyOverallData: [WeeklyOverallData] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<8).reversed().compactMap { weekOffset in
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: today) else { return nil }
            let monday = WeeklyGoal.weekStart(for: weekStart)
            var total = 0
            for dayOffset in 0..<7 {
                if let day = calendar.date(byAdding: .day, value: dayOffset, to: monday) {
                    let key = Habit.dayKey(from: day)
                    total += habitVM.habits.filter { $0.completions[key] == true }.count
                }
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return WeeklyOverallData(week: formatter.string(from: monday), total: total)
        }
    }

    private func streakHistory(habit: Habit) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Streak History")
                .font(.headline)

            HStack(spacing: 16) {
                VStack {
                    Text("\(habit.currentStreak)")
                        .font(.title.bold())
                        .foregroundStyle(.orange)
                    Text("Current")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack {
                    Text("\(habit.longestStreak)")
                        .font(.title.bold())
                        .foregroundStyle(ThemeManager.AppColors.primary)
                    Text("Best")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack {
                    Text("\(habit.totalCompletions)")
                        .font(.title.bold())
                        .foregroundStyle(.blue)
                    Text("Total")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal)
    }

    private func bestDaySection(habit: Habit) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Best Performing Day")
                .font(.headline)

            let bestDay = findBestDay(for: habit)
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                Text("Most completions on **\(bestDay.name)** (\(bestDay.count) times)")
                    .font(.subheadline)
                Spacer()
            }
            .padding()
            .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
    }

    private func findBestDay(for habit: Habit) -> (name: String, count: Int) {
        let calendar = Calendar.current
        var dayCounts: [Int: Int] = [:]
        for key in habit.completions.keys where habit.completions[key] == true {
            if let date = Habit.dateFromKey(key) as Date? {
                let weekday = calendar.component(.weekday, from: date)
                dayCounts[weekday, default: 0] += 1
            }
        }
        let bestWeekday = dayCounts.max { $0.value < $1.value }?.key ?? 1
        let dayName = calendar.weekdaySymbols[bestWeekday - 1]
        return (dayName, dayCounts[bestWeekday] ?? 0)
    }
}

struct WeeklyOverallData: Identifiable {
    let id = UUID()
    let week: String
    let total: Int
}
