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
                Section(header: Text("Details").font(.headline)) {
                    TextField("Title", text: $draft.title)

                    if draft.includesTime {
                        DatePicker("Date", selection: $draft.timestamp) // leave as "Date"
                    } else {
                        DatePicker("Date", selection: $draft.timestamp, displayedComponents: .date)
                    }

                    Toggle("Include time", isOn: $draft.includesTime)
                        .toggleStyle(.switch)

                    TextField("Location", text: Binding($draft.location))
                        .textContentType(.location)

                    TextField("Notes", text: Binding($draft.notes), axis: .vertical)
                }

                if mode == .edit {
                    Section(header: Text("")) {
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
            .onChange(of: draft.includesTime) { includesTime in
                guard !includesTime else { return }
                let calendar = Calendar.current
                draft.timestamp = calendar.startOfDay(for: draft.timestamp)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .listRowBackground(Theme.panel)
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
            if !event.includesTime {
                let calendar = Calendar.current
                event.timestamp = calendar.startOfDay(for: event.timestamp)
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
