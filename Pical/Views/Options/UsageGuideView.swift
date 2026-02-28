import SwiftUI

struct UsageGuideView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Getting started")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Theme.accent)

                    Text("Pical helps you track one-off events (Agenda) and repeating patterns (Recurring). This guide explains the core screens, gestures, and tips to get the most out of the app.")
                        .foregroundColor(Color("ColorTextPrimary"))

                    Group {
                        Text("Top-level screens")
                            .font(.headline)
                            .foregroundStyle(Theme.accent)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top) {
                                Image(systemName: "list.bullet.rectangle")
                                    .foregroundStyle(Theme.splash)
                                Text("Agenda — your timeline of upcoming events. Tap an event to view details.")
                                    .foregroundColor(Color("ColorTextPrimary"))
                            }
                            HStack(alignment: .top) {
                                Image(systemName: "repeat")
                                    .foregroundStyle(Theme.splash)
                                Text("Recurring — manage repeating patterns like routines, bills, and classes.")
                                    .foregroundColor(Color("ColorTextPrimary"))
                            }
                            HStack(alignment: .top) {
                                Image(systemName: "slider.horizontal.3")
                                    .foregroundStyle(Theme.splash)
                                Text("Options — configure reminders, layout, and view guides & credits.")
                                    .foregroundColor(Color("ColorTextPrimary"))
                            }
                        }
                    }

                    Group {
                        Text("Adding & editing events")
                            .font(.headline)
                            .foregroundStyle(Theme.accent)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Add: Tap the + in the top-right of Agenda or Recurring.")
                                .foregroundColor(Color("ColorTextPrimary"))
                            Text("• Edit: Open an event and tap Edit, or swipe a row and choose Edit.")
                                .foregroundColor(Color("ColorTextPrimary"))
                            Text("• Duplicate: Copy an event then modify it for similar instances.")
                                .foregroundColor(Color("ColorTextPrimary"))
                            Text("• Delete: Swipe a row or open the event and choose Delete.")
                                .foregroundColor(Color("ColorTextPrimary"))
                        }
                    }

                    Group {
                        Text("Gestures & interactions")
                            .font(.headline)
                            .foregroundStyle(Theme.accent)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack { Image(systemName: "hand.tap").foregroundStyle(Theme.splash); Text("Tap a row — open details").foregroundColor(Color("ColorTextPrimary")) }
                            HStack { Image(systemName: "arrow.left").foregroundStyle(Theme.splash); Text("Swipe left — Edit / Duplicate / Delete").foregroundColor(Color("ColorTextPrimary")) }
                            HStack { Image(systemName: "square.and.pencil").foregroundStyle(Theme.splash); Text("Manage — enable reordering and bulk actions. Note: the Manage button only appears when \"Group recurring by weekday\" is turned off.").foregroundColor(Color("ColorTextPrimary")) }
                        }
                    }

                    Group {
                        Text("Notifications & reminders")
                            .font(.headline)
                            .foregroundStyle(Theme.accent)
                        Text("Agenda reminders run once per day when you have events that day. Recurring reminders send a daily reminder for recurring items at your configured time. Configure these on the Options screen.")
                            .foregroundColor(Color("ColorTextPrimary"))
                    }

                    Group {
                        Text("Options explained")
                            .font(.headline)
                            .foregroundStyle(Theme.accent)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Smart agenda grouping — Groups agenda items into Today, This Week (when applicable), Next Week, and Later instead of listing by individual date.")
                                .foregroundColor(Color("ColorTextPrimary"))
                            Text("• Group recurring by weekday — Groups weekly recurring items by the weekday and sorts them; also applies sorting to monthly-by-day and monthly-by-date items instead of using the freeform Manage layout.")
                                .foregroundColor(Color("ColorTextPrimary"))
                            Text("• Compact view — Hides most secondary details (locations, notes) from main lists; details remain in event detail screens.")
                                .foregroundColor(Color("ColorTextPrimary"))
                            Text("• Agenda reminders / Recurring reminders — Enable daily reminders for each type; notifications only fire if events of that type occur that day. If both reminders are set to the same time, they are combined into one notification.")
                                .foregroundColor(Color("ColorTextPrimary"))
                            Text("• Auto-clear past events — When enabled, events that occurred on previous days are automatically deleted.")
                                .foregroundColor(Color("ColorTextPrimary"))
                        }
                    }

                    Group {
                        Text("Tips & best practices")
                            .font(.headline)
                            .foregroundStyle(Theme.accent)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Keep titles short and actionable. Put details in Notes.")
                                .foregroundColor(Color("ColorTextPrimary"))
                            Text("• Use Duplicate + edit for fast copies of similar events.")
                                .foregroundColor(Color("ColorTextPrimary"))
                            Text("• Use Recurring for anything you never want to forget.")
                                .foregroundColor(Color("ColorTextPrimary"))
                        }
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Usage Guide")
            .background(Theme.background)
        }
    }
}

#Preview {
    UsageGuideView()
}
