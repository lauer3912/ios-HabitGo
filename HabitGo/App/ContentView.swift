import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var habitVM: HabitViewModel

    var body: some View {
        TabView {
            HabitListView()
                .tabItem {
                    Label("Habits", systemImage: "checkmark.circle.fill")
                }

            CalendarHistoryView()
                .tabItem {
                    Label("History", systemImage: "calendar")
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
    @State private var showExportOptions = false
    @State private var showImportPicker = false
    @State private var showImportSuccess = false
    @State private var showImportError = false
    @State private var exportData: Data?
    @State private var exportCSVText: String = ""

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
                    HStack {
                        Text("Total Habits")
                        Spacer()
                        Text("\(habitVM.habits.count)")
                            .foregroundStyle(.secondary)
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
                        NotificationManager.shared.clearAll()
                    }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Export Format", isPresented: $showExportOptions) {
                Button("JSON (Full Backup)") {
                    if let data = exportData {
                        shareData(data: data, filename: "HabitGo_backup.json", mimeType: "application/json")
                    }
                }
                Button("CSV (Spreadsheet)") {
                    let csv = habitVM.exportCSV()
                    shareText(text: csv, filename: "HabitGo_export.csv")
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
                Text("Could not import data. Please make sure the file is a valid HabitGo JSON export.")
            }
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
