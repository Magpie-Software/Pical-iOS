import SwiftUI

@main
struct PicalApp: App {
    init() {
        UserDefaults.standard.register(defaults: [
            SettingsKeys.recurringWeekdayGrouping: true,
            SettingsKeys.smartAgendaGrouping: true,
            SettingsKeys.compactLayout: false
        ])
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .accentColor(UserDefaults.standard.bool(forKey: SettingsKeys.themeEnabled) ? Theme.accent : Color.accentColor)
                .tint(UserDefaults.standard.bool(forKey: SettingsKeys.themeEnabled) ? Theme.accent : Color.accentColor)
        }
    }
}
