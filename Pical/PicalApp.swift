import SwiftUI

@main
struct PicalApp: App {
    init() {
        UserDefaults.standard.register(defaults: [
            SettingsKeys.recurringWeekdayGrouping: true
        ])
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
