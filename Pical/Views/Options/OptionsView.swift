import SwiftUI

struct OptionsView: View {
    @Environment(\.openURL) private var openURL

    @AppStorage(SettingsKeys.agendaDateHeaders) private var agendaDateHeaders = false
    @AppStorage(SettingsKeys.smartAgendaGrouping) private var smartAgendaGrouping = true
    @AppStorage(SettingsKeys.recurringWeekdayGrouping) private var recurringWeekdayGrouping = false
    @AppStorage(SettingsKeys.autoPurgePastEvents) private var autoPurgePastEvents = true
    @AppStorage(SettingsKeys.agendaNotificationsEnabled) private var agendaNotificationsEnabled = false
    @AppStorage(SettingsKeys.recurringNotificationsEnabled) private var recurringNotificationsEnabled = false
    @AppStorage(SettingsKeys.agendaNotificationTime) private var agendaNotificationTime: Double = DefaultTimes.agenda
    @AppStorage(SettingsKeys.recurringNotificationTime) private var recurringNotificationTime: Double = DefaultTimes.recurring

    private let donationLinks = OptionsLink.samples
    private let guideLinks = GuideLink.samples
    private let feedbackLinks = FeedbackLink.samples

    var body: some View {
        NavigationStack {
            List {
                Section("Display") {
                    Toggle("Agenda date ribbons", isOn: $agendaDateHeaders)
                        .toggleStyle(.switch)
                        .accessibilityHint("Show each date as a header ribbon instead of the left column")

                    Toggle("Smart agenda grouping", isOn: $smartAgendaGrouping)
                        .toggleStyle(.switch)
                        .accessibilityHint("Organize events into Today / This Week / Later buckets")

                    Toggle("Group recurring by weekday", isOn: $recurringWeekdayGrouping)
                        .toggleStyle(.switch)
                }

                Section("Notifications") {
                    Toggle("Agenda reminders", isOn: $agendaNotificationsEnabled)
                    if agendaNotificationsEnabled {
                        DatePicker(
                            "Agenda reminder time",
                            selection: Binding(
                                get: { timeFromSeconds(agendaNotificationTime) },
                                set: { agendaNotificationTime = secondsFromMidnight($0) }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                    }

                    Toggle("Recurring reminders", isOn: $recurringNotificationsEnabled)
                    if recurringNotificationsEnabled {
                        DatePicker(
                            "Recurring reminder time",
                            selection: Binding(
                                get: { timeFromSeconds(recurringNotificationTime) },
                                set: { recurringNotificationTime = secondsFromMidnight($0) }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                    }

                    Text("Notifications only fire on days that actually have events.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Maintenance") {
                    Toggle("Auto-clear past events", isOn: $autoPurgePastEvents)
                        .toggleStyle(.switch)
                        .accessibilityHint("When enabled, yesterday’s one-off events disappear on the next launch")
                    Text("Clearing still happens manually when you disable this toggle.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Support & Donations") {
                    ForEach(donationLinks) { link in
                        OptionsLinkRow(title: link.title, detail: link.detail, systemImage: link.icon) {
                            openURL(link.url)
                        }
                    }
                }

                Section("Guides & Docs") {
                    ForEach(guideLinks) { link in
                        OptionsLinkRow(title: link.title, detail: link.detail, systemImage: link.icon) {
                            openURL(link.url)
                        }
                    }
                }

                Section("Feedback & Bug Reports") {
                    ForEach(feedbackLinks) { link in
                        OptionsLinkRow(title: link.title, detail: link.detail, systemImage: link.icon) {
                            openURL(link.url)
                        }
                    }
                }

                Section("Acknowledgments") {
                    NavigationLink {
                        AcknowledgmentsView()
                    } label: {
                        Label("View credits", systemImage: "list.star")
                    }
                }
            }
            .navigationTitle("Options")
        }
    }

    private func timeFromSeconds(_ seconds: Double) -> Date {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        return startOfDay.addingTimeInterval(seconds)
    }

    private func secondsFromMidnight(_ date: Date) -> Double {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        return max(0, min(86_399, date.timeIntervalSince(startOfDay)))
    }
}

private struct OptionsLinkRow: View {
    let title: String
    let detail: String?
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Label(title, systemImage: systemImage)
                if let detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .tint(.primary)
    }
}

private struct OptionsLink: Identifiable {
    let id = UUID()
    let title: String
    let detail: String?
    let icon: String
    let url: URL

    static let samples: [OptionsLink] = [
        OptionsLink(
            title: "Ko-fi",
            detail: "One-off tips for MagWare/Pical",
            icon: "cup.and.saucer.fill",
            url: URL(string: "https://ko-fi.com/magware")!
        ),
        OptionsLink(
            title: "Patreon",
            detail: "Recurring support with perks",
            icon: "wand.and.stars",
            url: URL(string: "https://patreon.com/magware")!
        ),
        OptionsLink(
            title: "Buy Me a Coffee",
            detail: "Fast donations without an account",
            icon: "mug.fill",
            url: URL(string: "https://buymeacoffee.com/magware")!
        )
    ]
}

private struct GuideLink: Identifiable {
    let id = UUID()
    let title: String
    let detail: String?
    let icon: String
    let url: URL

    static let samples: [GuideLink] = [
        GuideLink(
            title: "Usage guide",
            detail: "Get started + learn the gestures",
            icon: "book.closed.fill",
            url: URL(string: "https://magpiesoftware.notion.site/pical-guide")!
        ),
        GuideLink(
            title: "Release notes",
            detail: "Track what changed between builds",
            icon: "doc.text.fill",
            url: URL(string: "https://magpiesoftware.notion.site/pical-release-notes")!
        )
    ]
}

private struct FeedbackLink: Identifiable {
    let id = UUID()
    let title: String
    let detail: String?
    let icon: String
    let url: URL

    static let samples: [FeedbackLink] = [
        FeedbackLink(
            title: "Feedback form",
            detail: "Share ideas or feature requests",
            icon: "bubble.left.fill",
            url: URL(string: "https://magpiesoftware.typeform.com/pical-feedback")!
        ),
        FeedbackLink(
            title: "Bug report",
            detail: "Attach diagnostics & repro steps",
            icon: "ladybug.fill",
            url: URL(string: "https://magpiesoftware.typeform.com/pical-bugs")!
        )
    ]
}

private struct AcknowledgmentsView: View {
    var body: some View {
        List {
            Section("Core team") {
                LabeledContent("Product", value: "Camden Bettencourt")
                LabeledContent("iOS build", value: "Donsy helper")
            }

            Section("Thanks") {
                Text("Beta testers, corvid pals, and everyone sharing scheduling chaos stories.")
            }
        }
        .navigationTitle("Acknowledgments")
    }
}
