# Agent Task — feature/notifications-fix-and-appearance

You are working on Pical-iOS, a SwiftUI iOS app. Branch is already created and pushed: `feature/notifications-fix-and-appearance`. Do NOT switch branches.

Read the relevant files, implement the two tasks below, then commit and push.

---

## TASK 1: Fix notification bug + reformat notification body

### Background
The app has two stores:
- `Stores/EventStore.swift` — holds `[EventRecord]` (properties: .timestamp, .title, .includesTime, .location, .notes)
- `ViewModels/AgendaDataStore.swift` — holds `[PicalEvent]` + `[RecurringEvent]`

`ContentView.swift` passes `agendaStore.events` (which are `[EventRecord]`) and `store.recurringEvents` (which are `[RecurringEvent]`) to `NotificationScheduler.shared.scheduleNotifications(...)`.

The `NotificationScheduler` currently uses `.date` on events (old PicalEvent field name) but `EventRecord` uses `.timestamp`. This is the bug — the wrong field causes events from the wrong date to appear.

### Required changes to NotificationScheduler

1. Change the `events` parameter type from `[PicalEvent]` to `[EventRecord]`. Use `.timestamp` (not `.date`) for all date comparisons and time formatting.

2. Fix the date filter: `calendar.isDate($0.timestamp, inSameDayAs: date)`.

3. Reformat the notification body as a bulleted list, one item per line:

   Agenda notification:
   - title: "Agenda items for today"
   - body lines: "- {title} {time}" if includesTime (format time from .timestamp using DateFormatter timeStyle .short), else "- {title}"

   Recurring notification:
   - title: "Recurring events today"
   - body lines: "- {title}" for each recurring event

   Combined (same fire time, both enabled):
   - title: "Your day at a glance"
   - body: "Agenda:\n- item1\n- item2\n\nRecurring:\n- item1\n- item2"

4. Truncate: show at most 5 agenda + 5 recurring bullets. If more exist, append "...and N more" on a new line.

5. Remove any methods in NotificationScheduler that are no longer used after this refactor.

6. Update the call site in ContentView if the parameter label changed (it may already use `agendaEvents:` — check and align).

---

## TASK 2: Add appearance toggle to OptionsView

### Background
- `SettingsKeys.displayAppearance` already exists in `Support/SettingsKeys.swift`
- `ContentView.swift` already reads `@AppStorage(SettingsKeys.displayAppearance) private var displayAppearanceRaw` and uses `AppearanceMode` enum
- `AppearanceMode` may or may not exist — search the codebase first

### Required changes

1. If `AppearanceMode` does not exist, create `Support/AppearanceMode.swift` with:
```swift
import SwiftUI

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
```

2. In `Views/Options/OptionsView.swift`, add to the Display section (after the existing toggles):
```swift
Picker("Appearance", selection: $displayAppearanceRaw) {
    ForEach(AppearanceMode.allCases) { mode in
        Text(mode.label).tag(mode.rawValue)
    }
}
.pickerStyle(.segmented)
```
And add the AppStorage binding at the top of OptionsView:
```swift
@AppStorage(SettingsKeys.displayAppearance) private var displayAppearanceRaw = AppearanceMode.system.rawValue
```

---

## After completing both tasks

1. Run `bash scripts/prepush.sh` — if it errors only because Xcode full IDE is missing (xcode-select command line tools only), note it but proceed. Fix any actual Swift compilation errors you can identify by reading the code carefully.
2. Commit: `git add -A && git commit -m "Fix notification date filtering, reformat body, add appearance toggle"`
3. Push: `git push origin feature/notifications-fix-and-appearance`
4. Run: `openclaw system event --text "Pical PR ready: notifications fix + appearance toggle" --mode now`
