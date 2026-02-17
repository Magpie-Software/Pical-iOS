import Foundation

extension Calendar {
    func firstOccurrence(of date: Date, within range: ClosedRange<Date>, component: Calendar.Component) -> Date? {
        if range.contains(date) { return date }
        guard date < range.upperBound else { return nil }

        var current = date
        while current < range.lowerBound {
            guard let next = self.date(byAdding: component, value: 1, to: current) else { return nil }
            current = next
        }
        return range.contains(current) ? current : nil
    }

    func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        isDate(lhs, inSameDayAs: rhs)
    }
}
