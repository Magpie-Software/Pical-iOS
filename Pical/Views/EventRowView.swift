import SwiftUI

struct EventRowView: View {
    let occurrence: EventOccurrence
    var showDateLabel: Bool = false

    @AppStorage(SettingsKeys.compactLayout) private var compactLayout = false

    private var timeFormatter: DateFormatter { .eventTimeFormatter }
    private var dateFormatter: DateFormatter { .eventDateFormatter }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            timeColumn
                .frame(width: showDateLabel ? 96 : 82, alignment: .leading)

            VStack(alignment: .leading, spacing: compactLayout ? 2 : 4) {
                Text(occurrence.title)
                    .font(.headline)

                if !compactLayout, let location = occurrence.location, !location.isEmpty {
                    Label(location, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .labelStyle(.titleAndIcon)
                }

                if !compactLayout, let notes = occurrence.notes, !notes.isEmpty {
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
        .padding(.vertical, compactLayout ? 4 : 6)
    }

    private var timeColumn: some View {
        Group {
            if showDateLabel {
                VStack(alignment: .leading, spacing: 2) {
                    Text(dateFormatter.string(from: occurrence.startDate))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(timeLabel)
                        .font(.callout.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            } else {
                Text(timeLabel)
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
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
