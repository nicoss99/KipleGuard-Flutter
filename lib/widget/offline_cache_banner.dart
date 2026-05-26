import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/cache/guard_list_cache.dart';
import '../core/connectivity/network_connectivity.dart';
import '../l10n/app_l10n.dart';
import '../theme/app_color.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_style.dart';

/// Banner when the device is offline and/or list data is from on-device cache.
class OfflineCacheBanner extends ConsumerWidget {
  const OfflineCacheBanner({
    super.key,
    this.fromCache = false,
    this.savedAt,
  });

  final bool fromCache;
  final DateTime? savedAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isOnlineProvider).value;
    final isOffline = online == false;
    final hasCachedAt = fromCache && savedAt != null;

    if (!isOffline && !hasCachedAt) return const SizedBox.shrink();

    final message = _message(isOffline: isOffline, hasCachedAt: hasCachedAt);

    return Container(
      width: double.infinity,
      color: AppColor.orange.withValues(alpha: 0.12),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 8.h,
      ),
      child: Text(
        message,
        style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _message({required bool isOffline, required bool hasCachedAt}) {
    if (isOffline && hasCachedAt) {
      return '${appL10n.offlineDataMessage} ${appL10n.offlineShowingCached(GuardListCache.formatSavedAt(savedAt!))}';
    }
    if (isOffline) return appL10n.offlineNoConnection;
    return appL10n.offlineShowingCached(GuardListCache.formatSavedAt(savedAt!));
  }
}
