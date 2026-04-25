import SwiftUI
import LocalAuthentication

@main
struct HabitGoApp: App {
    @StateObject private var habitVM = HabitViewModel()
    @State private var isLocked = true
    @State private var authError: String?

    var body: some Scene {
        WindowGroup {
            Group {
                if isLocked && UserDefaults.standard.bool(forKey: "HabitArcFlow_appLockEnabled") {
                    AppLockView()
                } else {
                    ContentView()
                        .environmentObject(habitVM)
                }
            }
            .preferredColorScheme(ThemeManager.shared.colorScheme)
            .onAppear {
                checkLockStatus()
            }
        }
    }

    private func checkLockStatus() {
        let requiresLock = UserDefaults.standard.bool(forKey: "HabitArcFlow_appLockEnabled")
        if requiresLock {
            isLocked = true
            authenticate()
        } else {
            isLocked = false
        }
    }

    private func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Unlock HabitArcFlow"
            ) { success, authErr in
                DispatchQueue.main.async {
                    if success {
                        withAnimation {
                            isLocked = false
                        }
                    } else {
                        self.authError = authErr?.localizedDescription
                    }
                }
            }
        } else {
            // No biometrics available, allow access
            isLocked = false
        }
    }
}
