import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Runtime environment from entrypoints and optional `--dart-define=API_ENV=...`.
///
/// Builds use **staging** ([AppFlavor.staging]) and **production** ([AppFlavor.prod]).
/// [AppFlavor.dev] keeps legacy dev-host URLs for overrides only.
enum AppFlavor { dev, staging, prod }

/// Overridden at app startup via [ProviderScope].
final appFlavorProvider = Provider<AppFlavor>((ref) => AppFlavor.prod);
