import SwiftUI

@main
struct PicalApp: App {
    init() {
        UserDefaults.standard.register(defaults: [
            SettingsKeys.recurringWeekdayGrouping: true,
            SettingsKeys.smartAgendaGrouping: false,
            SettingsKeys.compactLayout: false
        ])
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
