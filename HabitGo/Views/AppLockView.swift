import SwiftUI
import LocalAuthentication

struct AppLockView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isLocked = false
    @State private var biometricType: LABiometryType = .none

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: biometricIcon)
                    .font(.system(size: 80))
                    .foregroundStyle(ThemeManager.AppColors.primary)

                Text(isLocked ? "HabitArcFlow is Locked" : "App Lock")
                    .font(.title2.bold())

                Text(isLocked ? "Authenticate to access your habits" : lockDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if isLocked {
                    Button {
                        authenticate()
                    } label: {
                        Label("Unlock with \(biometricName)", systemImage: biometricIcon)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ThemeManager.AppColors.primary)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 40)
                }

                Spacer()

                if !isLocked {
                    Toggle("Require \(biometricName) to Open", isOn: Binding(
                        get: { UserDefaults.standard.bool(forKey: "HabitArcFlow_appLockEnabled") },
                        set: { UserDefaults.standard.set($0, forKey: "HabitArcFlow_appLockEnabled") }
                    ))
                    .tint(ThemeManager.AppColors.primary)
                    .padding()
                    .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
            }
            .navigationTitle("App Lock")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                checkBiometricType()
                checkLockStatus()
            }
            .background(colorScheme == .dark ? ThemeManager.AppColors.darkBackground : ThemeManager.AppColors.lightBackground)
        }
    }

    private var biometricIcon: String {
        switch biometricType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        default: return "lock.fill"
        }
    }

    private var biometricName: String {
        switch biometricType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "Biometrics"
        }
    }

    private var lockDescription: String {
        if UserDefaults.standard.bool(forKey: "HabitArcFlow_appLockEnabled") {
            return "\(biometricName) is required to open the app"
        } else {
            return "Protect your habit data with \(biometricName)"
        }
    }

    private func checkBiometricType() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        }
    }

    private func checkLockStatus() {
        let requiresAuth = UserDefaults.standard.bool(forKey: "HabitArcFlow_appLockEnabled")
        if requiresAuth {
            isLocked = true
            authenticate()
        }
    }

    private func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Unlock HabitArcFlow"
            ) { success, _ in
                DispatchQueue.main.async {
                    if success {
                        isLocked = false
                    }
                }
            }
        }
    }
}
