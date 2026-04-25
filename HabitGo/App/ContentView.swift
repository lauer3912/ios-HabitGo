import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @StateObject private var theme = ThemeManager.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HabitListView()
                .tabItem {
                    Label("Habits", systemImage: "checkmark.circle.fill")
                }
                .tag(0)

            CalendarHistoryView()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
                .tag(1)

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(2)

            AchievementsView()
                .tabItem {
                    Label("Badges", systemImage: "star.circle.fill")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tint(ThemeManager.AppColors.primary)
        .preferredColorScheme(theme.colorScheme)
    }
}

// MARK: - Stats View
struct StatsView: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Completed Today")
                        Spacer()
                        Text("\(habitVM.completedToday) / \(habitVM.totalToday)")
                            .foregroundStyle(ThemeManager.AppColors.primary)
                    }
                    HStack {
                        Text("Today's Progress")
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
                            .foregroundStyle(ThemeManager.AppColors.primary)
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
                    HStack {
                        Text("Achievements")
                        Spacer()
                        Text("\(habitVM.allAchievements.filter { $0.isUnlocked }.count) / \(habitVM.allAchievements.count)")
                            .foregroundStyle(.secondary)
                    }
                }

                if !habitVM.habits.isEmpty {
                    Section("Habit Streaks") {
                        ForEach(habitVM.habits) { habit in
                            HStack {
                                Image(systemName: habit.icon)
                                    .font(.title3)
                                Text(habit.name)
                                Spacer()
                                VStack(alignment: .trailing) {
                                    HStack(spacing: 4) {
                                        if habit.currentStreak > 0 {
                                            StreakFireView(streak: habit.currentStreak)
                                        }
                                        Text("\(habit.currentStreak) day")
                                            .font(.caption)
                                            .foregroundStyle(habit.currentStreak > 0 ? .orange : .secondary)
                                    }
                                    Text("Best: \(habit.longestStreak)")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                    }
                }

                Section {
                    NavigationLink {
                        WeeklyProgressView()
                    } label: {
                        Label("Weekly Goals", systemImage: "target")
                    }

                    NavigationLink {
                        WeeklyReviewView()
                    } label: {
                        Label("Weekly Review", systemImage: "doc.text.magnifyingglass")
                    }

                    NavigationLink {
                        TrendChartView()
                    } label: {
                        Label("Trends & Charts", systemImage: "chart.line.uptrend.xyaxis")
                    }

                    NavigationLink {
                        HeatMapView()
                    } label: {
                        Label("Heat Map", systemImage: "square.grid.3x3.fill")
                    }

                    NavigationLink {
                        HabitStackView()
                    } label: {
                        Label("Habit Stacks", systemImage: "link")
                    }
                }
            }
            .navigationTitle("Statistics")
            .background(colorScheme == .dark ? Color.black : Color(hex: "F8F9FA"))
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var habitVM: HabitViewModel
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var theme = ThemeManager.shared
    @State private var showExportOptions = false
    @State private var showImportPicker = false
    @State private var showImportSuccess = false
    @State private var showImportError = false
    @State private var exportData: Data?
    @State private var showCategories = false
    @State private var showTemplates = false
    @State private var showFocusMode = false
    @State private var showAppLock = false

    var body: some View {
        NavigationStack {
            List {
                Section("App") {
                    HStack {
                        Text("App Name")
                        Spacer()
                        Text("HabitArcFlow")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("3.0")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Total Habits")
                        Spacer()
                        Text("\(habitVM.habits.count)")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Appearance") {
                    Picker("Theme", selection: Binding(
                        get: {
                            if let stored = UserDefaults.standard.string(forKey: "HabitArcFlow_colorScheme") {
                                return stored
                            }
                            return "system"
                        },
                        set: { newValue in
                            if newValue == "dark" {
                                theme.setDarkMode(true)
                            } else if newValue == "light" {
                                theme.setLightMode()
                            } else {
                                theme.setSystemMode()
                            }
                        }
                    )) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.segmented)
                }

                Section("Habit Management") {
                    Button {
                        showTemplates = true
                    } label: {
                        Label("Habit Templates", systemImage: "square.stack.3d.up.fill")
                    }

                    Button {
                        showCategories = true
                    } label: {
                        Label("Categories", systemImage: "folder.fill")
                    }

                    NavigationLink {
                        FocusModeView()
                    } label: {
                        Label("Focus Mode", systemImage: "moon.stars.fill")
                    }
                }

                Section("Notifications") {
                    HStack {
                        Text("Notification Status")
                        Spacer()
                        Text(habitVM.notificationAuthGranted ? "Authorized" : "Not Authorized")
                            .foregroundStyle(habitVM.notificationAuthGranted ? .green : .red)
                    }

                    if !habitVM.notificationAuthGranted {
                        Button("Request Permission") {
                            habitVM.requestNotificationAuth { _ in }
                        }
                    }

                    if habitVM.notificationAuthGranted {
                        Button("Reschedule All Reminders") {
                            habitVM.rescheduleAllNotifications()
                        }
                    }
                }

                Section("Security") {
                    NavigationLink {
                        AppLockView()
                    } label: {
                        Label("App Lock", systemImage: "lock.fill")
                    }
                }

                Section("Data") {
                    Button {
                        if let data = habitVM.exportJSON() {
                            exportData = data
                            showExportOptions = true
                        }
                    } label: {
                        Label("Export Data (JSON)", systemImage: "square.and.arrow.up")
                    }
                    .disabled(habitVM.habits.isEmpty)

                    Button {
                        showImportPicker = true
                    } label: {
                        Label("Import Data (JSON)", systemImage: "square.and.arrow.down")
                    }
                }

                Section {
                    Button("Reset All Data", role: .destructive) {
                        habitVM.habits.removeAll()
                        habitVM.save()
                        habitVM.weeklyGoals.removeAll()
                        habitVM.habitNotes.removeAll()
                        habitVM.saveWeeklyGoals()
                        habitVM.saveNotes()
                        NotificationManager.shared.clearAll()
                    }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Export Format", isPresented: $showExportOptions) {
                Button("JSON (Full Backup)") {
                    if let data = exportData {
                        shareData(data: data, filename: "HabitArcFlow_v3_backup.json", mimeType: "application/json")
                    }
                }
                Button("CSV (Spreadsheet)") {
                    let csv = habitVM.exportCSV()
                    shareText(text: csv, filename: "HabitArcFlow_export.csv")
                }
                Button("Cancel", role: .cancel) {}
            }
            .fileImporter(
                isPresented: $showImportPicker,
                allowedContentTypes: [UTType.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    guard url.startAccessingSecurityScopedResource() else { return }
                    defer { url.stopAccessingSecurityScopedResource() }
                    do {
                        let data = try Data(contentsOf: url)
                        if habitVM.importJSON(from: data) {
                            showImportSuccess = true
                        } else {
                            showImportError = true
                        }
                    } catch {
                        showImportError = true
                    }
                case .failure:
                    showImportError = true
                }
            }
            .alert("Import Successful", isPresented: $showImportSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your habits have been restored successfully.")
            }
            .alert("Import Failed", isPresented: $showImportError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Could not import data. Please make sure the file is a valid HabitArcFlow JSON export.")
            }
            .sheet(isPresented: $showTemplates) {
                HabitTemplatesView()
            }
            .sheet(isPresented: $showCategories) {
                CategoriesView()
            }
            .background(colorScheme == .dark ? Color.black : Color(hex: "F8F9FA"))
        }
    }

    private func shareData(data: Data, filename: String, mimeType: String) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: tempURL)
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        } catch {}
    }

    private func shareText(text: String, filename: String) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try text.write(to: tempURL, atomically: true, encoding: .utf8)
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        } catch {}
    }
}