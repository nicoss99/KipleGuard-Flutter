# Architecture Document

## Overview

KipleGuard Flutter follows a **feature-first** layout: each screen module lives under `lib/page/<feature>/` with optional `widget/` subfolder. Shared infrastructure sits in `lib/core/`, `lib/router/`, `lib/service/`, and `lib/theme/`.

## Layer diagram

```text
┌─────────────────────────────────────────────────────────┐
│  UI: lib/page/*, lib/widget/*                           │
│  (ConsumerWidget, thin widgets, no direct HTTP)         │
└───────────────────────────┬─────────────────────────────┘
                            │ ref.watch / ref.read
┌───────────────────────────▼─────────────────────────────┐
│  State: *_provider.dart, *_state.dart (Riverpod)         │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│  Data: *_repository.dart                                │
│  Contracts: lib/core/api/contracts/*                    │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│  HTTP: GuardHttpClient → dioProvider (Dio)              │
└─────────────────────────────────────────────────────────┘
```

## Folder structure

```text
lib/
├── bootstrap/           bootstrap_app.dart — runApp, l10n, router shell
├── core/
│   ├── api/             GuardHttpClient, repository contracts
│   ├── auth/            Session expired, PIN verify helpers
│   ├── cache/           Offline list cache (SharedPreferences)
│   ├── app_config.dart  Base URLs, keys (dart-define overrides)
│   └── guard_api_paths.dart
├── router/              go_router table (app_router, *_routes)
├── service/             api_service.dart — Dio + interceptors
├── theme/               app_color, app_text_style, app_spacing, …
├── widget/              Shared components (AppButton, dialogs, HUD)
└── page/
    ├── home/
    ├── visitor/
    ├── booking/
    ├── attendance/
    └── …                One folder per feature
```

### Feature module convention

Each feature typically contains:

| File pattern | Role |
|--------------|------|
| `*_page.dart` | Screen widget |
| `*_provider.dart` | Riverpod notifier / async provider |
| `*_state.dart` | Immutable state (often freezed) |
| `*_repository.dart` | API calls (or uses shared guard repo) |
| `*_model.dart` | UI / domain models |
| `widget/` | Page-only widgets |

Target: hand-written files **≤ ~100 lines** where practical; split large files within the feature.

## State management (Riverpod)

- Providers declared at **top level** in `*_provider.dart` — not nested inside widget classes.
- Naming: `homeProvider`, `bookingListProvider`, etc.
- Sync state: `Notifier` / `NotifierProvider`
- Async / API: `FutureProvider`, `AsyncNotifier`, or `FutureProvider.family`
- Widgets use `ConsumerWidget` / `Consumer` with `ref.watch` / `ref.read`

## Navigation

- **go_router** only — no `Navigator.push` for app routes.
- Route definitions: `lib/router/app_route.dart` + composed modules (`home_routes.dart`, `login_routes.dart`, …).
- Redirect logic: onboarding complete, logged-in session (`lib/router/app_router.dart`).

## HTTP stack

### Dio configuration

`lib/service/api_service.dart` (`dioProvider`):

- Base URL from `AppConfig.baseUrl(flavor)`
- Headers: `Accept`, `Content-Type`, `X-Application-Key`
- `Authorization: Bearer <token>` on guard paths (except login/logout)
- 401 / session superseded → `session_expired_handler.dart`

### Guard HTTP client

`lib/core/api/client/dio_guard_http_client.dart` implements `GuardHttpClient`:

| Method | Use |
|--------|-----|
| `getJson` | GET with `{ success, data }` envelope check |
| `postJson` | POST with envelope check; returns `data` |
| `postGuardEnvelope` | Full envelope `{ data, message }` |
| `postMultipart` | File uploads (attendance selfie, incidents, register) |
| `postRaw` / `getRaw` | Legacy endpoints without guard envelope |

### Response envelope

Guard APIs return:

```json
{
  "success": true,
  "message": "Success.",
  "data": { }
}
```

Parsing: `lib/core/guard_api_message.dart` (`guardApiSuccess`, `guardApiData`).

Legacy `data/*` endpoints return `{ "resource": [ ... ] }` without `success`.

## Authentication and session

| Component | Path |
|-----------|------|
| Token storage | `lib/core/auth_prefs.dart` |
| Login | `GuardRepository.login` → `POST api/v1/guard/auth/login` |
| Logout | Clears session + dashboard prefs |
| Session expired | Single dialog app-wide (`session_expired_handler.dart`) |
| PIN verify | `POST api/v1/guard/auth/verify-pin` via `guard_pin_verify.dart` |

## Persistence

| Store | Purpose |
|-------|---------|
| `SharedPreferences` | Session, onboarding, dashboard/residence selection |
| `AppCacheStore` | Offline guard list payloads (visitors, bookings, attendance) |
| `GuardListCache` | Typed read/write for list caches |
| `AppFreshInstall` | Clears all prefs on first launch after install |

Cache flush on app background: `CacheLifecycleHost` → `AppCachePersistence.flushAll()`.

## Bootstrap sequence

`lib/bootstrap/bootstrap_app.dart`:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `AppFreshInstall.ensureCleanFirstLaunch()`
3. `OnboardingPrefs.load()`, `AuthPrefs.load()`
4. `runApp` with `ProviderScope` and flavor override

## Theming and UI rules

- All colors, spacing, typography via `lib/theme/` — no magic numbers in widgets.
- Full-screen loading: `lib/widget/modal_progress_hud.dart`
- Responsive units: `flutter_screenutil` (`.w`, `.h`, `.sp`, `.r`)
- Font: Manrope via `app_text_style.dart`

## SOLID / separation

- **UI** does not call HTTP or own business rules.
- **Repositories** map JSON → domain/UI models.
- **Providers** hold state and orchestrate repos — no `BuildContext` in providers.

## Related documents

- [03_API_DOCUMENTATION.md](03_API_DOCUMENTATION.md)
- [05_FEATURE_DOCUMENTATION.md](05_FEATURE_DOCUMENTATION.md)
- `.cursor/rules/flutter-riverpod-fast-ui.mdc` — enforced coding standards
