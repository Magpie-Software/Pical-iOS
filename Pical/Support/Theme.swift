import SwiftUI

enum Theme {
    // Use named color assets so designers/developers can update them in the asset catalog.
    // Asset names expected: "Onyx", "MintCream", "ShadowGray", "Ivory".
    static var background: Color { Color("MintCream") }
    static var panel: Color { Color("Ivory") }

    static var textPrimary: Color { Color("Ivory") }
    static var textSecondary: Color { Color("ColorTextSecondary") }

    // Accent/splash treatment
    static var accent: Color { Color("BalticBlue") }
    static var splash: Color { Color("JungleTeal") }

    // Always use the fancier header gradient
    static var headerGradient: LinearGradient {
        LinearGradient(colors: [Theme.splash, Theme.accent], startPoint: .leading, endPoint: .trailing)
    }
}
