import SwiftUI

struct ContentView: View {
    @StateObject private var agendaStore = EventStore()
    @State private var store = AgendaDataStore()
    @AppStorage(SettingsKeys.autoPurgePastEvents) private var autoPurgePastEvents = true
    @AppStorage(SettingsKeys.lastRefreshTimestamp) private var lastRefreshTimestamp: Double = 0
    @AppStorage(SettingsKeys.agendaNotificationsEnabled) private var agendaNotificationsEnabled = false
    @AppStorage(SettingsKeys.recurringNotificationsEnabled) private var recurringNotificationsEnabled = false
    @AppStorage(SettingsKeys.agendaNotificationTime) private var agendaNotificationTime: Double = DefaultTimes.agenda
    @AppStorage(SettingsKeys.recurringNotificationTime) private var recurringNotificationTime: Double = DefaultTimes.recurring

    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            AgendaView(store: agendaStore)
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
        .task { await runDailyRefreshIfNeeded() }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                Task { await scheduleNotificationsForToday() }
            }
        }
        .onChange(of: agendaNotificationsEnabled) { _ in
            Task { await scheduleNotificationsForToday() }
        }
        .onChange(of: recurringNotificationsEnabled) { _ in
            Task { await scheduleNotificationsForToday() }
        }
        .onChange(of: agendaNotificationTime) { _ in
            Task { await scheduleNotificationsForToday() }
        }
        .onChange(of: recurringNotificationTime) { _ in
            Task { await scheduleNotificationsForToday() }
        }
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

        await scheduleNotificationsForToday()
    }

    private func scheduleNotificationsForToday() async {
        let snapshot = await MainActor.run { (events: store.events, recurring: store.recurringEvents) }
        await NotificationScheduler.shared.scheduleNotifications(
            for: Date(),
            events: snapshot.events,
            recurringEvents: snapshot.recurring,
            agendaEnabled: agendaNotificationsEnabled,
            recurringEnabled: recurringNotificationsEnabled,
            agendaTime: agendaNotificationTime,
            recurringTime: recurringNotificationTime
        )
    }
}

#Preview {
    ContentView()
}
