import Foundation
import UserNotifications

struct NotificationScheduler {
    static let shared = NotificationScheduler()

    private let center = UNUserNotificationCenter.current()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        return f
    }()

    // MARK: - Public interface

    func scheduleNotifications(
        for date: Date,
        agendaEvents: [EventRecord],
        recurringEvents: [RecurringEvent],
        agendaEnabled: Bool,
        recurringEnabled: Bool,
        agendaTime: Double,
        recurringTime: Double,
        calendar: Calendar = .current
    ) async {
        guard agendaEnabled || recurringEnabled else {
            await center.removePendingNotificationRequests(withIdentifiers: Identifiers.all)
            return
        }

        guard await ensureAuthorization() else { return }

        await center.removePendingNotificationRequests(withIdentifiers: Identifiers.all)

        // Filter to events that fall on `date`
        let agendaToday = agendaEvents.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
        let recurringToday = recurringEvents.filter { $0.occurs(on: date, calendar: calendar) }

        // Combine into one notification when both are enabled at the same time
        let sameTime = agendaEnabled && recurringEnabled && abs(agendaTime - recurringTime) < 1

        if sameTime {
            guard !agendaToday.isEmpty || !recurringToday.isEmpty else { return }
            guard let trigger = trigger(for: date, secondsFromMidnight: agendaTime, calendar: calendar) else { return }
            let content = UNMutableNotificationContent()
            content.title = "Your day at a glance"
            content.body = combinedBody(agendaEvents: agendaToday, recurringEvents: recurringToday)
            content.sound = .default
            await add(UNNotificationRequest(identifier: Identifiers.combined, content: content, trigger: trigger))
            return
        }

        if agendaEnabled, !agendaToday.isEmpty,
           let trigger = trigger(for: date, secondsFromMidnight: agendaTime, calendar: calendar) {
            let content = UNMutableNotificationContent()
            content.title = "Agenda items for today"
            content.body = agendaBody(for: agendaToday)
            content.sound = .default
            await add(UNNotificationRequest(identifier: Identifiers.agenda, content: content, trigger: trigger))
        }

        if recurringEnabled, !recurringToday.isEmpty,
           let trigger = trigger(for: date, secondsFromMidnight: recurringTime, calendar: calendar) {
            let content = UNMutableNotificationContent()
            content.title = "Recurring events today"
            content.body = recurringBody(for: recurringToday)
            content.sound = .default
            await add(UNNotificationRequest(identifier: Identifiers.recurring, content: content, trigger: trigger))
        }
    }

    // MARK: - Body formatting

    /// Bulleted list for agenda items.
    /// Format: "- Title 6:00 PM" if timed, else "- Title"
    private func agendaBody(for events: [EventRecord]) -> String {
        let capped = Array(events.prefix(5))
        var lines = capped.map { event -> String in
            if event.includesTime {
                let time = Self.timeFormatter.string(from: event.timestamp)
                return "- \(event.title) \(time)"
            } else {
                return "- \(event.title)"
            }
        }
        let remainder = events.count - capped.count
        if remainder > 0 {
            lines.append("...and \(remainder) more")
        }
        return lines.joined(separator: "\n")
    }

    /// Bulleted list for recurring items. Format: "- Title"
    private func recurringBody(for events: [RecurringEvent]) -> String {
        let capped = Array(events.prefix(5))
        var lines = capped.map { "- \($0.title)" }
        let remainder = events.count - capped.count
        if remainder > 0 {
            lines.append("...and \(remainder) more")
        }
        return lines.joined(separator: "\n")
    }

    /// Combined body when agenda + recurring fire at the same time.
    private func combinedBody(agendaEvents: [EventRecord], recurringEvents: [RecurringEvent]) -> String {
        var parts: [String] = []
        if !agendaEvents.isEmpty {
            parts.append("Agenda:\n\(agendaBody(for: agendaEvents))")
        }
        if !recurringEvents.isEmpty {
            parts.append("Recurring:\n\(recurringBody(for: recurringEvents))")
        }
        return parts.joined(separator: "\n\n")
    }

    // MARK: - Helpers

    private func add(_ request: UNNotificationRequest) async {
        do {
            try await center.add(request)
        } catch {
#if DEBUG
            print("NotificationScheduler: failed to schedule '\(request.identifier)': \(error.localizedDescription)")
#endif
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

    private func trigger(
        for date: Date,
        secondsFromMidnight: Double,
        calendar: Calendar
    ) -> UNCalendarNotificationTrigger? {
        let startOfDay = calendar.startOfDay(for: date)
        let normalized = max(0, min(86_399, secondsFromMidnight))
        let fireDate = startOfDay.addingTimeInterval(normalized)
        guard fireDate > Date() else { return nil }
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        components.second = 0
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }

    // MARK: - Identifiers

    private enum Identifiers {
        static let agenda   = "notifications.agenda.daily"
        static let recurring = "notifications.recurring.daily"
        static let combined  = "notifications.combined.daily"
        static var all: [String] { [agenda, recurring, combined] }
    }
}
