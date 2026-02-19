import SwiftUI

struct RecurringEventsView: View {
    @Environment(AgendaDataStore.self) private var store
    @State private var editingEvent: RecurringEvent?
    @State private var selectedEvent: RecurringEvent?
    @State private var isPresentingNew = false
    @State private var editMode: EditMode = .inactive

    @AppStorage(SettingsKeys.recurringWeekdayGrouping) private var groupByWeekday = false

    var body: some View {
        NavigationStack {
            Group {
                if store.recurringEvents.isEmpty {
                    ContentUnavailableView("No recurring patterns", systemImage: "repeat", description: Text("Document your weekly/monthly rhythms here."))
                } else {
                    recurringList
                }
            }
            .navigationTitle("Recurring")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !groupByWeekday {
                        Button(editMode.isEditingList ? "Done" : "Manage") {
                            editMode = editMode.isEditingList ? .inactive : .active
                        }
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isPresentingNew = true
                    } label: {
                        Label("Add recurring", systemImage: "plus")
                    }
                }
            }
            .sheet(item: $selectedEvent) { event in
                RecurringEventDetailView(eventID: event.id)
                    .presentationDetents([.medium, .large])
            }
            .sheet(item: $editingEvent) { event in
                RecurringEventFormView(event: event) { updated in
                    store.updateRecurring(updated)
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $isPresentingNew) {
                RecurringEventFormView(event: nil) { newEvent in
                    store.addRecurring(newEvent)
                }
            }
        }
    }

    private var recurringList: some View {
        List {
            if groupByWeekday {
                ForEach(RecurringWeekdaySection.build(from: store.recurringEvents)) { section in
                    Section(header: Text(section.title)) {
                        ForEach(section.events) { event in
                            recurringRow(for: event)
                        }
                    }
                }
            } else {
                ForEach(store.recurringEvents) { event in
                    recurringRow(for: event)
                }
                .onDelete { indices in
                    store.deleteRecurring(at: indices)
                }
            }
        }
        .listStyle(groupByWeekday ? .insetGrouped : .plain)
        .environment(\.editMode, $editMode)
    }

    private func recurringRow(for event: RecurringEvent) -> some View {
        RecurringEventRowView(event: event)
            .contentShape(Rectangle())
            .onTapGesture { selectedEvent = event }
            .swipeActions(allowsFullSwipe: false) {
                Button {
                    editingEvent = event
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .tint(.blue)

                Button {
                    store.duplicateRecurring(event)
                } label: {
                    Label("Duplicate", systemImage: "plus.square.on.square")
                }
                .tint(.indigo)

                Button(role: .destructive) {
                    store.deleteRecurring(event)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
    }
}

private struct RecurringWeekdaySection: Identifiable {
    let id = UUID()
    let title: String
    let events: [RecurringEvent]

    static func build(from events: [RecurringEvent]) -> [RecurringWeekdaySection] {
        let grouped = Dictionary(grouping: events) { event in
            event.pattern.groupingKey
        }

        return grouped.keys.sorted(by: { $0.sortIndex < $1.sortIndex }).map { key in
            RecurringWeekdaySection(title: key.title, events: grouped[key] ?? [])
        }
    }
}

#Preview {
    RecurringEventsView()
        .environment(AgendaDataStore())
}
