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
        // If the recurring event has an end date in the past and auto-purge is enabled,
        // do not add it (mirror the agenda one-off behavior).
        if let stop = event.stopCondition {
            switch stop {
            case let .endDate(date):
                let startOfDay = Calendar.current.startOfDay(for: Date())
                if UserDefaults.standard.bool(forKey: SettingsKeys.autoPurgePastEvents) {
                    if Calendar.current.startOfDay(for: date) < startOfDay {
                        return
                    }
                }
            default:
                break
            }
        }

        recurringEvents.append(event)

        // Ensure immediate purge/refresh so changes to end dates are reflected instantly
        Task {
            await MainActor.run {
                let purge = UserDefaults.standard.bool(forKey: SettingsKeys.autoPurgePastEvents)
                self.dailyRefresh(referenceDate: Date(), purgePastEvents: purge, calendar: .current)
            }
        }
    }

    func updateRecurring(_ event: RecurringEvent) {
        // Mirror addRecurring: if updated event now has an endDate in the past and auto-purge
        // is enabled, remove it instead of updating.
        if let stop = event.stopCondition {
            switch stop {
            case let .endDate(date):
                let startOfDay = Calendar.current.startOfDay(for: Date())
                if UserDefaults.standard.bool(forKey: SettingsKeys.autoPurgePastEvents) {
                    if Calendar.current.startOfDay(for: date) < startOfDay {
                        deleteRecurring(event)
                        return
                    }
                }
            default:
                break
            }
        }

        guard let index = recurringEvents.firstIndex(where: { $0.id == event.id }) else { return }
        recurringEvents[index] = event

        // Ensure immediate purge/refresh so changes to end dates are reflected instantly
        Task {
            await MainActor.run {
                let purge = UserDefaults.standard.bool(forKey: SettingsKeys.autoPurgePastEvents)
                self.dailyRefresh(referenceDate: Date(), purgePastEvents: purge, calendar: .current)
            }
        }
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

    func dailyRefresh(referenceDate: Date, purgePastEvents: Bool, calendar: Calendar = .current) {
        let startOfDay = calendar.startOfDay(for: referenceDate)

        if purgePastEvents {
            events.removeAll { calendar.startOfDay(for: $0.date) < startOfDay }
        }

        recurringEvents = recurringEvents.compactMap { event in
            var updatedEvent = event

            if let stopCondition = event.stopCondition {
                switch stopCondition {
                case let .endDate(date):
                    // Remove recurring events whose end date is in the past when purgePastEvents (auto-clear) is enabled.
                    if purgePastEvents {
                        if calendar.startOfDay(for: date) < startOfDay {
                            return nil
                        }
                    }
                case let .occurrenceCount(remaining):
                    // Do not auto-decrement occurrence counts in this version. Only remove if count already <= 0.
                    if remaining <= 0 {
                        return nil
                    }
                    // if decrementRecurrences is false, leave remaining unchanged
                }
            }

            return updatedEvent
        }

        sortEvents()
    }
}
