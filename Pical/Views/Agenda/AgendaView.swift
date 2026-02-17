import SwiftUI

struct AgendaView: View {
    @Environment(EventStore.self) private var store
    @State private var selectedEvent: PicalEvent?
    @State private var isPresentingNewEvent = false

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
                                    Button("Duplicate") {
                                        store.duplicateEvent(event)
                                    }
                                    .tint(.indigo)

                                    Button(role: .destructive) {
                                        store.deleteEvent(event)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Agenda")
            .toolbar {
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
