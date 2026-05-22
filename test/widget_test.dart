import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kiple_guard_flutter/bootstrap/bootstrap_app.dart';
import 'package:kiple_guard_flutter/core/app_flavor.dart';
import 'package:kiple_guard_flutter/core/auth_prefs.dart';
import 'package:kiple_guard_flutter/core/onboarding_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Home shows dashboard labels from Android strings', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({
      OnboardingPrefs.key: true,
      AuthPrefs.sessionTokenKey: 'test_session',
    });
    await Future.wait([OnboardingPrefs.load(), AuthPrefs.load()]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appFlavorProvider.overrideWithValue(AppFlavor.prod)],
        child: const KipleGuardApp(flavor: AppFlavor.prod),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('KipleGuard'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('Scan QR'), findsOneWidget);
  });
}
