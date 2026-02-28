import SwiftUI

struct EventFormView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var draft: PicalEvent
    @State private var hasEndTime: Bool

    let onSave: (PicalEvent) -> Void

    init(event: PicalEvent?, onSave: @escaping (PicalEvent) -> Void) {
        let fallbackDate = Date()
        let initial = event ?? PicalEvent(title: "", date: fallbackDate, includesTime: true)
        _draft = State(initialValue: initial)
        _hasEndTime = State(initialValue: initial.endDate != nil)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Details").font(.headline)) {
                    TextField("Title", text: $draft.title)
                    TextField("Location", text: Binding(
                        get: { draft.location ?? "" },
                        set: { draft.location = $0.isEmpty ? nil : $0 }
                    ))
                    TextField("Notes", text: Binding(
                        get: { draft.notes ?? "" },
                        set: { draft.notes = $0.isEmpty ? nil : $0 }
                    ), axis: .vertical)
                }

                Section(header: Text("Timing").font(.headline)) {
                    Toggle("Include time", isOn: $draft.includesTime)
                        .onChange(of: draft.includesTime) { _, includesTime in
                            if !includesTime {
                                hasEndTime = false
                                draft.endDate = nil
                                draft.date = Calendar.current.startOfDay(for: draft.date)
                            }
                        }

                    DatePicker(draft.includesTime ? "Start" : "Date", selection: $draft.date, displayedComponents: draft.includesTime ? [.date, .hourAndMinute] : [.date])

                    if draft.includesTime {
                        Toggle("Specify end time", isOn: $hasEndTime)
                            .onChange(of: hasEndTime) { _, enabled in
                                if !enabled {
                                    draft.endDate = nil
                                } else if draft.endDate == nil {
                                    draft.endDate = draft.date.addingTimeInterval(60 * 30)
                                }
                            }

                        if hasEndTime {
                            DatePicker("End", selection: Binding(
                                get: { draft.endDate ?? draft.date.addingTimeInterval(60 * 30) },
                                set: { newValue in
                                    draft.endDate = max(newValue, draft.date)
                                }
                            ), displayedComponents: [.hourAndMinute])
                        }
                    }
                }
            }
            .navigationTitle(draft.title.isEmpty ? "New Event" : "Edit Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var cleaned = draft
                        if !cleaned.includesTime {
                            cleaned.endDate = nil
                        } else if !hasEndTime {
                            cleaned.endDate = nil
                        }
                        cleaned.title = cleaned.title.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSave(cleaned)
                        dismiss()
                    }
                    .disabled(draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .listRowBackground(Theme.panel)
        }
    }
}

#Preview {
    EventFormView(event: PicalEvent.sampleData().first) { _ in }
}
