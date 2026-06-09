# Play Store Deployment Guide

Steps to publish KipleGuard Flutter to Google Play.

## Prerequisites

- Google Play Developer account
- Flutter SDK and Android SDK installed
- Release keystore (create if none exists — **do not commit to git**)

## App identity

| Item | Value |
|------|-------|
| Application ID | `com.kipleguard.kiple_guard_flutter` |
| Package | `android/app/build.gradle.kts` |

## Signing configuration

Current `android/app/build.gradle.kts` uses **debug signing** for release builds (TODO in project). Before Play Store upload:

1. Create a release keystore (store outside repo):

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Add `android/key.properties` (gitignored):

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-upload-keystore.jks>
```

3. Configure `signingConfigs` and assign to `release` buildType in `build.gradle.kts`.

4. Never commit keystore or passwords to version control.

## Build App Bundle (recommended)

```bash
flutter build appbundle -t lib/main_prod.dart --flavor prod --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/bundle/prod/release
```

Or use helper script:

```bash
./build_prod.sh
```

**Output:** `build/app/outputs/bundle/prodRelease/app-prod-release.aab`

## Build APK (side-loading / internal)

```bash
flutter build apk -t lib/main_prod.dart --flavor prod --release
```

Output: `build/app/outputs/flutter-apk/app-prod-release.apk`

## Play Console workflow

1. **Create app** (first time) — default language, app name **KipleGuard**
2. **App content** — complete privacy policy, data safety, content rating questionnaires
3. **Release → Testing → Internal testing** — upload AAB, add testers
4. Verify on internal track:
   - Login, site selection, one flow per major module
   - Permissions prompts (camera, location, phone) behave correctly
5. **Production release** — promote from internal/closed testing or upload new AAB
6. Set rollout percentage if staged rollout desired

## Version codes

- `version` in `pubspec.yaml`: `1.0.0+1` → versionName `1.0.0`, versionCode `1`
- Each Play upload must increment **versionCode** (the number after `+`)

## Permissions (AndroidManifest)

Declared capabilities include:

| Permission | Used for |
|------------|----------|
| `CAMERA` | Attendance selfie, register photo, scan QR |
| `RECORD_AUDIO` | Unit call / intercom (if enabled) |
| `CALL_PHONE` | Dial from unit call |
| `ACCESS_FINE_LOCATION` / `COARSE` | Reporting incident location |

Document these in Play Console Data safety form.

## Backup and data

`android:allowBackup="false"` — user data is not auto-restored on reinstall; first launch clears prefs via `AppFreshInstall`.

## Obfuscation

Release builds use `--obfuscate` with `--split-debug-info`. **Upload deobfuscation files** to Play Console (App bundle explorer → Downloads) for readable crash reports.

## Troubleshooting

| Issue | Action |
|-------|--------|
| Version code already used | Increment build number in pubspec |
| Signing error | Verify `key.properties` and keystore path |
| Missing flavor | Add `--flavor prod` |
| Wrong API environment | Confirm `main_prod.dart` entrypoint, no staging dart-define |

## Related documents

- [04_ENVIRONMENT_FLAVOR_GUIDE.md](04_ENVIRONMENT_FLAVOR_GUIDE.md)
- [06_RELEASE_CHECKLIST.md](06_RELEASE_CHECKLIST.md)
