import SwiftUI

struct AgendaView: View {
    @Environment(EventStore.self) private var store
    @State private var selectedEvent: PicalEvent?
    @State private var editingEvent: PicalEvent?
    @State private var isPresentingNewEvent = false
    @State private var editMode: EditMode = .inactive

    @AppStorage(SettingsKeys.agendaDateHeaders) private var useDateHeaders = false
    @AppStorage(SettingsKeys.smartAgendaGrouping) private var useSmartGrouping = true

    var body: some View {
        NavigationStack {
            Group {
                if store.events.isEmpty {
                    ContentUnavailableView("No events yet", systemImage: "calendar.badge.plus", description: Text("Start by adding something you care about."))
                } else {
                    agendaList
                }
            }
            .navigationTitle("Agenda")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if allowsBatchEditing {
                        Button(editMode.isEditingList ? "Done" : "Manage") {
                            editMode = editMode.isEditingList ? .inactive : .active
                        }
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isPresentingNewEvent = true
                    } label: {
                        Label("Add event", systemImage: "plus")
                    }
                }
            }
            .sheet(item: $selectedEvent) { event in
                EventDetailView(eventID: event.id)
                    .presentationDetents([.medium, .large])
            }
            .sheet(item: $editingEvent) { event in
                EventFormView(event: event) { updated in
                    store.updateEvent(updated)
                }
            }
            .sheet(isPresented: $isPresentingNewEvent) {
                EventFormView(event: nil) { newEvent in
                    store.addEvent(newEvent)
                }
            }
        }
    }

    private var agendaList: some View {
        List {
            if displaySections.isEmpty {
                emptySection
            } else {
                ForEach(displaySections) { section in
                    Section {
                        ForEach(section.events) { event in
                            AgendaRowView(event: event, layout: .fullWidth)
                                .contentShape(Rectangle())
                                .onTapGesture { selectedEvent = event }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    editButtons(for: event)
                                }
                        }
                    } header: {
                        sectionHeader(for: section)
                    }
                }
            }
        }
        .listStyle(useDateHeaders || useSmartGrouping ? .insetGrouped : .plain)
        .environment(\.editMode, $editMode)
    }

    private var emptySection: some View {
        ForEach(store.events) { event in
            AgendaRowView(event: event)
                .contentShape(Rectangle())
                .onTapGesture { selectedEvent = event }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    editButtons(for: event)
                }
        }
        .onDelete { indices in
            store.deleteEvents(at: indices)
        }
    }

    private func editButtons(for event: PicalEvent) -> some View {
        Group {
            Button {
                editingEvent = event
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)

            Button {
                store.duplicateEvent(event)
            } label: {
                Label("Duplicate", systemImage: "plus.square.on.square")
            }
            .tint(.indigo)

            Button(role: .destructive) {
                store.deleteEvent(event)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private var allowsBatchEditing: Bool {
        !(useDateHeaders || useSmartGrouping)
    }

    private var displaySections: [AgendaSectionDisplay] {
        if useSmartGrouping {
            return SmartAgendaSection.build(from: store.events)
        } else if useDateHeaders {
            return DateAgendaSection.build(from: store.events)
        } else {
            return []
        }
    }

    private func sectionHeader(for section: AgendaSectionDisplay) -> some View {
        switch section.style {
        case let .date(date):
            DateRibbonView(date: date)
        case let .smart(title):
            Text(title)
                .font(.headline)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
        }
    }
}

private struct AgendaSectionDisplay: Identifiable {
    enum Style {
        case date(Date)
        case smart(String)
    }

    let id = UUID()
    let style: Style
    let events: [PicalEvent]
}

private enum SmartAgendaSection: CaseIterable {
    case past
    case today
    case thisWeek
    case nextWeek
    case later

    var title: String {
        switch self {
        case .past: "Earlier"
        case .today: "Today"
        case .thisWeek: "This Week"
        case .nextWeek: "Next Week"
        case .later: "Later"
        }
    }

    static func build(from events: [PicalEvent], calendar: Calendar = .current) -> [AgendaSectionDisplay] {
        let today = calendar.startOfDay(for: Date())
        let nextWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: today) ?? today

        var buckets: [SmartAgendaSection: [PicalEvent]] = [:]

        for event in events {
            let eventDay = calendar.startOfDay(for: event.date)
            let section: SmartAgendaSection

            if eventDay < today {
                section = .past
            } else if calendar.isDate(eventDay, inSameDayAs: today) {
                section = .today
            } else if calendar.isDate(eventDay, equalTo: today, toGranularity: .weekOfYear) {
                section = .thisWeek
            } else if calendar.isDate(eventDay, equalTo: nextWeekStart, toGranularity: .weekOfYear) {
                section = .nextWeek
            } else {
                section = .later
            }

            buckets[section, default: []].append(event)
        }

        return SmartAgendaSection.allCases.compactMap { section in
            guard let events = buckets[section]?.sorted(by: { $0.date < $1.date }) else { return nil }
            return AgendaSectionDisplay(style: .smart(section.title), events: events)
        }
    }
}

private enum DateAgendaSection {
    static func build(from events: [PicalEvent], calendar: Calendar = .current) -> [AgendaSectionDisplay] {
        let grouped = Dictionary(grouping: events) { event in
            calendar.startOfDay(for: event.date)
        }

        return grouped.keys.sorted().map { date in
            let events = grouped[date]?.sorted(by: { $0.date < $1.date }) ?? []
            return AgendaSectionDisplay(style: .date(date), events: events)
        }
    }
}

#Preview {
    AgendaView()
        .environment(EventStore())
}
