import Foundation
import Observation

@Observable
final class AgendaDataStore {
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

    func deleteEvents(at offsets: IndexSet) {
        let ids = offsets.map { events[$0].id }
        events.removeAll { ids.contains($0.id) }
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
    }

    func updateRecurring(_ event: RecurringEvent) {
        guard let index = recurringEvents.firstIndex(where: { $0.id == event.id }) else { return }
        recurringEvents[index] = event
    }

    func deleteRecurring(_ event: RecurringEvent) {
        recurringEvents.removeAll { $0.id == event.id }
    }

    func deleteRecurring(at offsets: IndexSet) {
        let ids = offsets.map { recurringEvents[$0].id }
        recurringEvents.removeAll { ids.contains($0.id) }
    }

    func duplicateRecurring(_ event: RecurringEvent) {
        var clone = event
        clone.id = UUID()
        if let index = recurringEvents.firstIndex(where: { $0.id == event.id }) {
            recurringEvents.insert(clone, at: index + 1)
        } else {
            recurringEvents.append(clone)
        }
    }

    func moveRecurring(from offsets: IndexSet, to destination: Int) {
        recurringEvents.move(fromOffsets: offsets, toOffset: destination)
    }

    func dailyRefresh(referenceDate: Date, purgePastEvents: Bool, decrementRecurrences: Bool = true, calendar: Calendar = .current) {
        let startOfDay = calendar.startOfDay(for: referenceDate)
        let previousDay = calendar.date(byAdding: .day, value: -1, to: startOfDay) ?? startOfDay

        if purgePastEvents {
            events.removeAll { calendar.startOfDay(for: $0.date) < startOfDay }
        }

        recurringEvents = recurringEvents.compactMap { event in
            var updatedEvent = event

            if let stopCondition = event.stopCondition {
                switch stopCondition {
                case let .endDate(date):
                    // Respect the decrementRecurrences toggle for endDate-based stop conditions.
                    // When the toggle is disabled we should not auto-delete recurring events
                    // even if their end date has passed.
                    if decrementRecurrences {
                        if calendar.startOfDay(for: date) < startOfDay {
                            return nil
                        }
                    }
                case let .occurrenceCount(remaining):
                    if remaining <= 0 {
                        return nil
                    }

                    if decrementRecurrences {
                        if event.occurs(on: previousDay, calendar: calendar) {
                            let next = max(remaining - 1, 0)
                            if next == 0 {
                                return nil
                            }
                            updatedEvent.stopCondition = .occurrenceCount(next)
                        }
                    }
                    // if decrementRecurrences is false, leave remaining unchanged
                }
            }

            return updatedEvent
        }

        sortEvents()
    }
}
