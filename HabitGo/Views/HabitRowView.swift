import SwiftUI

struct HabitRowView: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Binding var habit: Habit
    let onToggle: () -> Void

    private var categoryName: String? {
        guard let catId = habit.categoryId else { return nil }
        return habitVM.categories.first { $0.id == catId }?.name
    }

    var body: some View {
        HStack(spacing: 14) {
            // Icon bubble
            ZStack {
                Circle()
                    .fill(Color(hex: habit.colorHex).opacity(0.15))
                    .frame(width: 48, height: 48)
                Text(habit.icon)
                    .font(.title2)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.body)
                    .fontWeight(.medium)

                HStack(spacing: 6) {
                    // Streak
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                        Text("\(habit.currentStreak)")
                            .font(.caption)
                    }
                    .foregroundStyle(habit.currentStreak > 0 ? .orange : .secondary)

                    // Frequency
                    Text(habit.frequency.rawValue)
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    // Category badge
                    if let cat = categoryName {
                        Text(cat)
                            .font(.caption2)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color(hex: habit.colorHex).opacity(0.15))
                            .foregroundStyle(Color(hex: habit.colorHex))
                            .clipShape(Capsule())
                    }

                    // Reminder time
                    if habit.reminderEnabled, let h = habit.reminderHour, let m = habit.reminderMinute {
                        HStack(spacing: 2) {
                            Image(systemName: "bell.fill")
                                .font(.caption2)
                            Text(String(format: "%02d:%02d", h, m))
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Weekly goal indicator
            if let target = habit.weeklyGoalTarget {
                let goal = habitVM.weeklyGoal(for: habit)
                let progress = goal?.progress ?? 0
                VStack {
                    CircularProgress(progress: progress, color: Color(hex: habit.colorHex))
                        .frame(width: 32, height: 32)
                }
            }

            // Toggle button
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .strokeBorder(Color(hex: habit.colorHex), lineWidth: 2)
                        .frame(width: 32, height: 32)

                    if habit.isCompletedToday {
                        Circle()
                            .fill(Color(hex: habit.colorHex))
                            .frame(width: 32, height: 32)
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
