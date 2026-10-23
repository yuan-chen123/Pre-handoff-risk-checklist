# Pre-handoff risk checklist (v0.1 pilot)

Single-file clickable prototype of the checklist: open `index.html` (or `python3 -m http.server 4190`).

Assumptions (not in the source design — adjust freely):
- Each module item is answered Met / Flag / N/A; unanswered items block "ready".
- Flag requires note/link + severity; Mitigate/Accept need owner + date; Blockers need "Resolved" ticked.
- Sign-off is blocked while any blocker is unresolved. Compliance/Legal required when B or D has flags; CX when C has flags.
- T6 ("Can a customer undo?") opens C when ticked, same as the other triage cards.
- State persists in localStorage. "Demo controls" (bottom right) fills sample data / resets.
- Palette is Zip tokens via CSS variables at the top of the file.
- Export (status bar): .html report, print/PDF, .csv, .json and copy-as-text, all built from one data model so they hold identical content. Incomplete checklists export marked DRAFT with an outstanding list.
