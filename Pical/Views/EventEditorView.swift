import SwiftUI

struct EventEditorView: View {
    enum Mode {
        case create
        case edit
    }

    @Environment(\.dismiss) private var dismiss

    @State private var draft: EventRecord
    private let mode: Mode
    private let onSave: (EventRecord) async -> Void
    private let onDelete: (UUID) async -> Void

    init(event: EventRecord, mode: Mode, onSave: @escaping (EventRecord) async -> Void, onDelete: @escaping (UUID) async -> Void) {
        _draft = State(initialValue: event)
        self.mode = mode
        self.onSave = onSave
        self.onDelete = onDelete
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $draft.title)

                    DatePicker("Date & time", selection: $draft.timestamp)

                    TextField("Location", text: Binding($draft.location))
                        .textContentType(.location)

                    TextField("Notes", text: Binding($draft.notes), axis: .vertical)
                }

                Section("Recurrence") {
                    Picker("Repeat", selection: $draft.recurrence) {
                        ForEach(EventRecord.Recurrence.allCases) { recurrence in
                            Text(recurrence.displayName).tag(recurrence)
                        }
                    }
                }

                if mode == .edit {
                    Section {
                        Button(role: .destructive) { deleteDraft() } label: {
                            Label("Delete event", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle(mode == .create ? "New Event" : "Edit Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveDraft)
                        .disabled(draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveDraft() {
        let sanitized = draft.updating { event in
            event.title = event.title.trimmingCharacters(in: .whitespacesAndNewlines)
            if let location = event.location?.trimmingCharacters(in: .whitespacesAndNewlines), location.isEmpty {
                event.location = nil
            }
            if let notes = event.notes?.trimmingCharacters(in: .whitespacesAndNewlines), notes.isEmpty {
                event.notes = nil
            }
        }

        Task {
            await onSave(sanitized)
            await MainActor.run { dismiss() }
        }
    }

    private func deleteDraft() {
        Task {
            await onDelete(draft.id)
            await MainActor.run { dismiss() }
        }
    }
}

private extension Binding where Value == String {
    init(_ source: Binding<String?>, defaultValue: String = "") {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { source.wrappedValue = $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : $0 }
        )
    }
}

#Preview {
    EventEditorView(event: EventRecord.samples.first!, mode: .edit, onSave: { _ in }, onDelete: { _ in })
}
