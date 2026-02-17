import Foundation

struct EventRecord: Identifiable, Codable, Hashable {
    enum Recurrence: String, Codable, CaseIterable, Identifiable {
        case none
        case weekly
        case monthly

        var id: String { rawValue }
        var displayName: String {
            switch self {
            case .none: "One time"
            case .weekly: "Weekly"
            case .monthly: "Monthly"
            }
        }
    }

    var id: UUID
    var title: String
    var timestamp: Date
    var location: String?
    var notes: String?
    var recurrence: Recurrence
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        timestamp: Date,
        location: String? = nil,
        notes: String? = nil,
        recurrence: Recurrence = .none,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.timestamp = timestamp
        self.location = location
        self.notes = notes
        self.recurrence = recurrence
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension EventRecord {
    func updating(metadataDate: Date = .now, transform: (inout EventRecord) -> Void) -> EventRecord {
        var copy = self
        transform(&copy)
        copy.updatedAt = metadataDate
        return copy
    }

    func occurrences(in range: ClosedRange<Date>, calendar: Calendar = .autoupdatingCurrent) -> [EventOccurrence] {
        switch recurrence {
        case .none:
            guard range.contains(timestamp) else { return [] }
            return [EventOccurrence(event: self, occurrenceDate: timestamp, isRecurring: false)]
        case .weekly:
            return recurringOccurrences(in: range, calendar: calendar, component: .weekOfYear)
        case .monthly:
            return recurringOccurrences(in: range, calendar: calendar, component: .month)
        }
    }

    private func recurringOccurrences(in range: ClosedRange<Date>, calendar: Calendar, component: Calendar.Component) -> [EventOccurrence] {
        guard let first = calendar.firstOccurrence(of: timestamp, within: range, component: component) else {
            return []
        }

        var results: [EventOccurrence] = []
        var current = first
        while current <= range.upperBound {
            results.append(EventOccurrence(event: self, occurrenceDate: current, isRecurring: true))
            guard let next = calendar.date(byAdding: component, value: 1, to: current) else { break }
            current = next
        }
        return results
    }
}
