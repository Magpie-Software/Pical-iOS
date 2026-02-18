import Foundation

struct PicalEvent: Identifiable, Equatable, Hashable {
    var id: UUID = UUID()
    var title: String
    var date: Date
    var endDate: Date?
    var includesTime: Bool
    var location: String?
    var notes: String?

    init(id: UUID = UUID(), title: String, date: Date, endDate: Date? = nil, includesTime: Bool = true, location: String? = nil, notes: String? = nil) {
        self.id = id
        self.title = title
        self.date = date
        self.endDate = endDate
        self.includesTime = includesTime
        self.location = location
        self.notes = notes
    }
}

extension PicalEvent {
    static func sampleData(calendar: Calendar = .current) -> [PicalEvent] {
        let today = calendar.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"

        return [
            PicalEvent(title: "Breakfast with Jules",
                       date: formatter.date(from: "2026/02/17 08:30") ?? today,
                       endDate: formatter.date(from: "2026/02/17 09:15"),
                       includesTime: true,
                       location: "Cornerstone Cafe",
                       notes: "Bring pen + notebook"),
            PicalEvent(title: "Design sprint prep",
                       date: formatter.date(from: "2026/02/17 11:00") ?? today,
                       endDate: formatter.date(from: "2026/02/17 12:00"),
                       includesTime: true,
                       location: "Studio",
                       notes: nil),
            PicalEvent(title: "Groceries + errand loop",
                       date: formatter.date(from: "2026/02/18 00:00") ?? today,
                       includesTime: false,
                       location: "Whole Foods / UPS",
                       notes: "Restock espresso beans"),
            PicalEvent(title: "Workout",
                       date: formatter.date(from: "2026/02/19 17:30") ?? today,
                       endDate: formatter.date(from: "2026/02/19 18:30"),
                       includesTime: true,
                       location: "Garage gym",
                       notes: "Push session"),
            PicalEvent(title: "Family dinner extremely long title that should truncate nicely",
                       date: formatter.date(from: "2026/02/20 19:00") ?? today,
                       includesTime: true,
                       location: "Kitchen with a location name that will also truncate gracefully",
                       notes: "Plan menu Friday morning")
        ]
    }
}
