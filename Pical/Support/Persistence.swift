import Foundation

/// Lightweight JSON persistence for Pical's local data.
/// Writes two files into Application Support:
///   - Pical/events.json
///   - Pical/recurring.json
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

    static func loadEvents() -> [PicalEvent] {
        guard FileManager.default.fileExists(atPath: eventsURL.path) else { return [] }
        do {
            let data = try Data(contentsOf: eventsURL)
            return try decoder.decode([PicalEvent].self, from: data)
        } catch {
            // Corrupt or incompatible file — start fresh rather than crashing.
            return []
        }
    }

    static func loadRecurring() -> [RecurringEvent] {
        guard FileManager.default.fileExists(atPath: recurringURL.path) else { return [] }
        do {
            let data = try Data(contentsOf: recurringURL)
            return try decoder.decode([RecurringEvent].self, from: data)
        } catch {
            return []
        }
    }

    // MARK: - Save

    static func save(events: [PicalEvent]) {
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
