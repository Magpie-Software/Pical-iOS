import SwiftUI

struct AgendaView: View {
    @Environment(EventStore.self) private var store
    @State private var selectedEvent: PicalEvent?
    @State private var editingEvent: PicalEvent?
    @State private var isPresentingNewEvent = false
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationStack {
            Group {
                if store.events.isEmpty {
                    ContentUnavailableView("No events yet", systemImage: "calendar.badge.plus", description: Text("Start by adding something you care about."))
                } else {
                    List {
                        ForEach(store.events) { event in
                            AgendaRowView(event: event)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedEvent = event
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
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
                        .onDelete { indices in
                            store.deleteEvents(at: indices)
                        }
                    }
                    .listStyle(.plain)
                    .environment(\.editMode, $editMode)
                }
            }
            .navigationTitle("Agenda")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(editMode.isEditingList ? "Done" : "Manage") {
                        editMode = editMode.isEditingList ? .inactive : .active
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
}

#Preview {
    AgendaView()
        .environment(EventStore())
}
