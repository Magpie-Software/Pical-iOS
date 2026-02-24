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
                .accentColor(Theme.accent)
                .tint(Theme.accent)
        }
    }
}
