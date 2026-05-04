import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Runtime environment selected by [main_dev] / [main_prod] entrypoints.
enum AppFlavor { dev, prod }

/// Overridden at app startup via [ProviderScope].
final appFlavorProvider = Provider<AppFlavor>((ref) => AppFlavor.prod);
