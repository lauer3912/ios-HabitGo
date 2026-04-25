import SwiftUI

struct WeeklyReviewView: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Week Overview Card
                    weekOverviewCard

                    // Completion Ring
                    completionRingCard

                    // Insights
                    insightsCard

                    // Best & Most Improved
                    bestAndImprovedCard

                    // Day by Day Breakdown
                    dayByDayCard
                }
                .padding()
            }
            .navigationTitle("Weekly Review")
            .background(colorScheme == .dark ? Color.black : Color(hex: "F8F9FA"))
        }
    }

    private var weekOverviewCard: some View {
        VStack(spacing: 16) {
            Text(reviewWeekLabel)
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .primary)

            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text("\(weeklyStats.completions)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(hex: "34C759"))
                    Text("Completions")
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "6C757D"))
                }

                VStack(spacing: 4) {
                    Text("\(weeklyStats.target)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                    Text("Target")
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "6C757D"))
                }

                VStack(spacing: 4) {
                    Text("\(Int(weeklyStats.rate * 100))%")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(hex: "007AFF"))
                    Text("Rate")
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "6C757D"))
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? Color(hex: "141414") : Color.white)
        .cornerRadius(16)
    }

    private var completionRingCard: some View {
        VStack(spacing: 16) {
            Text("Weekly Progress")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .primary)

            ZStack {
                Circle()
                    .stroke(colorScheme == .dark ? Color(hex: "1E1E1E") : Color(hex: "E9ECEF"), lineWidth: 20)
                    .frame(width: 150, height: 150)

                Circle()
                    .trim(from: 0, to: weeklyStats.rate)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "34C759"), Color(hex: "2DA44E")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(Int(weeklyStats.rate * 100))%")
                        .font(.title.bold())
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "6C757D"))
                }
            }

            // Streak Info
            HStack(spacing: 24) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(overallStreak) day streak")
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                }

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(achievementsUnlocked) badges")
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? Color(hex: "141414") : Color.white)
        .cornerRadius(16)
    }

    private var insightsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Insights")
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
            }

            ForEach(insights, id: \.self) { insight in
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "34C759"))
                        .font(.caption)

                    Text(insight)
                        .font(.subheadline)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "6C757D"))
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorScheme == .dark ? Color(hex: "141414") : Color.white)
        .cornerRadius(16)
    }

    private var bestAndImprovedCard: some View {
        HStack(spacing: 16) {
            // Best Habit
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                    Text("Best Habit")
                        .font(.caption.bold())
                        .foregroundColor(colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "6C757D"))
                }

                if let best = bestHabit {
                    Image(systemName: best.icon)
                        .font(.title2)
                    Text(best.name)
                        .font(.subheadline.bold())
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                    Text("\(best.currentStreak) day streak")
                        .font(.caption)
                        .foregroundColor(.orange)
                } else {
                    Text("N/A")
                        .font(.subheadline)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "6C757D"))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(colorScheme == .dark ? Color(hex: "141414") : Color.white)
            .cornerRadius(12)

            // Most Active
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "arrow.up.right.circle.fill")
                        .foregroundColor(Color(hex: "34C759"))
                    Text("Most Active")
                        .font(.caption.bold())
                        .foregroundColor(colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "6C757D"))
                }

                if let active = mostActiveHabit {
                    Image(systemName: active.icon)
                        .font(.title2)
                    Text(active.name)
                        .font(.subheadline.bold())
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                    Text("\(active.totalCompletions) total")
                        .font(.caption)
                        .foregroundColor(Color(hex: "34C759"))
                } else {
                    Text("N/A")
                        .font(.subheadline)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "6C757D"))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(colorScheme == .dark ? Color(hex: "141414") : Color.white)
            .cornerRadius(12)
        }
    }

    private var dayByDayCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Day by Day")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .primary)

            ForEach(dayBreakdown, id: \.day) { day in
                HStack {
                    Text(day.day)
                        .font(.subheadline)
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                        .frame(width: 60, alignment: .leading)

                    Text("\(day.completed)/\(day.total)")
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "6C757D"))

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(colorScheme == .dark ? Color(hex: "1E1E1E") : Color(hex: "E9ECEF"))

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "34C759"))
                                .frame(width: geo.size.width * day.rate)
                        }
                    }
                    .frame(height: 8)

                    Text("\(Int(day.rate * 100))%")
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "6C757D"))
                        .frame(width: 40, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color(hex: "141414") : Color.white)
        .cornerRadius(16)
    }

    private var reviewWeekLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let weekStart = WeeklyGoal.weekStart()
        let weekEnd = Calendar.current.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
        return "\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd))"
    }

    private var weeklyStats: (completions: Int, target: Int, rate: Double) {
        let weekStart = WeeklyGoal.weekStart()
        let calendar = Calendar.current

        var completions = 0
        var target = 0

        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else { continue }
            let key = Habit.dayKey(from: date)

            for habit in habitVM.habits {
                if habit.frequency.shouldCompleteToday {
                    target += 1
                    if habit.completions[key] == true {
                        completions += 1
                    }
                }
            }
        }

        let rate = target > 0 ? Double(completions) / Double(target) : 0
        return (completions, target, rate)
    }

    private var overallStreak: Int {
        habitVM.habits.map { $0.currentStreak }.max() ?? 0
    }

    private var achievementsUnlocked: Int {
        habitVM.achievements.filter { $0.isUnlocked }.count
    }

    private var insights: [String] {
        var result: [String] = []

        if weeklyStats.rate >= 0.8 {
            result.append("Excellent week! You maintained high consistency.")
        } else if weeklyStats.rate >= 0.5 {
            result.append("Good progress! Try to complete more habits in the evenings.")
        }

        if let best = bestHabit, best.currentStreak >= 7 {
            result.append("\(best.name) is on fire with a \(best.currentStreak)-day streak!")
        }

        let morningHabits = habitVM.habits.filter { $0.reminderHour ?? 0 < 12 }
        if !morningHabits.isEmpty {
            result.append("You have \(morningHabits.count) morning habits - keep the momentum!")
        }

        return result
    }

    private var bestHabit: Habit? {
        habitVM.habits.max(by: { $0.currentStreak < $1.currentStreak })
    }

    private var mostActiveHabit: Habit? {
        habitVM.habits.max(by: { $0.totalCompletions < $1.totalCompletions })
    }

    private var dayBreakdown: [(day: String, completed: Int, total: Int, rate: Double)] {
        let weekStart = WeeklyGoal.weekStart()
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"

        return (0..<7).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else { return nil }
            let key = Habit.dayKey(from: date)
            let dayName = formatter.string(from: date)

            var completed = 0
            var total = 0

            for habit in habitVM.habits {
                if habit.frequency.shouldCompleteToday {
                    total += 1
                    if habit.completions[key] == true {
                        completed += 1
                    }
                }
            }

            let rate = total > 0 ? Double(completed) / Double(total) : 0
            return (dayName, completed, total, rate)
        }
    }
}

#Preview {
    WeeklyReviewView()
        .environmentObject(HabitViewModel())
}