import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/cache/guard_list_cache.dart';
import '../../l10n/app_l10n.dart';
import '../../theme/app_color.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_style.dart';
import '../../widget/api_failed_dialog.dart';
import '../../widget/app_progress_indicator.dart';
import '../../widget/app_success_dialog.dart';
import '../../widget/standard_primary_header.dart';
import '../reporting/reporting_sync_service.dart';
import 'offline_data_provider.dart';
import 'profile_strings.dart';

class ProfileOfflinePage extends ConsumerStatefulWidget {
  const ProfileOfflinePage({super.key});

  @override
  ConsumerState<ProfileOfflinePage> createState() => _ProfileOfflinePageState();
}

class _ProfileOfflinePageState extends ConsumerState<ProfileOfflinePage> {
  var _syncing = false;

  Future<void> _syncNow() async {
    setState(() => _syncing = true);
    try {
      await ref.read(reportingSyncServiceProvider).processQueue();
      ref.invalidate(offlineDataSummaryProvider);
      if (!mounted) return;
      await showAppSuccessDialog(
        context,
        message: appL10n.offlineSyncDone,
      );
    } catch (e) {
      if (mounted) await showApiFailedDialog(context, error: e);
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(offlineDataSummaryProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: standardPrimaryOverlayStyle(),
      child: Scaffold(
        backgroundColor: AppColor.white,
        body: Column(
          children: [
            StandardPrimaryHeader(
              title: ProfileStrings.offlineData,
              onBack: () => context.pop(),
            ),
            if (_syncing)
              const LinearProgressIndicator(minHeight: 2, color: AppColor.primary),
            Expanded(
              child: summary.when(
                loading: () => const Center(child: AppProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(e.toString(), style: AppTextStyle.body),
                ),
                data: (s) => RefreshIndicator(
                  color: AppColor.primary,
                  onRefresh: () async {
                    ref.invalidate(offlineDataSummaryProvider);
                    await ref.read(offlineDataSummaryProvider.future);
                  },
                  child: ListView(
                    padding: EdgeInsets.all(AppSpacing.md),
                    children: [
                      if (s.residenceName.isNotEmpty)
                        Text(
                          s.residenceName,
                          style: AppTextStyle.subtitle,
                        ),
                      SizedBox(height: 16.h),
                      Text(
                        appL10n.offlinePendingSection,
                        style: AppTextStyle.subtitle,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        s.pendingIncidents == 0
                            ? appL10n.offlineNoPending
                            : appL10n.offlinePendingIncidents(s.pendingIncidents),
                        style: AppTextStyle.bodyMuted,
                      ),
                      SizedBox(height: 12.h),
                      FilledButton(
                        onPressed: _syncing ? null : _syncNow,
                        child: Text(appL10n.offlineSyncNow),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        appL10n.offlineCachedSection,
                        style: AppTextStyle.subtitle,
                      ),
                      SizedBox(height: 8.h),
                      if (!s.hasCache)
                        Text(
                          ProfileStrings.emptyOfflineData,
                          style: AppTextStyle.bodyMuted,
                        )
                      else
                        ...s.cacheEntries.map(
                          (e) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(e.label, style: AppTextStyle.body),
                            subtitle: Text(
                              '${e.detail}\n${appL10n.offlineSavedAt(GuardListCache.formatSavedAt(e.savedAt))}',
                              style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
