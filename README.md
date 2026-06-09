# KipleGuard Flutter

Guard mobile client for KipleGuard — visitor management, bookings, attendance, reporting, QR scan, and unit intercom. Built with **Flutter**, **Riverpod**, and **go_router**, aligned with the legacy Android KipleGuard app.

## Quick start

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (SDK `^3.11.0`).
2. Clone the repo and run `flutter pub get`.
3. Run staging debug: `flutter run -t lib/main_dev.dart --flavor dev`.

Full setup: **[docs/01_SETUP_GUIDE.md](docs/01_SETUP_GUIDE.md)**

## Documentation

Complete handover set (Markdown + Word):

**[docs/README.md](docs/README.md)**

| Document | Description |
|----------|-------------|
| Setup Guide | Prerequisites, run configs, codegen |
| Architecture | Layers, folders, HTTP, offline cache |
| API Documentation | Guard REST + legacy endpoints |
| Environment / Flavor Guide | Staging vs prod builds |
| Feature Documentation | Per-screen flows and files |
| Release Checklist | Pre-release QA steps |
| Play Store Deployment | AAB, signing, Play Console |
| Git Workflow | Branching and review |
| Testing Guide | Unit tests and manual QA |

## Tech stack

- `flutter_riverpod` / `hooks_riverpod` — state
- `go_router` — navigation
- `dio` — HTTP
- `freezed` / `json_serializable` — models (where used)
- `flutter_screenutil` — responsive layout
- `intl` + `lib/l10n/` — localization

## Project layout

```text
lib/
├── bootstrap/     # App entry bootstrap
├── core/          # Config, auth, cache, API client
├── router/        # go_router route table
├── service/       # Dio configuration
├── theme/         # Colors, typography, spacing
├── widget/        # Shared UI components
└── page/          # Feature modules (home, visitor, booking, …)
```

## Build (release APK)

See **[docs/04_ENVIRONMENT_FLAVOR_GUIDE.md](docs/04_ENVIRONMENT_FLAVOR_GUIDE.md)**.

```bash
# Staging
flutter build apk -t lib/main_dev.dart --flavor dev --release

# Production
flutter build apk -t lib/main_prod.dart --flavor prod --release
```

## License

Proprietary — Kiple / internal use.
