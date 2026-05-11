import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';
import '../unit_call_phone.dart';
import '../unit_call_strings.dart';
import 'call_recent_provider.dart';
import 'call_recent_state.dart';
import 'widget/call_recent_tile.dart';

/// Android `VoipCallHistoryActivity`.
class CallRecentPage extends ConsumerStatefulWidget {
  const CallRecentPage({super.key});

  @override
  ConsumerState<CallRecentPage> createState() => _CallRecentPageState();
}

class _CallRecentPageState extends ConsumerState<CallRecentPage> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(callRecentProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(callRecentProvider);
    final top = MediaQuery.paddingOf(context).top;

    ref.listen(callRecentProvider.select((s) => s.searchQuery), (prev, next) {
      if (_search.text != next) _search.text = next;
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColor.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColor.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: AppColor.primary,
              child: SizedBox(height: top, width: double.infinity),
            ),
            Material(
              color: AppColor.white,
              elevation: 2,
              shadowColor: AppColor.primary.withValues(alpha: 0.15),
              child: SizedBox(
                height: 52.h,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColor.primary, size: 20.sp),
                    ),
                    Expanded(
                      child: Text(
                        UnitCallStrings.recent,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(width: 48.w),
                  ],
                ),
              ),
            ),
            if (state.refreshing && state.rows.isNotEmpty)
              LinearProgressIndicator(
                minHeight: 2,
                color: AppColor.primary,
                backgroundColor: AppColor.primary.withValues(alpha: 0.12),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.md, 10.h, AppSpacing.md, 6.h),
              child: TextField(
                controller: _search,
                onChanged: ref.read(callRecentProvider.notifier).setSearch,
                decoration: InputDecoration(
                  hintText: UnitCallStrings.callRecentSearch,
                  filled: true,
                  fillColor: AppColor.siteListRowGrey.withValues(alpha: 0.45),
                  prefixIcon: Icon(Icons.search_rounded, color: AppColor.textSecondary, size: 22.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12.h),
                ),
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: AppColor.siteListRowGrey.withValues(alpha: 0.25),
                child: _body(context, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, CallRecentState state) {
    if (state.loading && state.rows.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColor.primary));
    }
    if (state.error != null && state.rows.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.error!, textAlign: TextAlign.center, style: AppTextStyle.body),
              SizedBox(height: 12.h),
              FilledButton(
                onPressed: () => ref.read(callRecentProvider.notifier).refreshFromNetwork(),
                style: FilledButton.styleFrom(backgroundColor: AppColor.primary),
                child: const Text(UnitCallStrings.retry),
              ),
            ],
          ),
        ),
      );
    }

    final visible = state.visibleRows;
    if (visible.isEmpty) {
      return RefreshIndicator(
        color: AppColor.primary,
        onRefresh: () => ref.read(callRecentProvider.notifier).refreshFromNetwork(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 80.h),
            Center(child: Text(UnitCallStrings.callRecentEmpty, style: AppTextStyle.bodyMuted)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColor.primary,
      onRefresh: () => ref.read(callRecentProvider.notifier).refreshFromNetwork(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
        itemCount: visible.length,
        itemBuilder: (context, i) {
          final row = visible[i];
          return CallRecentTile(
            key: ValueKey<String>(row.uuid),
            row: row,
            residenceDisplayName: state.residenceName.isEmpty ? '—' : state.residenceName,
            onTap: () => showVoipPlaceholder(context),
          );
        },
      ),
    );
  }
}
