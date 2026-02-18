import SwiftUI

struct RecurringEventsView: View {
    @Environment(EventStore.self) private var store
    @State private var editingEvent: RecurringEvent?
    @State private var selectedEvent: RecurringEvent?
    @State private var isPresentingNew = false
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationStack {
            Group {
                if store.recurringEvents.isEmpty {
                    ContentUnavailableView("No recurring patterns", systemImage: "repeat", description: Text("Document your weekly/monthly rhythms here."))
                } else {
                    List {
                        ForEach(store.recurringEvents) { event in
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
                        .onDelete { indices in
                            store.deleteRecurring(at: indices)
                        }
                    }
                    .listStyle(.plain)
                    .environment(\.editMode, $editMode)
                }
            }
            .navigationTitle("Recurring")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(editMode.isEditingList ? "Done" : "Manage") {
                        editMode = editMode.isEditingList ? .inactive : .active
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
}

#Preview {
    RecurringEventsView()
        .environment(EventStore())
}
