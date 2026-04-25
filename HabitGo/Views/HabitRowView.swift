import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let onToggle: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var showCelebration = false

    var body: some View {
        HStack(spacing: 16) {
            // Completion Button
            Button(action: {
                if !habit.isCompletedToday {
                    showCelebration = true
                }
                onToggle()
            }) {
                ZStack {
                    Circle()
                        .stroke(habit.isCompletedToday ? Color(hex: habit.colorHex) : colorScheme == .dark ? Color(hex: "38383A") : Color(hex: "E9ECEF"), lineWidth: 2)
                        .frame(width: 32, height: 32)

                    if habit.isCompletedToday {
                        Circle()
                            .fill(Color(hex: habit.colorHex))
                            .frame(width: 32, height: 32)

                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            // Habit Icon
            Image(systemName: habit.icon)
                .font(.title3)
                .foregroundColor(Color(hex: habit.colorHex))
                .frame(width: 36, height: 36)
                .background(Color(hex: habit.colorHex).opacity(0.15))
                .clipShape(Circle())

            // Habit Info
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.body)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)

                HStack(spacing: 8) {
                    // Streak
                    if habit.currentStreak > 0 {
                        HStack(spacing: 2) {
                            StreakFireView(streak: habit.currentStreak)
                            Text("\(habit.currentStreak)d")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }

                    // Energy Level
                    if let energy = habit.energyLevel {
                        HStack(spacing: 2) {
                            Image(systemName: energy.icon)
                                .font(.caption2)
                                .foregroundColor(Color(hex: energy.colorHex))
                            Text(energy.rawValue)
                                .font(.caption2)
                                .foregroundColor(colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "6C757D"))
                        }
                    }

                    // Frequency
                    Text(habit.frequency.rawValue)
                        .font(.caption2)
                        .foregroundColor(colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "6C757D"))
                }
            }

            Spacer()

            // Arrow for detail
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(colorScheme == .dark ? Color(hex: "38383A") : Color(hex: "E9ECEF"))
        }
        .padding(.vertical, 8)
        .overlay {
            if showCelebration {
                CelebrationView(
                    isPresented: $showCelebration,
                    habitName: habit.name,
                    streak: habit.currentStreak,
                    onComplete: {}
                )
            }
        }
    }
}

#Preview {
    VStack {
        HabitRowView(
            habit: Habit(name: "Morning Run", icon: "figure.run", colorHex: "#34C759", frequency: .daily),
            onToggle: {}
        )
    }
    .padding()
    .background(Color.black)
}