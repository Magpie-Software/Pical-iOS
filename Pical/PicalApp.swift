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
        // Title color
        let largeColor = UIColor(named: "BalticBlue") ?? UIColor.systemBlue
        navAppearance.largeTitleTextAttributes = [.foregroundColor: largeColor]
        navAppearance.titleTextAttributes = [.foregroundColor: largeColor]
        // Match the nav bar background to the app content background color
        if let bg = UIColor(named: "Ivory") {
            navAppearance.backgroundColor = bg
        } else {
            navAppearance.backgroundColor = UIColor.systemBackground
        }
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
