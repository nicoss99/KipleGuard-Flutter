import json
from pathlib import Path

p = Path("lib/l10n/app_en.arb")
d = json.loads(p.read_text(encoding="utf-8"))
missing = {
    "attendanceNoResidenceSelected": "No residence selected. Select a site from the dashboard first.",
    "attendanceMissingSecurityProfile": "Site security data is missing. Select a site again or contact support.",
    "bookingFilterPickOne": "Choose a submitted date, category, or booking type to apply filters.",
    "dashboardFeatureAttendance": "This feature enable members to log attendance",
    "dashboardFeatureVisitor": "This feature enable members to register visitors",
    "dashboardFeatureReport": "This feature enable members to report incidents",
    "dashboardFeatureBooking": "This feature enable members to check booking",
    "dashboardFeatureCall": "This feature enable members to call the other members",
    "reportingPinNotFound": "This PIN doesn't exist in our system\nPlease check with your site supervisor",
    "reportingReportSuccessQueued": "Saved on this device and will sync when you are back online.",
    "reportingErrorReportDate": "You cannot choose future date to report an incident which never happened yet",
}
d.update(missing)
p.write_text(json.dumps(dict(sorted(d.items())), indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print("patched", len(missing), "keys")
