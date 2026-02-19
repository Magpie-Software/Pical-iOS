import Foundation
import SwiftUI

@MainActor
final class EventStore: ObservableObject {
    @Published private(set) var events: [EventRecord] = []
    @Published var lastError: String?
    @Published private(set) var isLoaded = false

    private let persistence: EventPersistence

    init(persistence: EventPersistence = .live) {
        self.persistence = persistence
    }

    func refresh() async {
        do {
            let loaded = try await persistence.load()
            events = loaded.sorted(by: { $0.timestamp < $1.timestamp })
            isLoaded = true
        } catch {
            lastError = error.localizedDescription
        }
    }

    func upsert(_ event: EventRecord) async {
        var snapshot = events
        if let index = snapshot.firstIndex(where: { $0.id == event.id }) {
            snapshot[index] = event
        } else {
            snapshot.append(event)
        }
        snapshot.sort(by: { $0.timestamp < $1.timestamp })
        events = snapshot
        await persist()
    }

    func delete(eventID: UUID) async {
        events.removeAll { $0.id == eventID }
        await persist()
    }

    func event(id: UUID) -> EventRecord? {
        events.first { $0.id == id }
    }

    func occurrences(daysAhead: Int = 21, calendar: Calendar = .autoupdatingCurrent) -> [EventOccurrence] {
        let start = calendar.startOfDay(for: .now)
        guard let end = calendar.date(byAdding: .day, value: daysAhead, to: start) else { return [] }
        let range = start...end
        return events
            .compactMap { $0.occurrence(in: range, calendar: calendar) }
            .sorted(by: { $0.startDate < $1.startDate })
    }

    func agendaSections(daysAhead: Int = 21, calendar: Calendar = .autoupdatingCurrent) -> [AgendaSection] {
        let grouped = Dictionary(grouping: occurrences(daysAhead: daysAhead, calendar: calendar)) { occurrence in
            calendar.startOfDay(for: occurrence.startDate)
        }
        return grouped
            .keys
            .sorted()
            .map { date in
                AgendaSection(date: date, events: grouped[date] ?? [])
            }
    }

    private func persist() async {
        do {
            try await persistence.save(events)
        } catch {
            lastError = error.localizedDescription
        }
    }
}

actor EventPersistence {
    enum Storage {
        case disk(URL)
        case memory([EventRecord])
    }

    private var storage: Storage

    init(storage: Storage) {
        self.storage = storage
    }

    func load() throws -> [EventRecord] {
        switch storage {
        case .disk(let url):
            let manager = FileManager.default
            if !manager.fileExists(atPath: url.path) {
                return []
            }
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([EventRecord].self, from: data)
        case .memory(let events):
            return events
        }
    }

    func save(_ events: [EventRecord]) throws {
        switch storage {
        case .disk(let url):
            let manager = FileManager.default
            let directory = url.deletingLastPathComponent()
            if !manager.fileExists(atPath: directory.path) {
                try manager.createDirectory(at: directory, withIntermediateDirectories: true)
            }
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(events)
            try data.write(to: url, options: .atomic)
        case .memory:
            storage = .memory(events)
        }
    }
}

extension EventPersistence {
    static let live: EventPersistence = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let url = base.appendingPathComponent("Pical").appendingPathComponent("events.json")
        return EventPersistence(storage: .disk(url))
    }()

    static func inMemory(_ events: [EventRecord] = []) -> EventPersistence {
        EventPersistence(storage: .memory(events))
    }
}

extension EventStore {
    static var preview: EventStore {
        EventStore(persistence: .inMemory(EventRecord.samples))
    }
}
