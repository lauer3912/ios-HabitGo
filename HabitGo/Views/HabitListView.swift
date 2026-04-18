import SwiftUI

struct HabitListView: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @State private var showAddHabit = false

    var body: some View {
        NavigationStack {
            Group {
                if habitVM.habits.isEmpty {
                    emptyState
                } else {
                    habitList
                }
            }
            .navigationTitle("HabitGo")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddHabit = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddHabit) {
                AddHabitView()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)
            Text("No habits yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Tap + to add your first habit")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Add First Habit") {
                showAddHabit = true
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "#34C759"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var habitList: some View {
        List {
            // Today's progress header
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Today's Progress")
                            .font(.headline)
                        Spacer()
                        Text("\(habitVM.completedToday)/\(habitVM.totalToday)")
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: habitVM.todayProgress)
                        .tint(Color(hex: "#34C759"))
                }
                .padding(.vertical, 4)
            }

            // Habits
            Section("My Habits") {
                ForEach($habitVM.habits) { $habit in
                    HabitRowView(habit: $habit) {
                        habitVM.toggleHabit(habit)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            habitVM.deleteHabit(habit)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
}
