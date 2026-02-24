import SwiftUI

@main
struct PicalApp: App {
    init() {
        UserDefaults.standard.register(defaults: [
            SettingsKeys.recurringWeekdayGrouping: true,
            SettingsKeys.smartAgendaGrouping: true,
            SettingsKeys.compactLayout: false
        ])

        // Make the large navigation title use the brand BalticBlue color.
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithDefaultBackground()
        let largeColor = UIColor(named: "BalticBlue") ?? UIColor.systemBlue
        navAppearance.largeTitleTextAttributes = [.foregroundColor: largeColor]
        navAppearance.titleTextAttributes = [.foregroundColor: largeColor]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .accentColor(Theme.accent)
                .tint(Theme.accent)
        }
    }
}
