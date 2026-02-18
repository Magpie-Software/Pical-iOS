import Foundation
import UserNotifications

struct NotificationScheduler {
    static let shared = NotificationScheduler()

    private let center = UNUserNotificationCenter.current()

    func scheduleNotifications(
        for date: Date,
        events: [PicalEvent],
        recurringEvents: [RecurringEvent],
        agendaEnabled: Bool,
        recurringEnabled: Bool,
        agendaTime: Double,
        recurringTime: Double,
        calendar: Calendar = .current
    ) async {
        if !(agendaEnabled || recurringEnabled) {
            await center.removePendingNotificationRequests(withIdentifiers: [Identifiers.agenda, Identifiers.recurring])
            return
        }

        guard await ensureAuthorization() else { return }

        await center.removePendingNotificationRequests(withIdentifiers: [Identifiers.agenda, Identifiers.recurring])

        if agendaEnabled {
            let todaysEvents = events.filter { calendar.isDate($0.date, inSameDayAs: date) }
            if !todaysEvents.isEmpty,
               let trigger = trigger(for: date, secondsFromMidnight: agendaTime, calendar: calendar) {
                let content = UNMutableNotificationContent()
                content.title = "Today's agenda"
                content.body = summary(for: todaysEvents)
                content.sound = .default

                let request = UNNotificationRequest(identifier: Identifiers.agenda, content: content, trigger: trigger)
                await center.add(request)
            }
        }

        if recurringEnabled {
            let todaysRecurring = recurringEvents.filter { $0.occurs(on: date, calendar: calendar) }
            if !todaysRecurring.isEmpty,
               let trigger = trigger(for: date, secondsFromMidnight: recurringTime, calendar: calendar) {
                let content = UNMutableNotificationContent()
                content.title = "Recurring rhythms today"
                content.body = recurringSummary(for: todaysRecurring)
                content.sound = .default

                let request = UNNotificationRequest(identifier: Identifiers.recurring, content: content, trigger: trigger)
                await center.add(request)
            }
        }
    }

    private func ensureAuthorization() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            do {
                return try await center.requestAuthorization(options: [.alert, .sound])
            } catch {
                return false
            }
        @unknown default:
            return false
        }
    }

    private func trigger(for date: Date, secondsFromMidnight: Double, calendar: Calendar) -> UNCalendarNotificationTrigger? {
        let startOfDay = calendar.startOfDay(for: date)
        let normalized = max(0, min(86_399, secondsFromMidnight))
        let fireDate = startOfDay.addingTimeInterval(normalized)
        guard fireDate > Date() else { return nil }
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        components.second = 0
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }

    private func summary(for events: [PicalEvent]) -> String {
        if events.count == 1, let event = events.first {
            return singleAgendaSummary(for: event)
        }
        let titles = events.prefix(3).map { $0.title }
        let remainder = events.count - titles.count
        var body = titles.joined(separator: ", ")
        if remainder > 0 {
            body += " +\(remainder) more"
        }
        return body
    }

    private func recurringSummary(for events: [RecurringEvent]) -> String {
        if events.count == 1, let event = events.first {
            return event.title
        }
        let titles = events.prefix(3).map { $0.title }
        let remainder = events.count - titles.count
        var body = titles.joined(separator: ", ")
        if remainder > 0 {
            body += " +\(remainder) more"
        }
        return body
    }

    private func singleAgendaSummary(for event: PicalEvent) -> String {
        if let timeDescription = event.timeDescription {
            return "\(event.title) at \(timeDescription)"
        }
        return event.title
    }

    private enum Identifiers {
        static let agenda = "notifications.agenda.daily"
        static let recurring = "notifications.recurring.daily"
    }
}
