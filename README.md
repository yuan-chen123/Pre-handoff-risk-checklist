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

## Shared mode (v0.2)
- Password gate (`password`) with an "internal use only" notice, then a project list; one shared checklist per project, per-item comments, and changes from other people appear within ~3s (polling). Edits sync as per-field patches so two people editing different fields don't overwrite each other (same field: last write wins).
- **Local mode** (default, `config.js` empty): everything is stored in this browser only — fine for demos, not shared.
- **Shared mode:** create a Supabase project, run `supabase.sql`, paste URL + anon key into `config.js`. All access goes through password-checked SQL functions; change `'password'` in the SQL.
- **Security caveat:** the password is a shared secret checked in the page and the database. `password` is trivially guessable, and the site is a public GitHub Pages URL. Do not put confidential project data behind it until it's behind Zip SSO or at least a strong password.
- Project CRUD: create (name required), open/edit, rename (list, top bar, or the Project field in the checklist), duplicate, delete. Delete, and "Clear checklist", use a confirmation modal; Cancel is focused by default.
