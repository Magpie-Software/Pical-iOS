import Foundation

enum Formatters {
    static let weekday: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
}

extension PicalEvent {
    var weekdayLabel: String {
        Formatters.weekday.string(from: date)
    }

    var dateLabel: String {
        Formatters.shortDate.string(from: date)
    }

    var timeDescription: String? {
        guard includesTime else { return nil }
        let start = Formatters.time.string(from: date)
        if let endDate {
            let end = Formatters.time.string(from: endDate)
            return "\(start) – \(end)"
        }
        return start
    }
}

extension Int {
    var ordinalString: String {
        let suffix: String
        switch self % 100 {
        case 11, 12, 13:
            suffix = "th"
        default:
            switch self % 10 {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default:
                suffix = "th"
            }
        }
        return "\(self)\(suffix)"
    }
}
