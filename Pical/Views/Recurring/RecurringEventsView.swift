import SwiftUI

struct RecurringEventsView: View {
    @Environment(AgendaDataStore.self) private var store
    @State private var editingEvent: RecurringEvent?
    @State private var selectedEvent: RecurringEvent?
    @State private var isPresentingNew = false
    @State private var editMode: EditMode = .inactive

    @AppStorage(SettingsKeys.recurringWeekdayGrouping) private var groupByWeekday = true

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
            .navigationBarTitleDisplayMode(.large)
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
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .accessibilityLabel("Add recurring")
                }
            }
            .sheet(item: $selectedEvent) { event in
                RecurringEventDetailView(eventID: event.id)
                    .presentationDetents([.large])
                    .presentationBackgroundInteraction(.enabled)
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
                    Section(header: Text(section.title)
                                .font(.headline)
                                .textCase(.uppercase)
                                .foregroundStyle(.secondary)) {
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
                .onMove { indices, newOffset in
                    store.moveRecurring(from: indices, to: newOffset)
                }
            }
        }
        .environment(\.editMode, $editMode)
        .applyRecurringListStyle(groupByWeekday)
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
        var sections: [RecurringWeekdaySection] = []

        for day in Weekday.allCases {
            let dayEvents = events.filter {
                if case .weekly(day) = $0.pattern {
                    return true
                }
                return false
            }

            if !dayEvents.isEmpty {
                sections.append(RecurringWeekdaySection(title: day.label, events: dayEvents))
            }
        }

        let monthlyOrdinal = events.compactMap { event -> (RecurringEvent, Int, Int)? in
            if case let .monthlyOrdinal(ordinal, day) = event.pattern {
                return (event, day.rawValue, ordinal.rawValue)
            }
            return nil
        }
        .sorted { lhs, rhs in
            if lhs.1 == rhs.1 {
                return lhs.2 < rhs.2
            }
            return lhs.1 < rhs.1
        }
        .map { $0.0 }

        if !monthlyOrdinal.isEmpty {
            sections.append(RecurringWeekdaySection(title: "Monthly (Weekday order)", events: monthlyOrdinal))
        }

        let monthlyDate = events.compactMap { event -> (RecurringEvent, Int)? in
            if case let .monthlyDate(day) = event.pattern {
                return (event, day)
            }
            return nil
        }
        .sorted { $0.1 < $1.1 }
        .map { $0.0 }

        if !monthlyDate.isEmpty {
            sections.append(RecurringWeekdaySection(title: "Monthly (Specific dates)", events: monthlyDate))
        }

        return sections
    }
}

private extension View {
    @ViewBuilder
    func applyRecurringListStyle(_ useInsetGrouped: Bool) -> some View {
        if useInsetGrouped {
            listStyle(.insetGrouped)
        } else {
            listStyle(.plain)
        }
    }
}

#Preview {
    RecurringEventsView()
        .environment(AgendaDataStore())
}
