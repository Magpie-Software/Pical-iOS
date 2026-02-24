import SwiftUI

enum Theme {
    static var background: Color { isEnabled ? Color("Ivory") : Color(.systemBackground) }
    static var panel: Color { isEnabled ? Color("ShadowGray") : Color(.secondarySystemBackground) }
    static var textPrimary: Color { isEnabled ? Color("Ivory") : Color.primary }
    static var textSecondary: Color { isEnabled ? Color("ColorTextSecondary") : Color.secondary }
    static var accent: Color { isEnabled ? Color("BalticBlue") : Color.accentColor }
    static var splash: Color { isEnabled ? Color("JungleTeal") : Color.accentColor }

    static var isEnabled: Bool { UserDefaults.standard.bool(forKey: SettingsKeys.themeEnabled) }
    static var headerGradient: LinearGradient {
        LinearGradient(colors: [Theme.splash, Theme.accent], startPoint: .leading, endPoint: .trailing)
    }
}
