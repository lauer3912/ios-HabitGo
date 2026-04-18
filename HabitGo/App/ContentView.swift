import SwiftUI

struct ContentView: View {
    @EnvironmentObject var habitVM: HabitViewModel

    var body: some View {
        TabView {
            HabitListView()
                .tabItem {
                    Label("Habits", systemImage: "checkmark.circle.fill")
                }

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Color(hex: "#34C759"))
    }
}

// MARK: - Stats View

struct StatsView: View {
    @EnvironmentObject var habitVM: HabitViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Today") {
                    HStack {
                        Text("Completed")
                        Spacer()
                        Text("\(habitVM.completedToday) / \(habitVM.totalToday)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Progress")
                        Spacer()
                        Text("\(Int(habitVM.todayProgress * 100))%")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("All Time") {
                    HStack {
                        Text("Total Completions")
                        Spacer()
                        Text("\(habitVM.totalCompletions)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Best Streak")
                        Spacer()
                        Text("\(habitVM.habits.map { $0.longestStreak }.max() ?? 0) days")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Total Habits")
                        Spacer()
                        Text("\(habitVM.habits.count)")
                            .foregroundStyle(.secondary)
                    }
                }

                if !habitVM.habits.isEmpty {
                    Section("Habit Streaks") {
                        ForEach(habitVM.habits) { habit in
                            HStack {
                                Text(habit.icon)
                                Text(habit.name)
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("\(habit.currentStreak) day streak")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("Best: \(habit.longestStreak)")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Statistics")
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var habitVM: HabitViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("App Name")
                        Spacer()
                        Text("HabitGo")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button("Reset All Data", role: .destructive) {
                        habitVM.habits.removeAll()
                        habitVM.save()
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
