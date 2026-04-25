import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(habitVM.allAchievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
                .padding()
            }
            .navigationTitle("Achievements")
            .background(colorScheme == .dark ? ThemeManager.AppColors.darkBackground : ThemeManager.AppColors.lightBackground)
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: achievement.colorHex).opacity(achievement.isUnlocked ? 0.2 : 0.1))
                    .frame(width: 64, height: 64)

                if achievement.isUnlocked {
                    Circle()
                        .fill(Color(hex: achievement.colorHex).opacity(0.3))
                        .frame(width: 64, height: 64)
                }

                Image(systemName: achievement.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(achievement.isUnlocked ? Color(hex: achievement.colorHex) : .secondary)
            }

            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(achievement.isUnlocked ? .primary : .secondary)
                    .multilineTextAlignment(.center)

                Text(achievement.description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }

            if !achievement.isUnlocked && achievement.progress > 0 {
                ProgressView(value: achievement.progress)
                    .tint(Color(hex: achievement.colorHex))
                    .frame(height: 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(achievement.isUnlocked ? 1.0 : 0.7)
    }
}
