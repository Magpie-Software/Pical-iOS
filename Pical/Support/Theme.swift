import SwiftUI

enum Theme {
    /// The new toggle is "Simple theme". When that flag is ON we use a toned-back Pical look.
    /// When it's OFF we show a fancier Pical theme (richer gradient/splash).
    static var isSimple: Bool { UserDefaults.standard.bool(forKey: SettingsKeys.themeEnabled) }

    static var background: Color { isSimple ? Color("Ivory") : Color("Ivory") }
    static var panel: Color { isSimple ? Color("ShadowGray") : Color("ShadowGray") }
    static var textPrimary: Color { isSimple ? Color("Ivory") : Color("Ivory") }
    static var textSecondary: Color { isSimple ? Color("ColorTextSecondary") : Color("ColorTextSecondary") }

    // Accent/splash treatment differs between simple vs. fancy
    static var accent: Color {
        if isSimple {
            // toned-back accent (slightly muted)
            Color("BalticBlue").opacity(0.9)
        } else {
            // full-strength brand accent
            Color("BalticBlue")
        }
    }

    static var splash: Color {
        if isSimple {
            Color("JungleTeal").opacity(0.9)
        } else {
            Color("JungleTeal")
        }
    }

    static var headerGradient: LinearGradient {
        if isSimple {
            // subtler single-color header for simple mode
            LinearGradient(colors: [Theme.accent, Theme.accent], startPoint: .leading, endPoint: .trailing)
        } else {
            // fancier gradient for full theme
            LinearGradient(colors: [Theme.splash, Theme.accent], startPoint: .leading, endPoint: .trailing)
        }
    }
}
