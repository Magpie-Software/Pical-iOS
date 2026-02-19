import SwiftUI

struct EventRowView: View {
    let occurrence: EventOccurrence

    private var timeFormatter: DateFormatter { .eventTimeFormatter }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(timeLabel)
                .font(.callout.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 82, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(occurrence.title)
                    .font(.headline)

                if let location = occurrence.location, !location.isEmpty {
                    Label(location, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .labelStyle(.titleAndIcon)
                }

                if let notes = occurrence.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if occurrence.isRecurring {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }

    private var timeLabel: String {
        if occurrence.hasExplicitTime {
            return timeFormatter.string(from: occurrence.startDate)
        } else {
            return "All day"
        }
    }
}

#Preview {}
