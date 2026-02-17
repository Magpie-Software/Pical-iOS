import SwiftUI

private enum RecurringStopSelection: String, CaseIterable, Identifiable {
    case none
    case endDate
    case occurrenceCount

    var id: String { rawValue }

    var label: String {
        switch self {
        case .none: return "No end"
        case .endDate: return "End by date"
        case .occurrenceCount: return "End after count"
        }
    }
}

struct RecurringEventFormView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var location: String
    @State private var notes: String

    @State private var weekday: Weekday = .monday
    @State private var ordinal: OrdinalWeek = .first
    @State private var monthDay: Int = 1

    @State private var patternMode: PatternMode
    @State private var stopSelection: RecurringStopSelection
    @State private var stopDate: Date
    @State private var occurrenceCount: Int

    let sourceEvent: RecurringEvent?
    let onSave: (RecurringEvent) -> Void

    enum PatternMode: String, CaseIterable, Identifiable {
        case weekly
        case monthlyOrdinal
        case monthlyDate

        var id: String { rawValue }

        var label: String {
            switch self {
            case .weekly: return "Weekly"
            case .monthlyOrdinal: return "Monthly (First Monday)"
            case .monthlyDate: return "Monthly (Specific date)"
            }
        }
    }

    init(event: RecurringEvent?, onSave: @escaping (RecurringEvent) -> Void) {
        self.sourceEvent = event
        _title = State(initialValue: event?.title ?? "")
        _location = State(initialValue: event?.location ?? "")
        _notes = State(initialValue: event?.notes ?? "")

        if let pattern = event?.pattern {
            switch pattern {
            case let .weekly(day):
                _patternMode = State(initialValue: .weekly)
                _weekday = State(initialValue: day)
            case let .monthlyOrdinal(ord, day):
                _patternMode = State(initialValue: .monthlyOrdinal)
                _ordinal = State(initialValue: ord)
                _weekday = State(initialValue: day)
            case let .monthlyDate(day):
                _patternMode = State(initialValue: .monthlyDate)
                _monthDay = State(initialValue: day)
            }
        } else {
            _patternMode = State(initialValue: .weekly)
        }

        if let stop = event?.stopCondition {
            switch stop {
            case let .endDate(date):
                _stopSelection = State(initialValue: .endDate)
                _stopDate = State(initialValue: date)
                _occurrenceCount = State(initialValue: 10)
            case let .occurrenceCount(count):
                _stopSelection = State(initialValue: .occurrenceCount)
                _occurrenceCount = State(initialValue: max(1, count))
                _stopDate = State(initialValue: Date())
            }
        } else {
            _stopSelection = State(initialValue: .none)
            _stopDate = State(initialValue: Date().addingTimeInterval(60 * 60 * 24 * 30))
            _occurrenceCount = State(initialValue: 6)
        }

        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    TextField("Location", text: $location)
                    TextField("Notes", text: $notes, axis: .vertical)
                }

                Section("Pattern") {
                    Picker("Repeat", selection: $patternMode) {
                        ForEach(PatternMode.allCases) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    switch patternMode {
                    case .weekly:
                        Picker("Weekday", selection: $weekday) {
                            ForEach(Weekday.allCases) { day in
                                Text(day.label).tag(day)
                            }
                        }
                    case .monthlyOrdinal:
                        Picker("Week", selection: $ordinal) {
                            ForEach(OrdinalWeek.allCases) { ord in
                                Text(ord.label).tag(ord)
                            }
                        }
                        Picker("Weekday", selection: $weekday) {
                            ForEach(Weekday.allCases) { day in
                                Text(day.label).tag(day)
                            }
                        }
                    case .monthlyDate:
                        Stepper(value: $monthDay, in: 1...31) {
                            Text("Day \(monthDay)")
                        }
                    }
                }

                Section("Stop condition") {
                    Picker("Ends", selection: $stopSelection) {
                        ForEach(RecurringStopSelection.allCases) { option in
                            Text(option.label).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)

                    switch stopSelection {
                    case .none:
                        EmptyView()
                    case .endDate:
                        DatePicker("End date", selection: $stopDate, displayedComponents: .date)
                    case .occurrenceCount:
                        Stepper(value: $occurrenceCount, in: 1...60) {
                            Text("After \(occurrenceCount) occurrences")
                        }
                    }
                }
            }
            .navigationTitle(sourceEvent == nil ? "New Recurring" : "Edit Recurring")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let pattern = makePattern()
                        let stopCondition = makeStopCondition()
                        let newEvent = RecurringEvent(
                            id: sourceEvent?.id ?? UUID(),
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            pattern: pattern,
                            location: location.isEmpty ? nil : location,
                            notes: notes.isEmpty ? nil : notes,
                            stopCondition: stopCondition
                        )
                        onSave(newEvent)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func makePattern() -> RecurrencePattern {
        switch patternMode {
        case .weekly:
            return .weekly(weekday)
        case .monthlyOrdinal:
            return .monthlyOrdinal(ordinal, weekday)
        case .monthlyDate:
            return .monthlyDate(monthDay)
        }
    }

    private func makeStopCondition() -> RecurringStopCondition? {
        switch stopSelection {
        case .none:
            return nil
        case .endDate:
            return .endDate(stopDate)
        case .occurrenceCount:
            return .occurrenceCount(occurrenceCount)
        }
    }
}

#Preview {
    RecurringEventFormView(event: RecurringEvent.sampleData().first) { _ in }
}
