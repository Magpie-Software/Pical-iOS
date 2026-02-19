import SwiftUI

struct RecurringEventRowView: View {
    let event: RecurringEvent

    @AppStorage(SettingsKeys.compactLayout) private var compactLayout = false

    var body: some View {
        VStack(alignment: .leading, spacing: compactLayout ? 4 : 6) {
            Text(event.title)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.tail)

            Label(event.pattern.description, systemImage: "repeat")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)

            if !compactLayout, let stop = event.stopCondition {
                Label(stop.description, systemImage: "stopwatch")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            if !compactLayout, let location = event.location, !location.isEmpty {
                Label(location, systemImage: "mappin")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            if !compactLayout, let notes = event.notes, !notes.isEmpty {
                Text(notes)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .padding(.vertical, compactLayout ? 6 : 8)
    }
}

#Preview {
    List {
        RecurringEventRowView(event: RecurringEvent.sampleData().first!)
    }
}
