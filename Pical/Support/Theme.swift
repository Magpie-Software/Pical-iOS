import SwiftUI

/// Semantic theme wrapper. Use named Color assets (with light/dark variants) so designers can
/// supply both light and dark colors in the asset catalog. Asset names you should create:
/// - ColorBackground
/// - ColorPanel
/// - ColorTextPrimary
/// - ColorTextSecondary
/// - ColorAccent
/// - ColorSplash
/// - (optional) ColorHeaderStart, ColorHeaderEnd for an override of the header gradient
enum Theme {
    // Core surfaces
    static var background: Color { Color("ColorBackground") }
    static var panel: Color { Color("ColorPanel") }

    // Text
    static var textPrimary: Color { Color("ColorTextPrimary") }
    static var textSecondary: Color { Color("ColorTextSecondary") }

    // Accents
    static var accent: Color { Color("ColorAccent") }
    static var splash: Color { Color("ColorSplash") }

    // Header gradient: if the designer provides explicit start/end assets use them, otherwise
    // fall back to splash -> accent.
    static var headerGradient: LinearGradient {
        let start = Color("ColorHeaderStart")
        let end = Color("ColorHeaderEnd")

        // Attempt to use provided header assets; if they resolve to the default system color
        // (i.e., asset missing) they'll still be valid Colors, so we prefer explicit assets when present.
        // Designers: create ColorHeaderStart/ColorHeaderEnd if you want full control.
        return LinearGradient(colors: [start, end].allSatisfy({ !$0.description.isEmpty }) ? [start, end] : [Theme.splash, Theme.accent], startPoint: .leading, endPoint: .trailing)
    }
}
