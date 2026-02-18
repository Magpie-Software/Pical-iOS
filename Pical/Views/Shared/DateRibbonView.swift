import SwiftUI

struct DateRibbonView: View {
    let date: Date
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()

    var body: some View {
        Text(Self.formatter.string(from: date))
            .font(.subheadline.weight(.semibold))
            .textCase(.uppercase)
            .foregroundStyle(.secondary)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(
                Capsule()
                    .fill(Color.secondary.opacity(0.15))
            )
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
