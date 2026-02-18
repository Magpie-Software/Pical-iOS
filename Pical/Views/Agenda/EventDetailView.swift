import SwiftUI

struct EventDetailView: View {
    @Environment(EventStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let eventID: UUID
    @State private var isEditing = false
    @State private var isConfirmingDeletion = false

    private var event: PicalEvent? {
        store.events.first(where: { $0.id == eventID })
    }

    var body: some View {
        NavigationStack {
            if let event {
                List {
                    Section("Overview") {
                        Text(event.title)
                            .font(.title3)
                            .bold()
                        Text("\(event.weekdayLabel), \(event.dateLabel)")
                            .foregroundStyle(.secondary)
                        if let timeDescription = event.timeDescription {
                            Label(timeDescription, systemImage: "clock")
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let location = event.location, !location.isEmpty {
                        Section("Location") {
                            Text(location)
                        }
                    }

                    if let notes = event.notes, !notes.isEmpty {
                        Section("Notes") {
                            Text(notes)
                        }
                    }

                    Section("Quick actions") {
                        Button {
                            store.duplicateEvent(event)
                        } label: {
                            Label("Duplicate", systemImage: "plus.square.on.square")
                        }

                        Button(role: .destructive) {
                            isConfirmingDeletion = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .navigationTitle(event.title)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            dismiss()
                        }
                    }

                    ToolbarItem(placement: .primaryAction) {
                        Button("Edit") {
                            isEditing = true
                        }
                    }
                }
                .sheet(isPresented: $isEditing) {
                    EventFormView(event: event) { updatedEvent in
                        store.updateEvent(updatedEvent)
                    }
                }
                .confirmationDialog("Delete this event?", isPresented: $isConfirmingDeletion, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        store.deleteEvent(event)
                        dismiss()
                    }
                    Button("Cancel", role: .cancel) { }
                }
            } else {
                ContentUnavailableView("Event removed", systemImage: "calendar.badge.exclamationmark", description: Text("It might have been deleted while you were looking at it."))
            }
        }
    }
}

#Preview {
    EventDetailView(eventID: PicalEvent.sampleData().first!.id)
        .environment(EventStore())
}
