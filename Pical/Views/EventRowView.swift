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
                    .lineLimit(1)
                    .truncationMode(.tail)

                if !compactLayout, let location = occurrence.location, !location.isEmpty {
                    Label(location, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .labelStyle(.titleAndIcon)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }

                if !compactLayout, let notes = occurrence.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }

            Spacer()

            if occurrence.isRecurring {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 16, weight: .regular))
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
                    Text(displayTime)
                        .font(.callout.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            } else {
                Text(displayTime)
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var displayTime: String {
        timeLabel ?? " "
    }

    private var timeLabel: String? {
        guard occurrence.hasExplicitTime else { return nil }
        return timeFormatter.string(from: occurrence.startDate)
    }
}

#Preview {}
