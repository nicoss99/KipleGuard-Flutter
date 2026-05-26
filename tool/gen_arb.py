import json
import re
from pathlib import Path

PREFIX_MAP = {
    "attendance_strings.dart": "attendance",
    "booking_strings.dart": "booking",
    "dashboard_strings.dart": "dashboard",
    "profile_strings.dart": "profile",
    "register_strings.dart": "register",
    "reporting_strings.dart": "reporting",
    "scan_strings.dart": "scan",
    "select_site_strings.dart": "selectSite",
    "unit_call_strings.dart": "unitCall",
    "visitor_strings.dart": "visitor",
}

entries: dict[str, str] = {}
for path in Path("lib").rglob("*_strings.dart"):
    name = path.name
    if name not in PREFIX_MAP:
        continue
    pref = PREFIX_MAP[name]
    text = path.read_text(encoding="utf-8")
    for m in re.finditer(r"static const (\w+) = '((?:[^'\\]|\\.)*)';", text):
        key, val = m.group(1), m.group(2)
        arb_key = pref + key[0].upper() + key[1:]
        entries[arb_key] = val.encode().decode("unicode_escape")
    for m in re.finditer(r'static const (\w+) = "((?:[^"\\]|\\.)*)";', text):
        key, val = m.group(1), m.group(2)
        arb_key = pref + key[0].upper() + key[1:]
        entries[arb_key] = val.encode().decode("unicode_escape")

entries.update(
    {
        "commonCancel": "Cancel",
        "commonSubmit": "Submit",
        "commonDone": "Done",
        "commonOk": "OK",
        "commonSuccess": "Success!",
        "commonYes": "Yes",
        "commonNo": "No",
        "commonClear": "Clear",
        "commonApply": "Apply",
        "commonRetry": "Retry",
        "apiSomethingWentWrong": "Something went wrong",
        "apiRequestFailed": "Request failed",
        "apiNetworkError": "Network error",
        "apiLoginFailed": "Login failed",
        "apiInvalidLoginPayload": "Invalid login payload",
        "apiInvalidCredentials": "Invalid username / password",
        "apiLogoutFailed": "Logout failed",
        "apiProfileLoadFailed": "Failed to load profile",
        "apiResidencesLoadFailed": "Failed to load residences",
        "apiAttendanceLoadFailed": "Failed to load attendance",
        "apiInvalidAttendancePayload": "Invalid attendance payload",
        "apiVisitorLoadFailed": "Failed to load visitors",
        "apiVisitorDetailLoadFailed": "Failed to load visitor",
        "apiScanFailed": "Scan failed",
        "apiIncidentTypesLoadFailed": "Failed to load incident types",
        "apiIncidentReportFailed": "Incident report failed",
        "apiVisitorTypesLoadFailed": "Failed to load visitor types",
        "loginSignInFailedTitle": "Sign in failed",
        "loginInvalidCredentials": "Invalid username / password",
        "loginEmailOrPhoneLabel": "Email or Phone Number",
        "loginEmailOrPhoneHint": "Email or phone number",
        "loginPasswordLabel": "Password",
        "loginPasswordHint": "Password",
        "loginForgotPassword": "Forgot Password?",
        "loginSignIn": "Sign In",
        "loginSwitchDeviceTitle": "Sign in",
        "loginSwitchDeviceProceed": "Proceed",
        "loginRegionPlaceholder": "Select your region",
        "loginRegionSheetTitle": "Select your region",
        "loginRegionSheetSubtitle": "Choose where your account is registered",
        "loginRegionMalaysia": "Malaysia",
        "loginRegionIndonesia": "Indonesia",
        "loginRegionVietnam": "Vietnam",
        "appTitleStaging": "KipleGuard (Staging)",
    }
)

out = Path("lib/l10n/app_en.arb")
out.write_text(json.dumps(dict(sorted(entries.items())), indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"Wrote {len(entries)} keys to {out}")
