# Testing Guide

How to run automated tests and manual QA for KipleGuard Flutter.

## Automated tests

### Run all tests

```bash
flutter test
```

### Run a single file

```bash
flutter test test/page/booking/booking_parsers_test.dart
```

### Static analysis

```bash
dart analyze
```

Run both before every PR merge.

## Existing test files

| File | Covers |
|------|--------|
| `test/widget_test.dart` | Home dashboard smoke widget test |
| `test/page/booking/booking_parsers_test.dart` | Booking list/filter JSON parsing |
| `test/page/attendance/attendance_record_format_test.dart` | Attendance time/label formatting |
| `test/page/auth/guard_visitor_list_parser_test.dart` | Visitor list API parsing |

### Widget test pattern

`test/widget_test.dart` mocks SharedPreferences before bootstrap:

```dart
SharedPreferences.setMockInitialValues({
  OnboardingPrefs.key: true,
  AuthPrefs.sessionTokenKey: 'test_session',
});
await Future.wait([OnboardingPrefs.load(), AuthPrefs.load()]);
```

Use the same pattern when adding tests that depend on login/onboarding state.

## What to test in code

**High value:**

- JSON parsers (`*_parsers.dart`, `*_parser.dart`)
- Pure helpers (date format, filter logic, PIN validation helpers)
- Repository mapping with mocked `GuardHttpClient`

**Lower priority for unit tests:**

- Widget layout snapshots ( brittle )
- Full integration without mocks

## Manual QA matrix

Run on **staging** build (`main_dev.dart`, flavor `dev`) before release.

### Auth and session

| Test | Expected |
|------|----------|
| Login valid user | Lands on home or site picker |
| Login invalid | Error message from API |
| Session expired (401) | Single session dialog, redirect login |
| Logout | Returns to login, token cleared |

### Visitor

| Test | Expected |
|------|----------|
| List by date | Records load for selected day |
| Tab switch | Correct subset / counts |
| Offline | Banner shows cached data when airplane mode |
| Detail check-in/out | API success refreshes list |

### Booking

| Test | Expected |
|------|----------|
| Tab counts | All / checked in / upcoming |
| Facility filter | `samenity_id` applied |
| Search (≥ 3 chars) | Results filter; tab switch without re-fetch |
| Detail check-in/out | Status updates |

### Attendance

| Test | Expected |
|------|----------|
| PIN verify | API success proceeds to camera |
| Start shift | Selfie upload, success dialog |
| End shift | Requires open shift |
| Day calendar | Previous/next day navigation |

### Scan

| Test | Expected |
|------|----------|
| Visitor QR | Resolves visitor or error |
| Booking QR | Matching booking list |
| Health code | Temperature lookup |

### Reporting

| Test | Expected |
|------|----------|
| PIN gate | Blocks form until verified |
| Submit with photos | Success or queued offline |

### Register

| Test | Expected |
|------|----------|
| Unit / host pickers | Load from unit API |
| Submit registration | Success + access card |

### Profile

| Test | Expected |
|------|----------|
| Edit name | Persists via profile API |
| Change password | Validation + success |
| Offline data page | Lists cached entities |

## Device coverage

Minimum manual pass:

- [ ] One physical Android phone (primary)
- [ ] Android tablet if supported by layout
- [ ] iOS device (if iOS release planned)

## Regression after API changes

When backend changes response shape:

1. Update parser tests first
2. Run `flutter test`
3. Manual smoke on affected feature only

## Related documents

- [05_FEATURE_DOCUMENTATION.md](05_FEATURE_DOCUMENTATION.md)
- [06_RELEASE_CHECKLIST.md](06_RELEASE_CHECKLIST.md)
- [03_API_DOCUMENTATION.md](03_API_DOCUMENTATION.md)
