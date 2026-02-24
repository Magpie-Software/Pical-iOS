import SwiftUI

enum Theme {
    static var background: Color { Color("Ivory") }
    static var panel: Color { Color("ShadowGray") }
    static var textPrimary: Color { Color("Ivory") }
    static var textSecondary: Color { Color("ColorTextSecondary") }
    static var accent: Color { Color("BalticBlue") }
    static var splash: Color { Color("JungleTeal") }

    static var isEnabled: Bool { UserDefaults.standard.bool(forKey: SettingsKeys.themeEnabled) }
    static var headerGradient: LinearGradient {
        LinearGradient(colors: [Theme.splash, Theme.accent], startPoint: .leading, endPoint: .trailing)
    }
}
