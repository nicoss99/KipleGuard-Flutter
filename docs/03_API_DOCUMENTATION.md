# API Documentation

Client-side reference for KipleGuard Flutter HTTP usage. **Authoritative path list:** `lib/core/guard_api_paths.dart`.

## Base URL and headers

| Item | Source |
|------|--------|
| Base URL | `AppConfig.baseUrl(flavor)` — see [04_ENVIRONMENT_FLAVOR_GUIDE.md](04_ENVIRONMENT_FLAVOR_GUIDE.md) |
| Staging default | `https://kiplehome2-0-staging.kiple.com/` |
| Production default | `https://kiplehome2-0.kiple.com/` |
| App key | Header `X-Application-Key` from `AppConfig.xApplicationKey(flavor)` |
| Session | Header `Authorization: Bearer <token>` on guard paths except login/logout |

**Security:** Application keys and tokens are configured via `lib/core/app_config.dart` or `--dart-define`. Do not commit production secrets; use CI/build-time defines.

## Response conventions

### Guard envelope (most `/api/v1/guard/*` endpoints)

```json
{
  "success": true,
  "message": "Success.",
  "data": { }
}
```

- Success when `success` is truthy (`true`, `"true"`, `1`).
- Business data in `data` object.
- Errors: `success: false` with `message` string.
- HTTP **401** → app shows session-expired dialog (except login/logout).

Client parsing: `lib/core/guard_api_message.dart`, `DioGuardHttpClient`.

### Legacy DreamFactory-style

Paths like `data/kg_guards`, `data/bookings` return:

```json
{
  "resource": [ { } ]
}
```

No `success` wrapper. Used by `getRaw` / direct Dio in `ScanRepository`, `HomeRepository`.

---

## Auth and profile

Repository: `lib/page/auth/guard_repository.dart`  
Contract: `lib/core/api/contracts/guard_auth_repository.dart`

| Method | Path | Body / query | Notes |
|--------|------|--------------|-------|
| POST | `api/v1/guard/auth/login` | `email_or_phone`, `password`, `device_unique_id`, `device_model`, `brand`, optional `is_proceed: 1` | Returns `data.token`, `data.guard`, `data.residences`, optional `switch_device` |
| POST | `api/v1/guard/auth/logout` | — | Clears server session |
| POST | `api/v1/guard/auth/change-password` | `current_password`, `new_password`, `new_password_confirmation` | |
| POST | `api/v1/guard/auth/verify-pin` | `{ "pin": "112233" }` | Success when `success: true` **or** `data.pin_verified: true` |
| GET | `api/v1/guard/me` | — | `data.guard`, `data.residences` |
| GET | `api/v1/guard/residences` | — | Site list for guard |

### verify-pin example

**Request:**

```json
{ "pin": "112233" }
```

**Response:**

```json
{
  "success": true,
  "message": "PIN verified.",
  "data": {
    "pin_verified": true
  }
}
```

---

## Attendance

Repository: `lib/page/auth/guard_attendance_repository.dart`

| Method | Path | Body / query |
|--------|------|--------------|
| POST (multipart) | `api/v1/guard/residences/{uuid}/attendance/start` | `current_time`, `selfie_photo` (file) |
| POST (multipart) | `api/v1/guard/residences/{uuid}/attendance/end` | `current_time`, `selfie_photo` (file) |
| GET | `api/v1/guard/residences/{uuid}/attendance` | `from`, `to` (yyyy-MM-dd) |

Response list: `data.attendance[]`. Open shift check uses records where checkout is null.

---

## Visitors

Repository: `lib/page/auth/guard_visitor_repository.dart`

| Method | Path | Query / body |
|--------|------|--------------|
| GET | `api/v1/guard/residences/{uuid}/visitors` | `date` (yyyy-MM-dd), optional `status` |
| GET | `api/v1/guard/residences/{uuid}/visitors/{id}` | — |
| POST | `api/v1/guard/residences/{uuid}/visitors/scan` | `{ "qr_code_data": "..." }` |
| POST | `api/v1/guard/residences/{uuid}/visitors/{id}/check-in` | — |
| POST | `api/v1/guard/residences/{uuid}/visitors/{id}/check-out` | — |

List response includes `date`, `counts`, and visitor array (parsed in `guard_visitor_list_parser.dart`).

---

## Register visitor

Repository: `lib/page/register/register_repository.dart`

| Method | Path | Body |
|--------|------|------|
| GET | `api/v1/guard/residences/{scopeUuid}/visitor-types` | — |
| POST (multipart) | `api/v1/guard/residences/{scopeUuid}/visitors` | See fields below |

**Multipart fields** (`register_payload.dart`):

| Field | Description |
|-------|-------------|
| `visitor_type_id` | Type id or uuid |
| `unit_uuid` | Selected unit |
| `visitor_name`, `phone`, `ic_passport_no`, `email` | Guest details |
| `temperature`, `pass_id`, `vehicle_number`, `purpose` | |
| `photo` | Visitor photo file |
| `guest_of_user_id` | Optional host user id |

**Legacy follow-up:**

| Method | Path | Body |
|--------|------|------|
| POST | `accesscards/newvisitor` | `visitor_uuid`, `visitor_type_uuid`, `unit_uuid`, `residence_uuid` |

---

## Bookings

Repository: `lib/page/booking/guard_booking_repository.dart`

| Method | Path | Query / body |
|--------|------|--------------|
| GET | `api/v1/guard/residences/{uuid}/bookings` | See below |
| GET | `api/v1/guard/residences/{uuid}/bookings/filters` | — |
| GET | `api/v1/guard/residences/{uuid}/bookings/{id}` | — |
| POST | `api/v1/guard/residences/{uuid}/bookings/{id}/check-in` | `{ "current_time": "..." }` |
| POST | `api/v1/guard/residences/{uuid}/bookings/{id}/check-out` | `{ "current_time": "..." }` |

**List query parameters:**

| Param | Values | Notes |
|-------|--------|-------|
| `date` | `yyyy-MM-dd` | Required |
| `tab` | `all_bookings`, `checked_in`, `upcoming` | |
| `samenity_id` | integer | Facility filter |
| `search` | string (≥ 3 chars) | Guest/unit search |

**Filters response** (`data`):

```json
{
  "statuses": [
    { "label": "All Bookings", "value": "all_bookings" }
  ],
  "facilities": [
    { "label": "...", "value": "...", "samenity_id": 1 }
  ]
}
```

---

## Reporting (incidents)

Repository: `lib/page/reporting/reporting_repository.dart`

| Method | Path | Body |
|--------|------|------|
| GET | `api/v1/guard/residences/{uuid}/incidents/types` | — |
| POST (multipart) | `api/v1/guard/residences/{uuid}/incidents` | `incident_type`, `description`, `incident_at`, `photos[]` (files) |

Requires guard PIN verification before form entry (`reporting_gate_page.dart`).

---

## Unit call / intercom directory

Repository: `lib/page/unit_call/guard_unit_call_repository.dart`

| Method | Path | Query |
|--------|------|-------|
| GET | `api/v1/guard/residences/{uuid}/units/blocks` | — |
| GET | `api/v1/guard/residences/{uuid}/units/floors` | `block` |
| GET | `api/v1/guard/residences/{uuid}/units` | optional `block`, `floor` |
| GET | `api/v1/guard/residences/{uuid}/units/{unitUuid}/hosts` | — |

Also used by register-visit unit/host pickers.

---

## Legacy and auxiliary endpoints

Same Dio instance (`dioProvider`); different response shapes.

| Method | Path | Used by | Notes |
|--------|------|---------|-------|
| GET | `data/kg_guards` | `HomeRepository` | Filter `security_company_uuid`; guard PIN list JSON |
| GET | `visit/scan-qr/{residenceUuid}/{qr}` | `ScanRepository` | Legacy QR lookup |
| GET | `data/bookings` | `ScanRepository` | DreamFactory filter for booking QR |
| GET | `data/applications` | `ScanRepository` | HDF form list |
| GET | `data/students` | `ScanRepository` | Guardian student lookup |
| POST | `healthcode/temperature` | `ScanRepository` | Health code temperature |

---

## Repository → contract map

| Contract | Implementation |
|----------|----------------|
| `GuardAuthRepository` | `GuardRepository` |
| `GuardVisitorRepository` | `GuardVisitorRepository` |
| `GuardAttendanceRepository` | `GuardAttendanceRepositoryImpl` |
| `GuardBookingRepository` | `GuardBookingRepositoryImpl` |
| `GuardReportingRepository` | `ReportingRepository` |
| `GuardRegisterRepository` | `RegisterRepository` |
| `GuardUnitCallRepository` | `GuardUnitCallRepositoryImpl` |
| `LegacyGuardDataRepository` | `HomeRepository` |

---

## Error handling in the app

| Layer | Behavior |
|-------|----------|
| Repository | Maps `DioException` → user message via `guardApiMessage` / `apiErrorMessage` |
| UI | `showApiFailedDialog` for failures; session expired deduplicated |
| Offline | List features fall back to `GuardListCache` when network unavailable |

---

## Maintaining this document

When adding an endpoint:

1. Add path to `lib/core/guard_api_paths.dart`
2. Implement in the appropriate `*_repository.dart`
3. Update this file and regenerate Word export if required
