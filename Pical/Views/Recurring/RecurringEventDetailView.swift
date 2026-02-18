import SwiftUI

struct RecurringEventDetailView: View {
    @Environment(EventStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let eventID: UUID
    @State private var isEditing = false

    private var event: RecurringEvent? {
        store.recurringEvents.first(where: { $0.id == eventID })
    }

    var body: some View {
        NavigationStack {
            if let event {
                List {
                    Section("Pattern") {
                        Text(event.pattern.description)
                            .font(.headline)
                        if let stop = event.stopCondition {
                            Text(stop.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("No end date")
                                .font(.subheadline)
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
                }
                .navigationTitle(event.title)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Edit") { isEditing = true }
                    }
                }
                .sheet(isPresented: $isEditing) {
                    RecurringEventFormView(event: event) { updated in
                        store.updateRecurring(updated)
                    }
                }
            } else {
                ContentUnavailableView(
                    "Recurring event removed",
                    systemImage: "repeat.circle",
                    description: Text("It might have been deleted while you were viewing it.")
                )
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                }
            }
        }
    }
}

#Preview {
    RecurringEventDetailView(eventID: RecurringEvent.sampleData().first!.id)
        .environment(EventStore())
}
