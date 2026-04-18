import SwiftUI

@main
struct HabitGoApp: App {
    @StateObject private var habitVM = HabitViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(habitVM)
        }
    }
}
