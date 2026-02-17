import SwiftUI

struct EmptyAgendaView: View {
    let addAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar"
            )
            .font(.system(size: 48))
            .foregroundStyle(.secondary)

            Text("No events yet")
                .font(.title3.weight(.semibold))

            Text("Create your first event to see it appear here."
                )
                .font(.body)
                .foregroundStyle(.secondary)

            Button(action: addAction) {
                Label("Add event", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .multilineTextAlignment(.center)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyAgendaView(addAction: {})
}
