# Setup Guide

## Prerequisites

| Requirement | Version / notes |
|-------------|-----------------|
| Flutter SDK | `^3.11.0` (see `pubspec.yaml`) |
| Dart | Bundled with Flutter |
| Android Studio or VS Code | With Flutter & Dart plugins |
| Android SDK | For Android builds (API level per `flutter.minSdkVersion`) |
| Xcode | Optional — iOS run/debug (no product flavors on iOS yet) |
| Git | Clone and version control |

Verify installation:

```bash
flutter doctor
```

## Clone and install dependencies

```bash
git clone <repository-url>
cd KipleGuard-Flutter
flutter pub get
```

## Code generation (when needed)

Some models use **freezed** / **json_serializable**. After adding or changing annotated models:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Run this when you see missing `.freezed.dart` / `.g.dart` files or analyzer errors on generated code.

## Entrypoints and flavors

| Environment | Dart entrypoint | Android flavor | Default API host |
|-------------|-----------------|----------------|------------------|
| Staging | `lib/main_dev.dart` | `dev` | `https://kiplehome2-0-staging.kiple.com/` |
| Production | `lib/main_prod.dart` | `prod` | `https://kiplehome2-0.kiple.com/` |

`lib/main_staging.dart` is an alias for the same staging APIs as `main_dev.dart`.

`lib/main.dart` defaults to production flavor for IDE runs without a flavor.

## Run / debug

### Command line (Android)

```bash
# Staging debug
flutter run -t lib/main_dev.dart --flavor dev

# Production debug
flutter run -t lib/main_prod.dart --flavor prod
```

**Android requires** `--flavor dev` or `--flavor prod`. Omitting flavor causes a Gradle error.

### VS Code / Cursor

Use launch configs in `.vscode/launch.json`:

| Config | Entrypoint | Flavor |
|--------|------------|--------|
| `staging_debug` | `main_dev.dart` | `dev` |
| `prod_debug` | `main_prod.dart` | `prod` |
| `staging_debug (iOS)` | `main_dev.dart` | *(none)* |
| `prod_debug (iOS)` | `main_prod.dart` | *(none)* |

### Android Studio

Import run configurations from `.idea/runConfigurations/` (`staging_debug`, `prod_debug`). If missing:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/repair_android_studio_run_configs.ps1
```

Then restart Android Studio.

## Localization

Strings live in `lib/l10n/app_en.arb`. After editing ARB files:

```bash
flutter gen-l10n
```

Feature-specific string facades (e.g. `booking_strings.dart`) delegate to `AppLocalizations`.

## Environment overrides

Override API base URL or keys at build/run time:

```bash
flutter run -t lib/main_dev.dart --flavor dev \
  --dart-define=API_BASE_URL=https://your-staging.example.com/
```

See [04_ENVIRONMENT_FLAVOR_GUIDE.md](04_ENVIRONMENT_FLAVOR_GUIDE.md) for all supported `dart-define` keys.

## Common issues

| Issue | Fix |
|-------|-----|
| Gradle asks for flavor | Add `--flavor dev` or `--flavor prod` on Android |
| Missing generated files | Run `build_runner` (see above) |
| Session / stale data after reinstall | First launch clears prefs via `AppFreshInstall` |
| Analyzer errors after pull | `flutter pub get`, then `dart analyze` |
| iOS build without flavor | Use `(iOS)` launch configs — flavors are Android-only |

## Next steps

- [02_ARCHITECTURE.md](02_ARCHITECTURE.md) — project structure
- [04_ENVIRONMENT_FLAVOR_GUIDE.md](04_ENVIRONMENT_FLAVOR_GUIDE.md) — release builds
- [03_API_DOCUMENTATION.md](03_API_DOCUMENTATION.md) — backend endpoints
