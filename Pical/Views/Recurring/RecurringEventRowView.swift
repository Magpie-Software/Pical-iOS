import SwiftUI

struct RecurringEventRowView: View {
    let event: RecurringEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(event.title)
                .font(.headline)
                .lineLimit(1)

            Label(event.pattern.description, systemImage: "repeat")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let stop = event.stopCondition {
                Label(stop.description, systemImage: "stopwatch")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }

            if let location = event.location, !location.isEmpty {
                Label(location, systemImage: "mappin")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    List {
        RecurringEventRowView(event: RecurringEvent.sampleData().first!)
    }
}
