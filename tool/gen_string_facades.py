import re
from pathlib import Path

CONFIG = {
    "attendance_strings.dart": ("AttendanceStrings", "attendance"),
    "booking_strings.dart": ("BookingStrings", "booking"),
    "dashboard_strings.dart": ("DashboardStrings", "dashboard"),
    "profile_strings.dart": ("ProfileStrings", "profile"),
    "register_strings.dart": ("RegisterStrings", "register"),
    "reporting_strings.dart": ("ReportingStrings", "reporting"),
    "scan_strings.dart": ("ScanStrings", "scan"),
    "select_site_strings.dart": ("SelectSiteStrings", "selectSite"),
    "unit_call_strings.dart": ("UnitCallStrings", "unitCall"),
    "visitor_strings.dart": ("VisitorStrings", "visitor"),
}

for rel, (cls, pref) in CONFIG.items():
    path = next(Path("lib").rglob(rel))
    text = path.read_text(encoding="utf-8")
    keys = re.findall(r"static const (\w+) =", text)
    lines = [
        "import '../../l10n/app_l10n.dart';",
        "",
        f"/// Localized via [appL10n] — keys in `lib/l10n/app_en.arb`.",
        f"abstract final class {cls} {{",
    ]
    for key in keys:
        arb = pref + key[0].upper() + key[1:]
        lines.append(f"  static String get {key} => appL10n.{arb};")
    lines.append("}")
    lines.append("")
    path.write_text("\n".join(lines), encoding="utf-8")
    print(f"Updated {path} ({len(keys)} getters)")
