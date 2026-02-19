import Foundation

extension EventRecord {
    static var samples: [EventRecord] {
        let calendar = Calendar.autoupdatingCurrent
        let today = calendar.startOfDay(for: .now)
        let dates = (0..<5).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }

        return [
            EventRecord(
                title: "Coffee with Riley",
                timestamp: dates[0].addingTimeInterval(9 * 3600),
                location: "Juniper Cafe",
                notes: "Try the seasonal roast"
            ),
            EventRecord(
                title: "Studio Session",
                timestamp: dates[1].addingTimeInterval(19 * 3600),
                location: "South Loft",
                notes: "Bring pedal board"
            ),
            EventRecord(
                title: "Newsletter planning",
                timestamp: dates[2].addingTimeInterval(13 * 3600),
                notes: "Outline April issue"
            ),
            EventRecord(
                title: "Pickleball",
                timestamp: dates[3].addingTimeInterval(17 * 3600 + 1800),
                location: "East Courts"
            ),
            EventRecord(
                title: "Family dinner",
                timestamp: dates[4].addingTimeInterval(18 * 3600),
                notes: "Host dessert"
            ),
            EventRecord(
                title: "All-day planning",
                timestamp: dates[2],
                notes: "Focus block",
                includesTime: false
            )
        ]
    }
}
