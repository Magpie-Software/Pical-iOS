import Testing
@testable import Pical

@MainActor
struct PicalTests {

    @Test func weeklyOccurrenceExpandsWithinRange() throws {
        let calendar = Calendar(identifier: .gregorian)
        let start = calendar.startOfDay(for: .now)
        guard let timestamp = calendar.date(byAdding: .day, value: -7, to: start) else {
            Issue.record("Failed to build timestamp for test")
            return
        }

        let record = EventRecord(
            title: "Guitar lesson",
            timestamp: timestamp,
            recurrence: .weekly
        )

        guard let upper = calendar.date(byAdding: .day, value: 7, to: start) else {
            Issue.record("Failed to build end date for test")
            return
        }

        let occurrences = record.occurrences(in: start...upper, calendar: calendar)
        #expect(occurrences.count == 2)
        #expect(occurrences.first?.startDate == start)
    }

    @Test func storePersistsChangesInMemory() async throws {
        let persistence = EventPersistence.inMemory()
        let store = EventStore(persistence: persistence)
        let record = EventRecord(title: "Planning session", timestamp: .now)

        await store.upsert(record)
        #expect(store.events.count == 1)

        try await persistence.save(store.events)
        let reloaded = try await persistence.load()
        #expect(reloaded == store.events)
    }
}
