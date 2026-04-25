import SwiftUI

@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var colorScheme: ColorScheme? = nil
    @Published var isDarkMode: Bool = false

    // MARK: - App Colors - Dark Mode
    struct DarkColors {
        static let background = Color(hex: "000000")
        static let secondaryBackground = Color(hex: "141414")
        static let tertiaryBackground = Color(hex: "1E1E1E")
        static let card = Color(hex: "141414")
        static let elevated = Color(hex: "1E1E1E")
        static let text = Color(hex: "FFFFFF")
        static let textSecondary = Color(hex: "8E8E93")
        static let textTertiary = Color(hex: "636366")
        static let separator = Color(hex: "38383A")
        static let primary = Color(hex: "34C759")
        static let secondary = Color(hex: "007AFF")
        static let accent = Color(hex: "FF9500")
        static let success = Color(hex: "30D158")
        static let warning = Color(hex: "FF9F0A")
        static let error = Color(hex: "FF453A")
    }

    // MARK: - App Colors - Light Mode
    struct LightColors {
        static let background = Color(hex: "F8F9FA")
        static let secondaryBackground = Color(hex: "FFFFFF")
        static let tertiaryBackground = Color(hex: "F1F3F5")
        static let card = Color(hex: "FFFFFF")
        static let elevated = Color(hex: "FFFFFF")
        static let text = Color(hex: "1A1A1A")
        static let textSecondary = Color(hex: "6C757D")
        static let textTertiary = Color(hex: "ADB5BD")
        static let separator = Color(hex: "E9ECEF")
        static let primary = Color(hex: "34C759")
        static let secondary = Color(hex: "007AFF")
        static let accent = Color(hex: "FF9500")
        static let success = Color(hex: "28A745")
        static let warning = Color(hex: "FFC107")
        static let error = Color(hex: "DC3545")
    }

    // MARK: - App Colors (backward compatibility) - always dark themed color names
    struct AppColors {
        static let primary = DarkColors.primary
        static let primaryDark = DarkColors.primary
        static let accent = DarkColors.accent
        static let darkBackground = DarkColors.background
        static let darkSecondaryBG = DarkColors.secondaryBackground
        static let darkTertiaryBG = DarkColors.tertiaryBackground
        static let darkCard = DarkColors.card
        static let lightBackground = LightColors.background
        static let lightSecondaryBG = LightColors.secondaryBackground
        static let lightTertiaryBG = LightColors.tertiaryBackground
        static let lightCard = LightColors.card
        static let darkText = DarkColors.text
        static let darkSecondaryText = DarkColors.textSecondary
        static let lightText = LightColors.text
        static let lightSecondaryText = LightColors.textSecondary

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
            colorScheme = .dark  // Default to dark
            isDarkMode = true
        }
    }

    func setDarkMode(_ enabled: Bool) {
        isDarkMode = enabled
        UserDefaults.standard.set(enabled, forKey: "HabitArcFlow_darkMode")
        UserDefaults.standard.set(enabled ? "dark" : "light", forKey: "HabitArcFlow_colorScheme")
        colorScheme = enabled ? .dark : .light
    }

    func setLightMode() {
        isDarkMode = false
        UserDefaults.standard.set(false, forKey: "HabitArcFlow_darkMode")
        UserDefaults.standard.set("light", forKey: "HabitArcFlow_colorScheme")
        colorScheme = .light
    }

    func setSystemMode() {
        isDarkMode = false
        colorScheme = nil
        UserDefaults.standard.removeObject(forKey: "HabitArcFlow_darkMode")
        UserDefaults.standard.set("system", forKey: "HabitArcFlow_colorScheme")
    }

    // MARK: - Adaptive Colors
    func background(_ scheme: ColorScheme?) -> Color {
        scheme == .dark ? DarkColors.background : LightColors.background
    }

    func secondaryBG(_ scheme: ColorScheme?) -> Color {
        scheme == .dark ? DarkColors.secondaryBackground : LightColors.secondaryBackground
    }

    func tertiaryBG(_ scheme: ColorScheme?) -> Color {
        scheme == .dark ? DarkColors.tertiaryBackground : LightColors.tertiaryBackground
    }

    func card(_ scheme: ColorScheme?) -> Color {
        scheme == .dark ? DarkColors.card : LightColors.card
    }

    func elevated(_ scheme: ColorScheme?) -> Color {
        scheme == .dark ? DarkColors.elevated : LightColors.elevated
    }

    func text(_ scheme: ColorScheme?) -> Color {
        scheme == .dark ? DarkColors.text : LightColors.text
    }

    func textSecondary(_ scheme: ColorScheme?) -> Color {
        scheme == .dark ? DarkColors.textSecondary : LightColors.textSecondary
    }

    func textTertiary(_ scheme: ColorScheme?) -> Color {
        scheme == .dark ? DarkColors.textTertiary : LightColors.textTertiary
    }

    func separator(_ scheme: ColorScheme?) -> Color {
        scheme == .dark ? DarkColors.separator : LightColors.separator
    }

    // MARK: - Semantic Colors
    var primary: Color { isDarkMode ? DarkColors.primary : LightColors.primary }
    var secondary: Color { isDarkMode ? DarkColors.secondary : LightColors.secondary }
    var accent: Color { isDarkMode ? DarkColors.accent : LightColors.accent }
    var success: Color { isDarkMode ? DarkColors.success : LightColors.success }
    var warning: Color { isDarkMode ? DarkColors.warning : LightColors.warning }
    var error: Color { isDarkMode ? DarkColors.error : LightColors.error }
}

// MARK: - Adaptive View Modifier
extension View {
    func adaptiveBackground(_ scheme: ColorScheme?) -> some View {
        self.background(scheme == .dark ? ThemeManager.DarkColors.background : ThemeManager.LightColors.background)
    }

    func adaptiveSecondaryBG(_ scheme: ColorScheme?) -> some View {
        self.background(scheme == .dark ? ThemeManager.DarkColors.secondaryBackground : ThemeManager.LightColors.secondaryBackground)
    }

    func adaptiveCard(_ scheme: ColorScheme?) -> some View {
        self.background(scheme == .dark ? ThemeManager.DarkColors.card : ThemeManager.LightColors.card)
    }

    func adaptiveElevated(_ scheme: ColorScheme?) -> some View {
        self.background(scheme == .dark ? ThemeManager.DarkColors.elevated : ThemeManager.LightColors.elevated)
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