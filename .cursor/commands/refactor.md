# refactor

Refactor code using **SOLID** principles and keep **each Dart source file under 100 lines** when practical.

## Scope

1. **Hand-written code** in `lib/` — split oversized files into focused modules (single responsibility, dependency inversion via small APIs).
2. **Do not hand-edit generated code** — `lib/l10n/app_localizations*.dart` and other codegen outputs are excluded; change ARB / `flutter gen-l10n` sources instead.
3. **Central facades** — large "kitchen sink" APIs (e.g. a single `AppTextStyle` with hundreds of static styles) may need a **planned** API split (namespaces / typography tokens) before mechanical line splits; document exceptions in PR when touching them.

## How to split

- Prefer **feature folders** and **private helpers** over god files.
- **Router**: route tables can be split into `buildXxxRoutes(GlobalKey<NavigatorState>)` builders composed in one place.
- After splitting, run `dart analyze` on touched paths.

## Done when

- New/changed files respect the line budget where feasible.
- Behavior unchanged; analyzer clean.
