import SwiftUI

struct AgendaSectionView: View {
    let section: AgendaSection
    var onSelect: (EventOccurrence) -> Void

    private var dateFormatter: DateFormatter {
        DateFormatter.agendaSectionFormatter
    }

    var body: some View {
        Section(header: Text(dateFormatter.string(from: section.date))) {
            ForEach(section.events) { occurrence in
                EventRowView(occurrence: occurrence)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSelect(occurrence)
                    }
            }
        }
    }
}

#Preview {
    List {
        AgendaSectionView(section: AgendaSection(date: .now, events: EventRecord.samples.flatMap { $0.occurrences(in: Date.now...Date.now.addingTimeInterval(86400)) }), onSelect: { _ in })
    }
}
