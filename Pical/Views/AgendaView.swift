import SwiftUI

struct AgendaView: View {
    @StateObject var store: EventStore
    @State private var editor: EditorPresentation?

    var body: some View {
        NavigationStack {
            Group {
                if store.isLoaded {
                    if store.events.isEmpty {
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
            ForEach(store.agendaSections()) { section in
                AgendaSectionView(section: section, onSelect: { occurrence in
                    if let event = store.event(id: occurrence.eventID) {
                        editor = .init(mode: .edit, event: event)
                    }
                })
            }
        }
        .listStyle(.insetGrouped)
    }

    private func presentNewEvent() {
        editor = .init(mode: .create, event: EventRecord(title: "New event", timestamp: .now))
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
