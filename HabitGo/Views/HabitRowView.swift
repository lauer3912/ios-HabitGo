import SwiftUI

struct HabitRowView: View {
    @Binding var habit: Habit
    let onToggle: () -> Void

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

                HStack(spacing: 8) {
                    Label("\(habit.currentStreak)", systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(habit.currentStreak > 0 ? .orange : .secondary)

                    Text(habit.frequency.rawValue)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

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
