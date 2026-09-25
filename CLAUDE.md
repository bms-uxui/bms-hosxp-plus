# Project instructions

- ER module UI must follow the design language in [docs/design-rules.md](docs/design-rules.md). Read it before changing any ER screen.
- Medical/business rules live in [docs/knowledge.md](docs/knowledge.md) section 0; record new ones there.
- Run the ER module with `flutter run --dart-define=START=/erFlowHome`; never hardcode `initialLocation` in `nav.dart`.

## Working together in Live Share

Several Claude sessions (one per person, each on its own account) may edit this repo at the same time.
- Reply in Thai.
- Only edit files in the folder you were assigned (for example `features/workflow/`). Ask before touching `core/` or `er_flow_home_widget.dart`.
- Never run repo-wide rewrites (`dart format lib/`, mass renames, scripts that regenerate whole files). Format only the files you changed.
- Do not start or stop `flutter run`; the host owns it. Ask the host to hot reload.
- Commit only when your person asks, and only your own files (`git add <paths>`, never `git add -A`).
- Never enter a real Provider ID or PIN. Do not modify the 3D vessel layer.
