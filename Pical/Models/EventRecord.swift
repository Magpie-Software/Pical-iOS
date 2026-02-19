import Foundation

struct EventRecord: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var timestamp: Date
    var location: String?
    var notes: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        timestamp: Date,
        location: String? = nil,
        notes: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.timestamp = timestamp
        self.location = location
        self.notes = notes
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

    func occurrence(in range: ClosedRange<Date>, calendar: Calendar = .autoupdatingCurrent) -> EventOccurrence? {
        guard range.contains(timestamp) else { return nil }
        return EventOccurrence(event: self, occurrenceDate: timestamp, isRecurring: false)
    }
}
