import SwiftUI

struct HabitListView: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var showAddHabit = false
    @State private var showTemplates = false
    @State private var selectedCategoryId: UUID?
    @State private var showHabitDetail: Habit?

    private var filteredHabits: [Habit] {
        if let catId = selectedCategoryId {
            return habitVM.habits.filter { $0.categoryId == catId }
        }
        return habitVM.habits
    }

    var body: some View {
        NavigationStack {
            Group {
                if habitVM.habits.isEmpty {
                    emptyState
                } else {
                    habitList
                }
            }
            .navigationTitle("HabitArcFlow")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showAddHabit = true
                        } label: {
                            Label("New Habit", systemImage: "plus")
                        }
                        Button {
                            showTemplates = true
                        } label: {
                            Label("From Template", systemImage: "square.stack.3d.up")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddHabit) {
                AddHabitView()
            }
            .sheet(isPresented: $showTemplates) {
                HabitTemplatesView()
            }
            .sheet(item: $showHabitDetail) { habit in
                HabitDetailView(habit: habit)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 72))
                .foregroundStyle(ThemeManager.AppColors.primary.opacity(0.6))

            Text("Start Your Journey")
                .font(.title2.bold())

            Text("Build lasting habits and achieve your goals")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 12) {
                Button {
                    showAddHabit = true
                } label: {
                    Label("Add First Habit", systemImage: "plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ThemeManager.AppColors.primary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 40)

                Button {
                    showTemplates = true
                } label: {
                    Label("Browse Templates", systemImage: "square.stack.3d.up")
                        .font(.subheadline)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorScheme == .dark ? ThemeManager.AppColors.darkBackground : ThemeManager.AppColors.lightBackground)
    }

    private var habitList: some View {
        List {
            // Category filter
            if !habitVM.categories.isEmpty {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChipNew(
                                title: "All",
                                isSelected: selectedCategoryId == nil,
                                colorHex: ThemeManager.AppColors.primary.hexString
                            ) {
                                selectedCategoryId = nil
                            }

                            ForEach(habitVM.categories) { cat in
                                FilterChipNew(
                                    title: "\(cat.icon) \(cat.name)",
                                    isSelected: selectedCategoryId == cat.id,
                                    colorHex: cat.colorHex
                                ) {
                                    selectedCategoryId = cat.id
                                }
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }

            // Today's progress header
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Today's Progress")
                            .font(.headline)
                        Spacer()
                        Text("\(habitVM.completedToday)/\(habitVM.totalToday)")
                            .foregroundStyle(ThemeManager.AppColors.primary)
                    }
                    ProgressView(value: habitVM.todayProgress)
                        .tint(ThemeManager.AppColors.primary)
                        .scaleEffect(y: 1.5)

                    if habitVM.todayProgress >= 1.0 {
                        HStack {
                            Image(systemName: "party.popper.fill")
                                .foregroundStyle(.yellow)
                            Text("All habits completed! Great job!")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            // Habits
            Section(habitVM.habits.count == filteredHabits.count ? "My Habits" : "Category Habits") {
                ForEach(filteredHabits) { habit in
                    HabitRowView(habit: habit) {
                        habitVM.toggleHabit(habit)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showHabitDetail = habit
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
        .listStyle(.insetGrouped)
        .background(colorScheme == .dark ? ThemeManager.AppColors.darkBackground : ThemeManager.AppColors.lightBackground)
    }
}

struct FilterChipNew: View {
    let title: String
    let isSelected: Bool
    let colorHex: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected
                        ? Color(hex: colorHex)
                        : Color(.systemGray5)
                )
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

extension Color {
    var hexString: String {
        guard let components = UIColor(self).cgColor.components else { return "#34C759" }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
