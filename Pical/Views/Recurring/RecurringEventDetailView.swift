import SwiftUI

struct RecurringEventDetailView: View {
    @Environment(AgendaDataStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let eventID: UUID
    @State private var isEditing = false
    @State private var isConfirmingDeletion = false

    private var event: RecurringEvent? {
        store.recurringEvents.first(where: { $0.id == eventID })
    }

    var body: some View {
        NavigationStack {
            if let event {
                List {
                    Section(header: Text("Pattern").font(.headline)) {
                        Text(event.pattern.description)
                            .font(.headline)
                            .foregroundStyle(Theme.accent)
                        if let stop = event.stopCondition {
                            Text(stop.description)
                                .font(.subheadline)
                                .foregroundColor(Color("ColorTextPrimary"))
                        } else {
                            Text("No end date")
                                .font(.subheadline)
                                .foregroundColor(Color("ColorTextPrimary"))
                        }
                    }

                    if let location = event.location, !location.isEmpty {
                        Section(header: Text("Location").font(.headline)) {
                            Text(location)
                                .foregroundColor(Color("ColorTextPrimary"))
                        }
                    }

                    if let notes = event.notes, !notes.isEmpty {
                        Section(header: Text("Notes").font(.headline)) {
                            Text(notes)
                                .foregroundColor(Color("ColorTextPrimary"))
                        }
                    }

                    Section(header: Text("Quick actions").font(.headline)) {
                        Button {
                            store.duplicateRecurring(event)
                        } label: {
                            Label("Duplicate", systemImage: "plus.square.on.square")
                                .foregroundStyle(Theme.splash)
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
                .confirmationDialog("Delete this recurring pattern?", isPresented: $isConfirmingDeletion, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        store.deleteRecurring(event)
                        dismiss()
                    }
                    Button("Cancel", role: .cancel) { }
                }
                .scrollContentBackground(.hidden)
                .background(Theme.background)
                .listRowBackground(Theme.panel)
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
        .environment(AgendaDataStore())
}
