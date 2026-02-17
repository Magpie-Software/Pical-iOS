import SwiftUI

struct RecurringEventsView: View {
    @Environment(EventStore.self) private var store
    @State private var editingEvent: RecurringEvent?
    @State private var isPresentingNew = false

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
                                .onTapGesture { editingEvent = event }
                                .swipeActions(allowsFullSwipe: false) {
                                    Button("Edit") {
                                        editingEvent = event
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
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Recurring")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isPresentingNew = true
                    } label: {
                        Label("Add recurring", systemImage: "plus")
                    }
                }
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
