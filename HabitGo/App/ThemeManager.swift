import SwiftUI
import Combine

@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var colorScheme: ColorScheme? = nil
    @Published var isDarkMode: Bool = false

    // MARK: - App Colors
    struct AppColors {
        // Primary palette
        static let primary = Color(hex: "#34C759")
        static let primaryDark = Color(hex: "#2DA44E")
        static let accent = Color(hex: "#007AFF")

        // Dark theme backgrounds
        static let darkBackground = Color(hex: "#000000")
        static let darkSecondaryBG = Color(hex: "#1C1C1E")
        static let darkTertiaryBG = Color(hex: "#2C2C2E")
        static let darkCard = Color(hex: "#1C1C1E")

        // Light theme backgrounds
        static let lightBackground = Color(hex: "#F2F2F7")
        static let lightSecondaryBG = Color(hex: "#FFFFFF")
        static let lightTertiaryBG = Color(hex: "#F2F2F7")
        static let lightCard = Color(hex: "#FFFFFF")

        // Text colors
        static let darkText = Color(hex: "#FFFFFF")
        static let darkSecondaryText = Color(hex: "#8E8E93")
        static let lightText = Color(hex: "#000000")
        static let lightSecondaryText = Color(hex: "#8E8E93")

        // Habit colors
        static let habitColors: [String] = [
            "#34C759", "#007AFF", "#FF9500", "#FF3B30",
            "#AF52DE", "#5856D6", "#00C7BE", "#FF2D55",
            "#FFD60A", "#30D158", "#64D2FF", "#BF5AF2"
        ]

        static let habitIcons: [String] = [
            "checkmark", "book.fill", "dumbbell.fill", "drop.fill",
            "moon.fill", "figure.walk", "pencil", "heart.fill",
            "star.fill", "flame.fill", "leaf.fill", "brain.head.profile",
            "bed.double.fill", "cup.and.saucer.fill", "pill.fill", "bolt.fill",
            "sun.max.fill", "moon.stars.fill", "figure.run", "figure.yoga",
            "fork.knife", "scale.3d", "eye.fill", "hand.raised.fill"
        ]
    }

    private init() {
        loadThemePreference()
    }

    func loadThemePreference() {
        isDarkMode = UserDefaults.standard.bool(forKey: "HabitArcFlow_darkMode")
        let stored = UserDefaults.standard.string(forKey: "HabitArcFlow_colorScheme")
        if stored == "dark" {
            colorScheme = .dark
            isDarkMode = true
        } else if stored == "light" {
            colorScheme = .light
            isDarkMode = false
        } else {
            colorScheme = nil // System
            isDarkMode = false
        }
    }

    func setDarkMode(_ enabled: Bool) {
        isDarkMode = enabled
        UserDefaults.standard.set(enabled, forKey: "HabitArcFlow_darkMode")
        UserDefaults.standard.set(enabled ? "dark" : "light", forKey: "HabitArcFlow_colorScheme")
        colorScheme = enabled ? .dark : .light
    }

    func setSystemMode() {
        isDarkMode = false
        colorScheme = nil
        UserDefaults.standard.removeObject(forKey: "HabitArcFlow_darkMode")
        UserDefaults.standard.set("system", forKey: "HabitArcFlow_colorScheme")
    }

    // MARK: - Adaptive Colors
    func background(_ scheme: ColorScheme?) -> Color {
        scheme == .dark ? AppColors.darkBackground : AppColors.lightBackground
    }

    func secondaryBG(_ scheme: ColorScheme?) -> Color {
        scheme == .dark ? AppColors.darkSecondaryBG : AppColors.lightSecondaryBG
    }

    func card(_ scheme: ColorScheme?) -> Color {
        scheme == .dark ? AppColors.darkCard : AppColors.lightCard
    }

    func text(_ scheme: ColorScheme?) -> Color {
        scheme == .dark ? AppColors.darkText : AppColors.lightText
    }

    func secondaryText(_ scheme: ColorScheme?) -> Color {
        scheme == .dark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText
    }
}

// MARK: - Adaptive View Modifier
struct AdaptiveViewModifier: ViewModifier {
    @ObservedObject var theme = ThemeManager.shared
    let keyPath: KeyPath<ThemeManager.AppColors.Type, Color>

    func body(content: Content) -> some View {
        content
            .environment(\.colorScheme, theme.colorScheme)
    }
}

extension View {
    func adaptiveBackground(_ scheme: ColorScheme?) -> some View {
        self.background(scheme == .dark ? ThemeManager.AppColors.darkBackground : ThemeManager.AppColors.lightBackground)
    }

    func adaptiveSecondaryBG(_ scheme: ColorScheme?) -> some View {
        self.background(scheme == .dark ? ThemeManager.AppColors.darkSecondaryBG : ThemeManager.AppColors.lightSecondaryBG)
    }

    func adaptiveCard(_ scheme: ColorScheme?) -> some View {
        self.background(scheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default: (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
