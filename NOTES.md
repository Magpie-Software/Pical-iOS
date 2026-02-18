# Pical-iOS — Upcoming Adjustments (as of 2026-02-16)

1. **Event range**
   - Agenda should display every stored event (sorted) with no artificial date cutoff. Infinite scroll isn’t required because recurring events will live elsewhere.

2. **Recurring events tab**
   - Add a dedicated view/tab for recurring patterns (weekly/monthly) where entries read like “Mondays”, “First of the month”, etc. Recurring events need optional stop conditions: let users choose either a last occurrence date or a fixed number of repeats.

3. **Event duplication**
   - Provide a “Duplicate” action so users can clone an existing event (useful for irregular repeats that stay in the one-off list).

4. **Text truncation**
   - Long titles and locations should truncate gracefully in agenda rows (notes already do and should remain). Ensure truncation doesn’t break layout.

5. **Detail vs. edit flow**
   - Tapping an agenda row opens a detail sheet first. Include an explicit Edit button inside the detail view to enter edit mode.

6. **Timestamp presentation**
   - Make time optional metadata. Agenda rows should surface weekday labels (“Monday”) or dates depending on event type; time appears only if provided, under the title similar to location/notes.

7. **Tests**
   - Current Swift Testing cases are broken; note for later fix once functional updates land.

8. **Security/robustness**
   - Maintain input validation and avoid crashy flows even though the app is local-only.
