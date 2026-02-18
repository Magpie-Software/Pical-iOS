import Foundation

struct EventOccurrence: Identifiable, Hashable {
    let id: String
    let eventID: UUID
    let startDate: Date
    let title: String
    let location: String?
    let notes: String?
    let isRecurring: Bool

    init(event: EventRecord, occurrenceDate: Date, isRecurring: Bool) {
        self.id = "\(event.id.uuidString)-\(occurrenceDate.timeIntervalSinceReferenceDate)"
        self.eventID = event.id
        self.startDate = occurrenceDate
        self.title = event.title
        self.location = event.location
        self.notes = event.notes
        self.isRecurring = isRecurring
    }
}

struct AgendaSection: Identifiable, Hashable {
    let date: Date
    let events: [EventOccurrence]

    var id: Date { date }
}
