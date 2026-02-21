import Foundation

/// Lightweight JSON persistence for Pical's local data.
/// Writes two files into Application Support:
///   - Pical/events.json  (stores [EventRecord])
///   - Pical/recurring.json (stores [RecurringEvent])
struct PicalPersistence {

    // MARK: - Storage URL

    private static var storeDirectory: URL {
        let base = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return base.appendingPathComponent("Pical", isDirectory: true)
    }

    static var eventsURL: URL {
        storeDirectory.appendingPathComponent("events.json")
    }

    static var recurringURL: URL {
        storeDirectory.appendingPathComponent("recurring.json")
    }

    // MARK: - Encoding

    private static var encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        return e
    }()

    private static var decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    // MARK: - Load

    /// Load persisted EventRecord entries. If the file contains legacy PicalEvent
    /// objects, attempt a migration by decoding PicalEvent and mapping to EventRecord.
    static func loadEvents() -> [EventRecord] {
        guard FileManager.default.fileExists(atPath: eventsURL.path) else { return [] }
        do {
            let data = try Data(contentsOf: eventsURL)

            // First, try the new shape (EventRecord)
            if let records = try? decoder.decode([EventRecord].self, from: data) {
                return records
            }

            // Fallback: try legacy PicalEvent shape and convert
            if let legacy = try? decoder.decode([LegacyPicalEvent].self, from: data) {
                return legacy.map { p in
                    EventRecord(
                        id: p.id,
                        title: p.title,
                        timestamp: p.date,
                        location: p.location,
                        notes: p.notes,
                        includesTime: p.includesTime,
                        createdAt: Date(),
                        updatedAt: Date()
                    )
                }
            }

            // If decoding failed, return empty to avoid crashing.
            return []
        } catch {
            return []
        }
    }

    static func loadRecurring() -> [RecurringEvent] {
        guard FileManager.default.fileExists(atPath: recurringURL.path) else { return [] }
        do {
            let data = try Data(contentsOf: recurringURL)
            return (try? decoder.decode([RecurringEvent].self, from: data)) ?? []
        } catch {
            return []
        }
    }

    // MARK: - Save

    static func save(events: [EventRecord]) {
        write(events, to: eventsURL)
    }

    static func save(recurring: [RecurringEvent]) {
        write(recurring, to: recurringURL)
    }

    // MARK: - Private helpers

    private static func write<T: Encodable>(_ value: T, to url: URL) {
        do {
            let dir = url.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: dir,
                                                    withIntermediateDirectories: true)
            let data = try encoder.encode(value)
            try data.write(to: url, options: .atomic)
        } catch {
            // Persistence failures are non-fatal; in-memory state is authoritative.
        }
    }
}

// MARK: - Legacy types

private struct LegacyPicalEvent: Codable {
    var id: UUID
    var title: String
    var date: Date
    var endDate: Date?
    var includesTime: Bool
    var location: String?
    var notes: String?
}

