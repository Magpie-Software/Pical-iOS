import SwiftUI

struct ContentView: View {
    @State private var store = EventStore()
    @AppStorage(SettingsKeys.autoPurgePastEvents) private var autoPurgePastEvents = true
    @AppStorage(SettingsKeys.lastRefreshTimestamp) private var lastRefreshTimestamp: Double = 0

    var body: some View {
        TabView {
            AgendaView()
                .tabItem {
                    Label("Agenda", systemImage: "list.bullet.rectangle")
                }

            RecurringEventsView()
                .tabItem {
                    Label("Recurring", systemImage: "repeat")
                }

            OptionsView()
                .tabItem {
                    Label("Options", systemImage: "slider.horizontal.3")
                }
        }
        .environment(store)
        .task(runDailyRefreshIfNeeded)
    }

    private func runDailyRefreshIfNeeded() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastRefreshDate = Date(timeIntervalSince1970: lastRefreshTimestamp)

        if lastRefreshTimestamp == 0 || !calendar.isDate(lastRefreshDate, inSameDayAs: today) {
            await MainActor.run {
                store.dailyRefresh(referenceDate: today, purgePastEvents: autoPurgePastEvents, calendar: calendar)
            }
            lastRefreshTimestamp = today.timeIntervalSince1970
        }
    }
}

#Preview {
    ContentView()
}
