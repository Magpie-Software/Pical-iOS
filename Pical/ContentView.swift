import SwiftUI

struct ContentView: View {
    @State private var store = EventStore()

    var body: some View {
        TabView {
            AgendaView()
                .tabItem {
                    Label("Agenda", systemImage: "list.bullet.rectangle")
                }

            RecurringEventsView()
                .tabItem {
                    Label("Recurring", systemImage: "repeat")
                }

            OptionsView()
                .tabItem {
                    Label("Options", systemImage: "slider.horizontal.3")
                }
        }
        .environment(store)
    }
}

#Preview {
    ContentView()
}
