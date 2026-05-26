# Building release APKs (staging and production)

Environment is selected by **entrypoint** (`lib/main_*.dart`) and Android **product flavor** (`dev` / `prod`), matching [kipleHomev2](https://github.com/kiple/kipleHomev2) (`docs/BUILD_APK.md`). Run commands from the **repository root**.

## Environment overview

| Build | Entrypoint | Android flavor | Default API (K8s) | App label |
|--------|------------|----------------|---------------------|-----------|
| **Staging** | `lib/main_dev.dart` | `dev` | `https://kiplehome2-0-staging.kiple.com/` | KipleGuard (Staging) |
| **Production** | `lib/main_prod.dart` | `prod` | `https://kiplehome2-0.kiple.com/` | KipleGuard |

Optional overrides: `--dart-define=API_ENV=dev|prod`, `API_BASE_URL=...`, etc. (see `lib/core/api_env.dart`, `lib/core/app_config.dart`).

`lib/main_staging.dart` is an alias for the same staging APIs as `main_dev.dart`.

## Prerequisites

- Flutter on `PATH` (`flutter doctor`)
- Android SDK for release APKs

## Staging — release APK

```bash
flutter build apk -t lib/main_dev.dart --flavor dev --release --target-platform android-arm,android-arm64 --obfuscate --split-debug-info=build/app/outputs/apk/dev/release
```

**Output:** `build/app/outputs/flutter-apk/app-dev-release.apk`

## Production — release APK

```bash
flutter build apk -t lib/main_prod.dart --flavor prod --release --target-platform android-arm,android-arm64 --obfuscate --split-debug-info=build/app/outputs/apk/prod/release
```

**Output:** `build/app/outputs/flutter-apk/app-prod-release.apk`

## Helper scripts (Git Bash / WSL / macOS / Linux)

| Script | Environment | APK example |
|--------|-------------|-------------|
| `build_staging.sh` | Staging | `./build_staging.sh apk` |
| `build_prod.sh` | Production | `./build_prod.sh apk` |

Default (no argument) builds an **App Bundle** (`appbundle`). Pass `apk` for an APK.

On **Windows**, use **Git Bash** / **WSL** for `.sh` scripts, or the `flutter build apk` commands above in **PowerShell**.

## Run / debug

| Tool | Staging | Production |
|------|---------|------------|
| VS Code / Cursor | `staging_debug` in `.vscode/launch.json` | `prod_debug` |
| Android Studio | `staging_debug` (`.idea/runConfigurations/`) | `prod_debug` |

Android requires `--flavor dev` or `--flavor prod`. iOS configs omit `--flavor` (no Xcode flavors yet).

If **staging_debug** is missing in Android Studio:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/repair_android_studio_run_configs.ps1
```

Then restart Android Studio.

## Optional dart-define examples

```bash
./build_staging.sh apk --dart-define=API_BASE_URL=https://your-staging.example.com/
./build_prod.sh apk --dart-define=API_BASE_URL=https://your-prod.example.com/
```
