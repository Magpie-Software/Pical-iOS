import SwiftUI

struct AgendaView: View {
    @StateObject var store: EventStore
    @State private var editor: EditorPresentation?
    @AppStorage(SettingsKeys.smartAgendaGrouping) private var smartAgendaGrouping = false

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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: presentNewEvent) {
                        Image(systemName: "plus")
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
        }
        .alert(textBinding: $store.lastError)
    }

    private var agendaList: some View {
        List {
            ForEach(sections) { section in
                Section {
                    ForEach(section.events) { occurrence in
                        EventRowView(occurrence: occurrence, showDateLabel: smartAgendaGrouping)
                            .contentShape(Rectangle())
                            .onTapGesture { presentEditor(for: occurrence) }
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

    private func presentEditor(for occurrence: EventOccurrence) {
        guard let event = store.event(id: occurrence.eventID) else { return }
        editor = .init(mode: .edit, event: event)
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
