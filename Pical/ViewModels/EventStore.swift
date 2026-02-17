import Foundation
import Observation

@Observable
final class EventStore {
    private(set) var events: [PicalEvent]
    private(set) var recurringEvents: [RecurringEvent]

    init(events: [PicalEvent] = PicalEvent.sampleData(), recurringEvents: [RecurringEvent] = RecurringEvent.sampleData()) {
        self.events = events.sorted { $0.date < $1.date }
        self.recurringEvents = recurringEvents
    }

    // MARK: - Agenda events

    func addEvent(_ event: PicalEvent) {
        events.append(event)
        sortEvents()
    }

    func updateEvent(_ event: PicalEvent) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
        events[index] = event
        sortEvents()
    }

    func deleteEvent(_ event: PicalEvent) {
        events.removeAll { $0.id == event.id }
    }

    func duplicateEvent(_ event: PicalEvent) {
        var clone = event
        clone.id = UUID()
        addEvent(clone)
    }

    private func sortEvents() {
        events.sort { lhs, rhs in
            if lhs.date == rhs.date {
                switch (lhs.endDate, rhs.endDate) {
                case let (lhsEnd?, rhsEnd?):
                    return lhsEnd < rhsEnd
                case (.some, .none):
                    return true
                case (.none, .some):
                    return false
                default:
                    return lhs.title < rhs.title
                }
            }
            return lhs.date < rhs.date
        }
    }

    // MARK: - Recurring events

    func addRecurring(_ event: RecurringEvent) {
        recurringEvents.append(event)
        sortRecurringEvents()
    }

    func updateRecurring(_ event: RecurringEvent) {
        guard let index = recurringEvents.firstIndex(where: { $0.id == event.id }) else { return }
        recurringEvents[index] = event
        sortRecurringEvents()
    }

    func deleteRecurring(_ event: RecurringEvent) {
        recurringEvents.removeAll { $0.id == event.id }
    }

    private func sortRecurringEvents() {
        recurringEvents.sort { lhs, rhs in
            lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        }
    }
}
