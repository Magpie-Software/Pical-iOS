import SwiftUI

struct UsageGuideView: View {
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
                            HStack { Image(systemName: "arrow.left"); Text("Swipe left — Edit / Duplicate / Delete") }
                            HStack { Image(systemName: "square.and.pencil"); Text("Manage — enable reordering and bulk actions. Note: the Manage button only appears when \"Group recurring by weekday\" is turned off.") }
                        }
                    }

                    Group {
                        Text("Notifications & reminders")
                            .font(.headline)
                        Text("Agenda reminders run once per day when you have events that day. Recurring reminders send a daily reminder for recurring items at your configured time. Configure these on the Options screen.")
                    }

                    Group {
                        Text("Options explained")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Smart agenda grouping — Groups agenda items into Today, This Week (when applicable), Next Week, and Later instead of listing by individual date.")
                            Text("• Group recurring by weekday — Groups weekly recurring items by the weekday and sorts them; also applies sorting to monthly-by-day and monthly-by-date items instead of using the freeform Manage layout.")
                            Text("• Compact view — Hides most secondary details (locations, notes) from main lists; details remain in event detail screens.")
                            Text("• Agenda reminders / Recurring reminders — Enable daily reminders for each type; notifications only fire if events of that type occur that day. If both reminders are set to the same time, they are combined into one notification.")
                            Text("• Auto-clear past events — When enabled, events that occurred on previous days are automatically deleted.")
                        }
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
        }
    }
}

#Preview {
    UsageGuideView()
}
