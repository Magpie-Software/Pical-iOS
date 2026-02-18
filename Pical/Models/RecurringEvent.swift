import Foundation

enum Weekday: Int, CaseIterable, Identifiable, Codable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    var id: Int { rawValue }

    var label: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.weekdaySymbols[id - 1]
    }
}

enum OrdinalWeek: Int, CaseIterable, Identifiable, Codable {
    case first = 1
    case second
    case third
    case fourth
    case last

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .first: return "First"
        case .second: return "Second"
        case .third: return "Third"
        case .fourth: return "Fourth"
        case .last: return "Last"
        }
    }
}

enum RecurrencePattern: Identifiable, Codable, Hashable {
    case weekly(Weekday)
    case monthlyOrdinal(OrdinalWeek, Weekday)
    case monthlyDate(Int)

    var id: String {
        switch self {
        case let .weekly(day):
            return "weekly-\(day.rawValue)"
        case let .monthlyOrdinal(ordinal, day):
            return "monthly-ordinal-\(ordinal.rawValue)-\(day.rawValue)"
        case let .monthlyDate(day):
            return "monthly-date-\(day)"
        }
    }

    var description: String {
        switch self {
        case let .weekly(day):
            return "Every \(day.label)"
        case let .monthlyOrdinal(ordinal, day):
            return "\(ordinal.label) \(day.label)"
        case let .monthlyDate(day):
            let suffix: String
            switch day {
            case 1, 21, 31: suffix = "st"
            case 2, 22: suffix = "nd"
            case 3, 23: suffix = "rd"
            default: suffix = "th"
            }
            return "Day \(day)\(suffix)"
        }
    }
}

enum RecurringStopCondition: Codable, Hashable {
    case endDate(Date)
    case occurrenceCount(Int)

    var description: String {
        switch self {
        case let .endDate(date):
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return "Ends on \(formatter.string(from: date))"
        case let .occurrenceCount(count):
            return "Ends after \(count) occurrences"
        }
    }
}

struct RecurringEvent: Identifiable, Equatable, Hashable, Codable {
    var id: UUID = UUID()
    var title: String
    var pattern: RecurrencePattern
    var location: String?
    var notes: String?
    var stopCondition: RecurringStopCondition?

    init(id: UUID = UUID(), title: String, pattern: RecurrencePattern, location: String? = nil, notes: String? = nil, stopCondition: RecurringStopCondition? = nil) {
        self.id = id
        self.title = title
        self.pattern = pattern
        self.location = location
        self.notes = notes
        self.stopCondition = stopCondition
    }
}

extension RecurringEvent {
    static func sampleData() -> [RecurringEvent] {
        return [
            RecurringEvent(title: "Team sync",
                           pattern: .weekly(.monday),
                           location: "HQ",
                           notes: "Share wins",
                           stopCondition: nil),
            RecurringEvent(title: "House reset",
                           pattern: .monthlyOrdinal(.first, .saturday),
                           location: "Home",
                           notes: "Deep clean kitchen",
                           stopCondition: .occurrenceCount(12)),
            RecurringEvent(title: "Budget review",
                           pattern: .monthlyDate(15),
                           location: nil,
                           notes: "Check subscriptions",
                           stopCondition: .endDate(Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()))
        ]
    }
}
