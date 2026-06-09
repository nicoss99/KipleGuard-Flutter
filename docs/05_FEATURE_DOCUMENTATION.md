# Feature Documentation

Per-feature overview: purpose, routes, key files, and API dependencies. API details in [03_API_DOCUMENTATION.md](03_API_DOCUMENTATION.md).

## Route reference

All paths from `lib/router/app_route.dart`:

| Route name | Path |
|------------|------|
| `onboardingIntro` | `/onboarding-intro` |
| `onboarding` | `/onboarding` |
| `login` | `/login` |
| `home` | `/home` |
| `selectSite` | `/select-site` |
| `visitor` | `/visitor` |
| `visitorDetails` | `/visitor/:visitorUuid` |
| `booking` | `/booking` |
| `bookingDetail` | `/booking/:bookingUuid` |
| `attendance` | `/attendance` |
| `reporting` | `/reporting` |
| `reportingForm` | `/reporting/form` |
| `scanQr` | `/scan` |
| `scanHealth` | `/scan/health` |
| `scanForm` | `/scan/form/:formUuid` |
| `register` | `/register` |
| `registerVisit` | `/register/visit/:residenceUuid` |
| `callUnits` | `/call-units` |
| `callRecent` | `/call-recent` |
| `editProfile` | `/profile` |
| `changePassword` | `/profile/change-password` |
| `profileOffline` | `/profile/offline` |

---

## Onboarding

**Purpose:** First-run intro and completion flag.

| Item | Location |
|------|----------|
| Pages | `lib/page/onboarding/` |
| Prefs | `lib/core/onboarding_prefs.dart` |
| Router redirect | Incomplete → `/onboarding-intro` |

No backend API. Cleared on fresh install until user completes flow again.

---

## Login

**Purpose:** Guard authentication and session bootstrap.

| Item | Location |
|------|----------|
| Page | `lib/page/login/login_page.dart` |
| Provider | `lib/page/login/login_provider.dart` |
| Repository | `lib/page/auth/guard_repository.dart` |

**API:** `POST api/v1/guard/auth/login` with device fields (`LoginDeviceInfo`).

**Flow:** Login → token stored in `AuthPrefs` → redirect to home or site selection.

---

## Home / dashboard

**Purpose:** Module grid (attendance, visitor, booking, scan, etc.) driven by residence capabilities.

| Item | Location |
|------|----------|
| Page | `lib/page/home/home_page.dart` |
| Provider | `lib/page/home/home_provider.dart` |
| Prefs | `lib/core/dashboard_prefs.dart` |

**API:** Loads guard PIN JSON via `GET data/kg_guards` when `securityUuid` is set; refreshes residences from guard API.

---

## Select site

**Purpose:** Choose active residence when guard has multiple sites.

| Item | Location |
|------|----------|
| Page | `lib/page/select_site/select_site_page.dart` |

**API:** `GET api/v1/guard/residences` (cached from login / me).

Writes selection to `DashboardPrefs` and `ResidencePrefs`.

---

## Visitor

**Purpose:** Daily visitor list with tabs (check-in, incoming, overtime), detail, check-in/out.

| Item | Location |
|------|----------|
| Page | `lib/page/visitor/visitor_page.dart` |
| Provider | `lib/page/visitor/visitor_provider.dart` |
| Repository | `lib/page/auth/guard_visitor_repository.dart` |

**API:** `GET/POST …/visitors`, detail, check-in/out.

**Offline:** `GuardListCache.saveVisitors` / `readVisitors`.

---

## Booking

**Purpose:** Daily booking list with tabs, facility filter, search, detail check-in/out.

| Item | Location |
|------|----------|
| Page | `lib/page/booking/booking_page.dart` |
| Provider | `lib/page/booking/booking_provider.dart` |
| Repository | `lib/page/booking/guard_booking_repository.dart` |

**API:** Bookings list, filters, detail, check-in/out.

**Search:** Inline bar; API `search` param + client-side filter; cross-tab search pool.

---

## Attendance

**Purpose:** View guard attendance records; start/end shift with PIN + selfie.

| Item | Location |
|------|----------|
| Page | `lib/page/attendance/attendance_page.dart` |
| Provider | `lib/page/attendance/attendance_provider.dart` |
| Shift dialog | `lib/page/attendance/widget/attendance_shift_dialog.dart` |
| Repository | `lib/page/auth/guard_attendance_repository.dart` |

**Flow:** PIN dialog (`verify-pin` API) → open-shift check → camera → multipart start/end.

**API:** Attendance list, start, end.

---

## Scan QR

**Purpose:** QR scanning for visitors, bookings, health code, HDF forms.

| Item | Location |
|------|----------|
| Pages | `lib/page/scan/` |
| Repository | `lib/page/scan/scan_repository.dart` |

**API:** Mix of guard visitor scan and legacy `visit/scan-qr`, `data/bookings`, `data/applications`, `healthcode/temperature`.

---

## Register visit

**Purpose:** Walk-in visitor registration with unit, host, photo, visitor type.

| Item | Location |
|------|----------|
| Pages | `lib/page/register/` |
| Repository | `lib/page/register/register_repository.dart` |

**API:** Visitor types, multipart register, unit call directory, `accesscards/newvisitor`.

---

## Reporting

**Purpose:** Incident report with category, description, photos, location.

| Item | Location |
|------|----------|
| Gate | `lib/page/reporting/reporting_gate_page.dart` (PIN) |
| Form | `lib/page/reporting/reporting_form_page.dart` |
| Repository | `lib/page/reporting/reporting_repository.dart` |
| Offline sync | `lib/page/reporting/reporting_sync_service.dart` |

**API:** Incident types, multipart create incident.

**Flow:** PIN verify → form → submit (may queue offline).

---

## Unit call

**Purpose:** Browse units by block/floor; call intercom / view hosts.

| Item | Location |
|------|----------|
| Pages | `lib/page/unit_call/` |
| Repository | `lib/page/unit_call/guard_unit_call_repository.dart` |
| Cache | `lib/core/cache/guard_unit_call_cache.dart` |

**API:** Units blocks, floors, list, hosts.

---

## Profile

**Purpose:** View/edit guard name, change password, logout, offline data viewer.

| Item | Location |
|------|----------|
| Pages | `lib/page/profile/` |
| Provider | `lib/page/profile/profile_provider.dart` |

**API:** `GET api/v1/guard/me`, `POST change-password`, `POST logout`.

---

## Shared components

| Component | Path | Used for |
|-----------|------|----------|
| `GuardPinDialog` | `lib/widget/guard_pin_dialog.dart` | Attendance shift, reporting gate |
| `ModalProgressHud` | `lib/widget/modal_progress_hud.dart` | Full-screen loading |
| `OfflineCacheBanner` | `lib/widget/offline_cache_banner.dart` | Stale data indicator |
| Session expired | `lib/core/auth/session_expired_handler.dart` | Global 401 handling |

---

## Related documents

- [02_ARCHITECTURE.md](02_ARCHITECTURE.md)
- [03_API_DOCUMENTATION.md](03_API_DOCUMENTATION.md)
- [09_TESTING_GUIDE.md](09_TESTING_GUIDE.md)
