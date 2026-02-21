import Foundation
import UserNotifications

struct NotificationScheduler {
    static let shared = NotificationScheduler()

    private let center = UNUserNotificationCenter.current()

    // MARK: - Public entry point

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

        let agendaToday = agendaEnabled
            ? agendaEvents.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
            : []
        let recurringToday = recurringEnabled
            ? recurringEvents.filter { $0.occurs(on: date, calendar: calendar) }
            : []

        // If both are enabled at the same time, send one combined notification.
        let sameTime = agendaEnabled && recurringEnabled && abs(agendaTime - recurringTime) < 1

        if sameTime {
            if agendaToday.isEmpty && recurringToday.isEmpty { return }
            guard let trigger = makeTrigger(for: date, secondsFromMidnight: agendaTime, calendar: calendar) else { return }

            let content = UNMutableNotificationContent()
            content.title = "Today's Plan"
            content.body = combinedBody(agendaEvents: agendaToday, recurringEvents: recurringToday)
            content.sound = .default

            await add(UNNotificationRequest(identifier: Identifiers.combined, content: content, trigger: trigger))
            return
        }

        if agendaEnabled, !agendaToday.isEmpty,
           let trigger = makeTrigger(for: date, secondsFromMidnight: agendaTime, calendar: calendar) {
            let content = UNMutableNotificationContent()
            content.title = "Agenda items for today"
            content.body = agendaBody(for: agendaToday)
            content.sound = .default

            await add(UNNotificationRequest(identifier: Identifiers.agenda, content: content, trigger: trigger))
        }

        if recurringEnabled, !recurringToday.isEmpty,
           let trigger = makeTrigger(for: date, secondsFromMidnight: recurringTime, calendar: calendar) {
            let content = UNMutableNotificationContent()
            content.title = "Recurring events today"
            content.body = recurringBody(for: recurringToday)
            content.sound = .default

            await add(UNNotificationRequest(identifier: Identifiers.recurring, content: content, trigger: trigger))
        }
    }

    // MARK: - Body builders

    /// Bulleted list of agenda items with optional time.
    /// e.g. "• Date with Margot 6:00 PM\n• Fortnite 8:00 PM"
    private func agendaBody(for events: [EventRecord]) -> String {
        events
            .map { event in
                if event.includesTime {
                    let timeStr = DateFormatter.eventTimeFormatter.string(from: event.timestamp)
                    return "• \(event.title) \(timeStr)"
                }
                return "• \(event.title)"
            }
            .joined(separator: "\n")
    }

    /// Bulleted list of recurring event titles.
    private func recurringBody(for events: [RecurringEvent]) -> String {
        events
            .map { "• \($0.title)" }
            .joined(separator: "\n")
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

    // MARK: - Scheduling helpers

    private func makeTrigger(for date: Date, secondsFromMidnight: Double, calendar: Calendar) -> UNCalendarNotificationTrigger? {
        let startOfDay = calendar.startOfDay(for: date)
        let clamped = max(0, min(86_399, secondsFromMidnight))
        let fireDate = startOfDay.addingTimeInterval(clamped)
        guard fireDate > Date() else { return nil }
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        components.second = 0
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }

    private func add(_ request: UNNotificationRequest) async {
        do {
            try await center.add(request)
        } catch {
#if DEBUG
            print("NotificationScheduler: failed to schedule — \(error.localizedDescription)")
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
            return (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        @unknown default:
            return false
        }
    }

    // MARK: - Identifiers

    private enum Identifiers {
        static let agenda   = "notifications.agenda.daily"
        static let recurring = "notifications.recurring.daily"
        static let combined  = "notifications.combined.daily"

        static var all: [String] { [agenda, recurring, combined] }
    }
}
