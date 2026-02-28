import SwiftUI

struct UsageGuideView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Getting started")
                        .font(.title2)
                        .bold()

                    Text("Pical helps you track one-off events (Agenda) and repeating patterns (Recurring). This guide explains the core screens, gestures, and tips to get the most out of the app.")

                    Group {
                        Text("Top-level screens")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top) {
                                Image(systemName: "list.bullet.rectangle")
                                Text("Agenda — your timeline of upcoming events. Tap an event to view details.")
                            }
                            HStack(alignment: .top) {
                                Image(systemName: "repeat")
                                Text("Recurring — manage repeating patterns like routines, bills, and classes.")
                            }
                            HStack(alignment: .top) {
                                Image(systemName: "slider.horizontal.3")
                                Text("Options — configure reminders, layout, and view guides & credits.")
                            }
                        }
                    }

                    Group {
                        Text("Adding & editing events")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Add: Tap the + in the top-right of Agenda or Recurring.")
                            Text("• Edit: Open an event and tap Edit, or swipe a row and choose Edit.")
                            Text("• Duplicate: Copy an event then modify it for similar instances.")
                            Text("• Delete: Swipe a row or open the event and choose Delete.")
                        }
                    }

                    Group {
                        Text("Gestures & interactions")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack { Image(systemName: "hand.tap"); Text("Tap a row — open details") }
                            HStack { Image(systemName: "ellipsis.circle"); Text("Long-press — show contextual quick actions") }
                            HStack { Image(systemName: "arrow.left"); Text("Swipe left — Edit / Duplicate / Delete") }
                            HStack { Image(systemName: "square.and.pencil"); Text("Manage — enable reordering and bulk actions") }
                        }
                    }

                    Group {
                        Text("Notifications & reminders")
                            .font(.headline)
                        Text("Agenda reminders run once per day when you have events that day. Recurring reminders send a daily reminder for recurring items at your configured time. Configure these on the Options screen.")
                    }

                    Group {
                        Text("Tips & best practices")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Keep titles short and actionable. Put details in Notes.")
                            Text("• Use Duplicate + edit for fast copies of similar events.")
                            Text("• Use Recurring for anything you never want to forget.")
                        }
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Usage Guide")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    UsageGuideView()
}