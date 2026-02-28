import SwiftUI

struct UsageGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Usage Guide")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Group {
                    Text("Overview")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Pical separates events into two areas in Options: an Agenda tab for one-off, special events, and a Recurring tab for repeating weekly/monthly events. This helps you quickly manage occasional items without cluttering your regular recurring schedule.")
                }

                Group {
                    Text("Why Agenda vs Recurring")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("• Agenda (one-off special events): Use this for single-date events, extra responsibilities, or anything that won’t repeat. Agenda items are shown prominently so you can treat them as exceptions or spotlight items.\n\n• Recurring (weekly/monthly): Use this for habits, regular meetings, classes, or routines that repeat. Recurring events can be scheduled with a repeat cadence so they automatically appear on future dates.")
                }

                Group {
                    Text("Options Toggles — What they do")
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(alignment: .leading, spacing: 12) {
                        ToggleRow(title: "Show Agenda on Today", description: "When enabled, agenda items are surfaced on the Today view for quick access.")
                        ToggleRow(title: "Collapse Recurring Items", description: "If on, recurring events are collapsed into a compact list to reduce visual noise.")
                        ToggleRow(title: "Notify for Agenda Items", description: "Send a local reminder for agenda events. Useful for one-off deadlines.")
                        ToggleRow(title: "Auto-skip Past Recurring", description: "Automatically advance recurring items if their scheduled instance was missed.")
                        ToggleRow(title: "Highlight Special Events", description: "Give agenda items a visual accent so they stand out in lists and the calendar.")
                    }
                }

                Group {
                    Text("Tips")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("• Use Agenda for temporary focus items (projects, trips, exams).\n• Use Recurring for anything that repeats — saves setup time later.\n• Combine: create a recurring event and temporarily add an Agenda note for the current week to call extra attention to it.")
                }

                Group {
                    Text("Accessibility & UX")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("This guide is intentionally concise — headings and short paragraphs for screen readers, and clear toggle explanations so users know exactly what each option controls.")
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Usage Guide")
    }
}

struct ToggleRow: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
    }
}

#if DEBUG
struct UsageGuideView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UsageGuideView()
        }
    }
}
#endif
