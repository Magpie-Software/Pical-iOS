# Pical-iOS — Planning Notes (updated 2026-02-18)

## ✅ Recently Shipped
The following items from the 2026-02-16 plan are done and living in `main`:
- Agenda shows the full stored set, chronologically sorted.
- Dedicated Recurring tab with weekly/monthly patterns + stop conditions.
- Agenda row swipe actions for Duplicate/Edit/Delete, plus graceful truncation and optional timestamps.
- Detail sheets precede edit flows for both agenda + recurring entries.
- Swift Testing coverage restored for the new models and store behaviors.
- General robustness pass on input trimming, optional fields, and non-crashy flows.

## 🔭 Next Wave Focus
1. **Daily refresh job**
   - On launch/background task, purge past one-off events and decrement “occurrences remaining” for recurring entries whose date truly passed.

2. **Options tab**
   - Third tab housing: feedback link, bug report form, usage guide, acknowledgments, donation/support links (Ko-fi/Patreon/BMAC research for 2026 best options).

3. **Grouping options**
   - Setting to group recurring events by weekday labels.
   - Setting to group agenda items by date headers (ribbon badges) as an alternative to the current left-column labels.

4. **Smart agenda grouping**
   - Auto sections like “Today”, “This Week”, “Next Week”, “Later” with a user-facing toggle.

5. **Detail sheet quick actions**
   - Add Duplicate + Delete buttons to the bottom of agenda + recurring detail sheets (full-width or side-by-side rows).

6. **Visual refinements**
   - Revisit weekday presentation to avoid wrapping issues (e.g., “Wednesday”).
   - General layout polish before theming.

7. **Future launch prep**
   - Continue tightening overall personality (bird accents, tone, copy) and track App Store submission to-dos as features stabilize.

8. **Daily event notifications (queued)**
   - Add toggles for agenda vs. recurring reminders, schedule time-of-day pickers, and only send on days with events.
