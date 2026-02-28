import SwiftUI

struct AgendaEventDetailView: View {
    let event: EventRecord
    var onEdit: (() -> Void)?
    var onDuplicate: (() -> Void)?
    var onDelete: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Date").font(.headline)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dateFormatter.string(from: event.timestamp))
                            .foregroundColor(Color("ColorTextPrimary"))
                            .foregroundStyle(.secondary)
                        if let timeDescription = timeDescription {
                            Text(timeDescription)
                                .foregroundColor(Color("ColorTextPrimary"))
                                .foregroundStyle(.secondary)
                        }
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

                if onDuplicate != nil || onDelete != nil {
                    Section(header: Text("Quick actions").font(.headline)) {
                        if let onDuplicate {
                            Button(action: onDuplicate) {
                                Label("Duplicate", systemImage: "plus.square.on.square")
                                    .foregroundStyle(Theme.splash)
                            }
                        }

                        if let onDelete {
                            Button(role: .destructive, action: {
                                onDelete()
                                dismiss()
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle(event.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                if let onEdit {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Edit", action: onEdit)
                    }
                }
            }
            .background(Theme.background)
        }
    }

    private var dateFormatter: DateFormatter { DateFormatter.agendaSectionFormatter }

    private var timeDescription: String? {
        guard event.includesTime else { return nil }
        return DateFormatter.eventTimeFormatter.string(from: event.timestamp)
    }
}

#Preview {
    AgendaEventDetailView(event: EventRecord.samples.first!)
}
