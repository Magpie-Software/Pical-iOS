import SwiftUI

struct OptionsView: View {
    @Environment(\.openURL) private var openURL

    @AppStorage(SettingsKeys.displayAppearance) private var displayAppearance = AppearanceMode.system.rawValue
    @AppStorage(SettingsKeys.smartAgendaGrouping) private var smartAgendaGrouping = true
    @AppStorage(SettingsKeys.recurringWeekdayGrouping) private var recurringWeekdayGrouping = true
    @AppStorage(SettingsKeys.compactLayout) private var compactLayout = false
    @AppStorage(SettingsKeys.autoPurgePastEvents) private var autoPurgePastEvents = true
    @AppStorage(SettingsKeys.displayAppearance) private var displayAppearanceRaw = AppearanceMode.system.rawValue
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
                    Picker("Appearance", selection: $displayAppearance) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.label).tag(mode.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)

                    Toggle("Smart agenda grouping", isOn: $smartAgendaGrouping)
                        .toggleStyle(.switch)
                        .tint(Theme.splash)
                        .accessibilityHint("Organize events into Today / This Week / Later buckets")

                    Toggle("Group recurring by weekday", isOn: $recurringWeekdayGrouping)
                        .tint(Theme.splash)
                        .toggleStyle(.switch)

                    Toggle("Compact view", isOn: $compactLayout)
                        .tint(Theme.splash)
                        .toggleStyle(.switch)
                        .accessibilityHint("Hide secondary fields like locations and notes in list rows")

                    @AppStorage(SettingsKeys.themeEnabled) var themeEnabled = false
                    Toggle("Simple theme", isOn: $themeEnabled)
                        .tint(Theme.splash)
                        .toggleStyle(.switch)
                        .accessibilityHint("When enabled, Pical uses a toned-back simple theme; when off, Pical shows the full visual treatment with richer gradients and splash graphics")
                }

                Section("Notifications") {
                    Toggle("Agenda reminders", isOn: $agendaNotificationsEnabled)
                        .tint(Theme.splash)
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
                        .tint(Theme.splash)
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
                        .tint(Theme.splash)
                        .toggleStyle(.switch)
                        .accessibilityHint("When enabled, yesterday’s one-off events disappear on the next launch")


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
                        // Acknowledgments icon should also get the gradient treatment (non-animating)
                        HStack {
                            Image(systemName: "list.star")
                                .font(.system(size: 20, weight: .semibold))
                                .frame(width: 22, height: 22)
                                .overlay(Theme.headerGradient.mask(Image(systemName: "list.star").font(.system(size: 20, weight: .semibold))))
                            Text("View credits")
                        }
                    }
                }
            }
            .navigationTitle("Options")
            .navigationBarTitleDisplayMode(.large)
            }
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


private struct OptionsLinkRow: View {
    let title: String
    let detail: String?
    let systemImage: String
    let action: () -> Void
    @State private var animateGradient = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon: use a masked gradient that scrolls subtly for Support & Donations rows
                let baseIcon = Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .semibold))

                // Ko-fi is wider; force a consistent square frame to keep spacing uniform
                let iconFrameSize: CGFloat = systemImage == "cup.and.saucer.fill" ? 20 : 22

                baseIcon
                    .frame(width: iconFrameSize, height: iconFrameSize)
                    .overlay(
                        // animate gradient only for donation/support icons
                        Theme.headerGradient
                            .frame(width: 80, height: iconFrameSize)
                            .offset(x: animateGradient ? 40 : -40)
                            .mask(baseIcon)
                    )
                    .onAppear {
                        if ["cup.and.saucer.fill", "wand.and.stars", "mug.fill"].contains(systemImage) {
                            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                                animateGradient = true
                            }
                        }
                    }
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                    if let detail {
                        Text(detail)
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
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
