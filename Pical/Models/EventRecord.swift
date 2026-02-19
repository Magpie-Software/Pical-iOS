import Foundation

struct EventRecord: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var timestamp: Date
    var location: String?
    var notes: String?
    var includesTime: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        timestamp: Date,
        location: String? = nil,
        notes: String? = nil,
        includesTime: Bool = true,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.timestamp = timestamp
        self.location = location
        self.notes = notes
        self.includesTime = includesTime
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, timestamp, location, notes, includesTime, createdAt, updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        includesTime = try container.decodeIfPresent(Bool.self, forKey: .includesTime) ?? true
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encode(includesTime, forKey: .includesTime)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
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
        return EventOccurrence(event: self, occurrenceDate: timestamp, isRecurring: false, hasExplicitTime: includesTime)
    }
}
