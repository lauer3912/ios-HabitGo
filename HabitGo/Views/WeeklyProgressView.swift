import SwiftUI
import Charts

struct WeeklyProgressView: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // This week overview
                    weekOverviewCard

                    // Weekly goals per habit
                    if !habitVM.habitsWithGoals.isEmpty {
                        habitsGoalsSection
                    }

                    // Last 4 weeks trend
                    trendSection
                }
                .padding()
            }
            .navigationTitle("Weekly Goals")
            .background(colorScheme == .dark ? ThemeManager.AppColors.darkBackground : ThemeManager.AppColors.lightBackground)
        }
    }

    private var weekOverviewCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("This Week")
                        .font(.headline)
                    Text(weekDateRange)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(habitVM.completedThisWeek)/\(habitVM.totalThisWeek)")
                        .font(.title.bold())
                        .foregroundStyle(ThemeManager.AppColors.primary)
                    Text("completions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            ProgressView(value: habitVM.weeklyProgress)
                .tint(ThemeManager.AppColors.primary)
                .scaleEffect(y: 1.5)
        }
        .padding()
        .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var habitsGoalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Habit Goals")
                .font(.headline)

            ForEach(habitVM.habitsWithGoals) { habit in
                WeeklyGoalRow(habit: habit, goal: habitVM.weeklyGoal(for: habit))
            }
        }
    }

    private var trendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("4-Week Trend")
                .font(.headline)

            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(habitVM.weeklyTrendData) { item in
                        BarMark(
                            x: .value("Week", item.weekLabel),
                            y: .value("Completions", item.completions)
                        )
                        .foregroundStyle(ThemeManager.AppColors.primary.gradient)
                    }
                }
                .frame(height: 200)
                .padding()
                .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                // Fallback for older iOS
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(habitVM.weeklyTrendData) { item in
                        VStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: 4)
                                .fill(ThemeManager.AppColors.primary)
                                .frame(height: CGFloat(item.completions) * 5)
                            Text(item.weekLabel)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 200)
                .padding()
                .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private var weekDateRange: String {
        let start = WeeklyGoal.weekStart()
        let end = Calendar.current.date(byAdding: .day, value: 6, to: start)!
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}

struct WeeklyGoalRow: View {
    let habit: Habit
    let goal: WeeklyGoal?
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: habit.colorHex).opacity(0.15))
                    .frame(width: 40, height: 40)
                Text(habit.icon)
                    .font(.body)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.subheadline.bold())
                HStack {
                    Text("\(goal?.actualCompletions ?? 0)/\(habit.weeklyGoalTarget ?? 7) this week")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if goal?.isCompleted == true {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(ThemeManager.AppColors.primary)
                    }
                }
            }

            Spacer()

            CircularProgress(progress: goal?.progress ?? 0, color: Color(hex: habit.colorHex))
                .frame(width: 44, height: 44)
        }
        .padding()
        .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CircularProgress: View {
    let progress: Double
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 4)
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .font(.caption2.bold())
                .foregroundStyle(color)
        }
    }
}

// MARK: - WeeklyTrendData
struct WeeklyTrendData: Identifiable {
    let id = UUID()
    let weekLabel: String
    let completions: Int
}
