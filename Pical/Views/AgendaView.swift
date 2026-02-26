import SwiftUI

struct AgendaView: View {
    @StateObject var store: EventStore
    @State private var editor: EditorPresentation?
    @State private var selectedEvent: SelectedEvent?
    @AppStorage(SettingsKeys.smartAgendaGrouping) private var smartAgendaGrouping = true
    @State private var selectedOccurrence: EventOccurrence?
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            Group {
                if store.isLoaded {
                    if sections.isEmpty {
                        EmptyAgendaView(addAction: presentNewEvent)
                    } else {
                        agendaList
                    }
                } else {
                    ProgressView("Loading events…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Agenda")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: presentNewEvent) {
                        Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    }
                    .accessibilityLabel("Add event")
                }
            }
            .task {
                if !store.isLoaded {
                    await store.refresh()
                }
            }
            .sheet(item: $editor) { editor in
                EventEditorView(
                    event: editor.event,
                    mode: editor.mode.editorMode,
                    onSave: { updated in
                        await store.upsert(updated)
                    },
                    onDelete: { id in
                        await store.delete(eventID: id)
                    }
                )
            }
            .sheet(item: $selectedEvent) { selection in
                if let event = store.event(id: selection.id) {
                    AgendaEventDetailView(
                        event: event,
                        onEdit: { presentEditor(for: event) },
                        onDuplicate: { duplicate(event: event) },
                        onDelete: { delete(event: event) }
                    )
                } else {
                    ContentUnavailableView("Event removed", systemImage: "calendar.badge.exclamationmark", description: Text("It might have been deleted."))
                }
            }
        }
        .background(colorScheme == .light ? Theme.background.ignoresSafeArea() : Color.clear)
        .toolbarBackground(colorScheme == .light ? Theme.background : Color.clear, for: .navigationBar)
        .toolbarBackground(colorScheme == .light ? Theme.background : Color.clear, for: .tabBar)
        .alert(textBinding: $store.lastError)
        .onChange(of: store.events) { _ in
            if let selection = selectedEvent, store.event(id: selection.id) == nil {
                selectedEvent = nil
            }
        }
    }

    private var agendaList: some View {
        List {
            ForEach(sections) { section in
                Section {
                    ForEach(section.events) { occurrence in
                        agendaRow(for: occurrence)
                    }
                } header: {
                    header(for: section)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var sections: [AgendaDisplaySection] {
        if smartAgendaGrouping {
            return AgendaSmartSection.build(from: store.occurrences())
        } else {
            return store.agendaSections().map { AgendaDisplaySection(style: .date($0.date), events: $0.events) }
        }
    }

    @ViewBuilder
    private func header(for section: AgendaDisplaySection) -> some View {
        switch section.style {
        case let .date(date):
            DateRibbonView(date: date)
        case let .smart(smart):
            Text(smart.title)
                .font(.headline)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func agendaRow(for occurrence: EventOccurrence) -> some View {
        if let event = store.event(id: occurrence.eventID) {
            EventRowView(occurrence: occurrence, showDateLabel: smartAgendaGrouping)
                .contentShape(Rectangle())
                .onTapGesture { selectedEvent = SelectedEvent(id: event.id) }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        presentEditor(for: event)
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)

                    Button {
                        duplicate(event: event)
                    } label: {
                        Label("Duplicate", systemImage: "plus.square.on.square")
                    }
                    .tint(.indigo)

                    Button(role: .destructive) {
                        delete(event: event)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
        }
    }

    private func presentEditor(for event: EventRecord) {
        editor = .init(mode: .edit, event: event)
    }

    private func duplicate(event: EventRecord) {
        var copy = event
        copy.id = UUID()
        copy.createdAt = .now
        copy.updatedAt = .now
        Task { await store.upsert(copy) }
    }

    private func delete(event: EventRecord) {
        Task {
            await store.delete(eventID: event.id)
            if selectedEvent?.id == event.id {
                selectedEvent = nil
            }
        }
    }

    private func presentNewEvent() {
        editor = .init(mode: .create, event: EventRecord(title: "New event", timestamp: .now))
    }
}

private struct AgendaDisplaySection: Identifiable {
    enum Style {
        case date(Date)
        case smart(AgendaSmartSection)
    }

    let id = UUID()
    let style: Style
    let events: [EventOccurrence]
}

private enum AgendaSmartSection: CaseIterable {
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

    static func build(from occurrences: [EventOccurrence], calendar: Calendar = .autoupdatingCurrent) -> [AgendaDisplaySection] {
        let today = calendar.startOfDay(for: .now)
        let nextWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: today) ?? today

        var buckets: [AgendaSmartSection: [EventOccurrence]] = [:]

        for occurrence in occurrences {
            let eventDay = calendar.startOfDay(for: occurrence.startDate)
            let section: AgendaSmartSection

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

            buckets[section, default: []].append(occurrence)
        }

        return AgendaSmartSection.allCases.compactMap { section in
            guard let events = buckets[section]?.sorted(by: { $0.startDate < $1.startDate }) else { return nil }
            return AgendaDisplaySection(style: .smart(section), events: events)
        }
    }
}

private extension AgendaView {
    struct SelectedEvent: Identifiable {
        let id: EventRecord.ID
    }

    struct EditorPresentation: Identifiable {
        enum Mode {
            case create
            case edit

            var editorMode: EventEditorView.Mode {
                switch self {
                case .create: .create
                case .edit: .edit
                }
            }
        }

        let mode: Mode
        var event: EventRecord
        var id: UUID { event.id }
    }
}

#Preview {
    AgendaView(store: .preview)
}
