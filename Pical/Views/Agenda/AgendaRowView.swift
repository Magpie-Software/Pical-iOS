import SwiftUI

struct AgendaRowView: View {
    let event: PicalEvent

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(event.weekdayLabel)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(event.dateLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 90, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                if let location = event.location, !location.isEmpty {
                    Label {
                        Text(location)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    } icon: {
                        Image(systemName: "mappin.and.ellipse")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                if let timeDescription = event.timeDescription {
                    Label(timeDescription, systemImage: "clock")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if let notes = event.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    List {
        AgendaRowView(event: PicalEvent.sampleData().first!)
    }
}
