# Environment and Flavor Guide

Environment selection uses **Dart entrypoints**, **Android product flavors**, and optional **`--dart-define`** overrides. Aligned with kipleHomev2 build conventions.

## Environment overview

| Build | Entrypoint | Android flavor | Default API base | App label |
|-------|------------|----------------|------------------|-----------|
| **Staging** | `lib/main_dev.dart` | `dev` | `https://kiplehome2-0-staging.kiple.com/` | KipleGuard (Staging) |
| **Production** | `lib/main_prod.dart` | `prod` | `https://kiplehome2-0.kiple.com/` | KipleGuard |

`lib/main_staging.dart` — same staging APIs as `main_dev.dart`.

## How flavor is resolved

1. **Entrypoint** sets `AppFlavor` (`dev`, `staging`, or `prod`).
2. **`API_ENV` dart-define** can override: `dev` / `staging` → staging APIs; `prod` / `production` → production APIs (`lib/core/api_env.dart`).
3. **`AppConfig.baseUrl(flavor)`** picks the HTTP base URL.

## Android flavors

Defined in `android/app/build.gradle.kts`:

```kotlin
flavorDimensions += "env"
productFlavors {
    create("dev") { dimension = "env" … }
    create("prod") { dimension = "env" … }
}
```

**Always pass `--flavor dev` or `--flavor prod`** for Android builds and runs.

iOS: no Xcode flavors yet — use entrypoint + `dart-define` only.

## dart-define overrides

| Key | Purpose |
|-----|---------|
| `API_ENV` | `dev`, `staging`, `prod`, `production` — tier override |
| `API_BASE_URL` | Full API base URL |
| `X_APPLICATION_KEY` | Guard application key header |
| `WEB_PORTAL_URL` | Admin portal base |
| `FR_BASE_URL` | Face recognition web base |
| `EPASS_BASE_URL` | E-pass visitor URL |
| `TWILIO_VOIP_URL` | VoIP base |
| `TWILIO_PUSH_SID` | Twilio push credential SID |

Example:

```bash
flutter build apk -t lib/main_dev.dart --flavor dev --release \
  --dart-define=API_BASE_URL=https://your-staging.example.com/
```

Reference defaults: `lib/core/app_config.dart` (includes dev, staging K8s, prod K8s, and legacy IN/VN URLs for parity with Android JNI).

## Application keys

| Flavor | Key source |
|--------|------------|
| Staging / prod | Guard key via `AppConfig.xApplicationKey` |
| Dev | Legacy key unless overridden |

Override with `--dart-define=X_APPLICATION_KEY=...` — never commit production keys to git.

## Build release APK

### Staging

```bash
flutter build apk -t lib/main_dev.dart --flavor dev --release \
  --target-platform android-arm,android-arm64 \
  --obfuscate \
  --split-debug-info=build/app/outputs/apk/dev/release
```

**Output:** `build/app/outputs/flutter-apk/app-dev-release.apk`

### Production

```bash
flutter build apk -t lib/main_prod.dart --flavor prod --release \
  --target-platform android-arm,android-arm64 \
  --obfuscate \
  --split-debug-info=build/app/outputs/apk/prod/release
```

**Output:** `build/app/outputs/flutter-apk/app-prod-release.apk`

## Helper scripts

| Script | Environment | Example |
|--------|-------------|---------|
| `build_staging.sh` | Staging | `./build_staging.sh apk` |
| `build_prod.sh` | Production | `./build_prod.sh apk` |

Default (no argument) builds an **App Bundle** (`appbundle`). Pass `apk` for APK.

On Windows, use Git Bash/WSL for `.sh` scripts, or run `flutter build` commands directly in PowerShell.

## Run / debug configurations

### VS Code / Cursor (`.vscode/launch.json`)

| Config | Program | Flavor |
|--------|---------|--------|
| `staging_debug` | `main_dev.dart` | `dev` |
| `staging_release` | `main_dev.dart` | `dev` |
| `prod_debug` | `main_prod.dart` | `prod` |
| `prod_release` | `main_prod.dart` | `prod` |
| `*_ (iOS)` | same | *(no flavor)* |

### Android Studio

Use `staging_debug` / `prod_debug` from `.idea/runConfigurations/`. Repair if missing:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/repair_android_studio_run_configs.ps1
```

## Version and package identity

| Item | Location |
|------|----------|
| Version name / code | `pubspec.yaml` `version: x.y.z+build` |
| Android applicationId | `com.kipleguard.kiple_guard_flutter` (`build.gradle.kts`) |

## First install data wipe

On first launch after install, `AppFreshInstall` clears all `SharedPreferences` and sets an install marker. Android backup is disabled (`allowBackup=false`) to avoid restoring stale session data.

## Related documents

- [01_SETUP_GUIDE.md](01_SETUP_GUIDE.md)
- [06_RELEASE_CHECKLIST.md](06_RELEASE_CHECKLIST.md)
- [07_PLAY_STORE_DEPLOYMENT.md](07_PLAY_STORE_DEPLOYMENT.md)
