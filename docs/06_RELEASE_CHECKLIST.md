# Release Checklist

Use this checklist before each store or client handover release.

## 1. Code quality

- [ ] `flutter pub get` succeeds
- [ ] `dart analyze` — no errors
- [ ] `flutter test` — all tests pass
- [ ] No debug-only code paths left enabled unintentionally
- [ ] `flutter gen-l10n` run if ARB files changed

## 2. Version bump

- [ ] Update `version:` in `pubspec.yaml` (e.g. `1.0.1+2` — name + build number)
- [ ] Confirm Android `versionCode` / `versionName` sync from pubspec
- [ ] Prepare release notes (features, fixes, known issues)

## 3. Staging build and QA

- [ ] Build staging APK:

```bash
flutter build apk -t lib/main_dev.dart --flavor dev --release
```

- [ ] Install on physical device(s)
- [ ] Smoke test matrix (minimum):

| Area | Checks |
|------|--------|
| Login / logout | Valid credentials, session expired on 401 |
| Site selection | Residence switch persists |
| Visitor | List load, tab switch, detail, offline banner |
| Booking | Date change, filter, search, detail check-in/out |
| Attendance | PIN verify, start/end shift, camera |
| Scan | QR visitor / booking paths |
| Reporting | PIN gate, submit incident |
| Register | Full walk-in flow |
| Profile | Edit name, change password |

## 4. Production build

- [ ] QA sign-off on staging build
- [ ] Build production APK or AAB:

```bash
# APK
flutter build apk -t lib/main_prod.dart --flavor prod --release

# Play Store bundle
flutter build appbundle -t lib/main_prod.dart --flavor prod --release
```

- [ ] Verify app label is **KipleGuard** (not Staging)
- [ ] Verify API points to production base URL (no staging dart-define left)

## 5. Security and config

- [ ] No secrets committed (keys, keystores, `.env`)
- [ ] Release signing configured (replace debug signing before store release — see [07_PLAY_STORE_DEPLOYMENT.md](07_PLAY_STORE_DEPLOYMENT.md))
- [ ] `allowBackup=false` on Android (fresh install behavior)

## 6. Post-release

- [ ] Git tag: `v1.0.1` (match pubspec version)
- [ ] Upload AAB/APK to Play Console or distribution channel
- [ ] Archive build artifacts and mapping files (`--split-debug-info` output)
- [ ] Notify QA / stakeholders with release notes

## Rollback plan

- Keep previous AAB/APK and mapping files
- Play Console: halt rollout or promote previous release
- Document hotfix branch process per [08_GIT_WORKFLOW_GUIDE.md](08_GIT_WORKFLOW_GUIDE.md)
