import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../router/app_route.dart';
import '../../theme/app_color.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_style.dart';
import 'unit_call_phone.dart';
import 'unit_call_provider.dart';
import 'unit_call_state.dart';
import 'unit_call_strings.dart';
import 'widget/unit_call_selection_tile.dart';
import 'widget/unit_call_unit_tile.dart';

/// Android `UnitActivity` (call / intercom flow — `selectType` ≠ selectUnit).
class UnitCallPage extends ConsumerStatefulWidget {
  const UnitCallPage({super.key});

  @override
  ConsumerState<UnitCallPage> createState() => _UnitCallPageState();
}

class _UnitCallPageState extends ConsumerState<UnitCallPage> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(unitCallProvider.notifier).bootstrap();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _onBack() {
    final s = ref.read(unitCallProvider);
    final n = ref.read(unitCallProvider.notifier);
    if (s.officeMode || s.step == UnitCallStep.blocks) {
      if (mounted) context.pop();
      return;
    }
    n.handleBack();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unitCallProvider);
    final showSearch = state.officeMode || state.step == UnitCallStep.units;
    final top = MediaQuery.paddingOf(context).top;

    ref.listen(unitCallProvider.select((s) => s.searchQuery), (prev, next) {
      if (_search.text != next) {
        _search.text = next;
      }
    });

    final voip = state.callOption.toLowerCase() == 'number_masking_voip';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColor.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          _onBack();
        },
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
                        onPressed: _onBack,
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColor.primary, size: 20.sp),
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, anim) {
                            return FadeTransition(
                              opacity: anim,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.06, 0),
                                  end: Offset.zero,
                                ).animate(anim),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            state.appBarTitle,
                            key: ValueKey<String>(state.appBarTitle),
                            textAlign: TextAlign.center,
                            style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(AppRoute.callRecent.path),
                        child: Text(
                          UnitCallStrings.recent,
                          style: AppTextStyle.body.copyWith(
                            color: AppColor.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.refreshing && state.units.isNotEmpty)
                LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColor.primary,
                  backgroundColor: AppColor.primary.withValues(alpha: 0.12),
                ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, anim) => SizeTransition(sizeFactor: anim, axisAlignment: -1, child: child),
                child: showSearch
                    ? Padding(
                        key: const ValueKey<String>('search'),
                        padding: EdgeInsets.fromLTRB(AppSpacing.md, 10.h, AppSpacing.md, 6.h),
                        child: TextField(
                          controller: _search,
                          onChanged: ref.read(unitCallProvider.notifier).setSearch,
                          decoration: InputDecoration(
                            hintText: UnitCallStrings.searchHint,
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
                      )
                    : SizedBox(height: 6.h, key: const ValueKey<String>('nosearch')),
              ),
              Expanded(
                child: ColoredBox(
                  color: AppColor.siteListRowGrey.withValues(alpha: 0.25),
                  child: _body(state, voip),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(UnitCallState state, bool voip) {
    if (state.loading && state.units.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColor.primary),
            SizedBox(height: 16.h),
            Text(UnitCallStrings.loadingUnits, style: AppTextStyle.bodyMuted),
          ],
        ),
      );
    }
    if (state.error != null && state.units.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 48.sp, color: AppColor.textSecondary),
              SizedBox(height: 12.h),
              Text(state.error!, textAlign: TextAlign.center, style: AppTextStyle.body),
              SizedBox(height: 12.h),
              FilledButton(
                onPressed: () => ref.read(unitCallProvider.notifier).refreshFromNetwork(),
                style: FilledButton.styleFrom(backgroundColor: AppColor.primary),
                child: const Text(UnitCallStrings.retry),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColor.primary,
      onRefresh: () => ref.read(unitCallProvider.notifier).refreshFromNetwork(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) {
          final slide = Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero).animate(anim);
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<UnitCallStep>(state.step),
          child: switch (state.step) {
            UnitCallStep.blocks => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 12.h, bottom: 24.h),
              children: [
                for (var i = 0; i < state.blocks.length; i++)
                  UnitCallSelectionTile(
                    key: ValueKey<String>('block-${state.blocks[i]}'),
                    index: i,
                    title: state.blocks[i],
                    icon: Icons.domain_rounded,
                    onTap: () => ref.read(unitCallProvider.notifier).selectBlock(state.blocks[i]),
                  ),
              ],
            ),
            UnitCallStep.floors => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 12.h, bottom: 24.h),
              children: [
                for (var i = 0; i < state.floors.length; i++)
                  UnitCallSelectionTile(
                    key: ValueKey<String>('floor-${state.floors[i].name}'),
                    index: i,
                    title: state.floors[i].name,
                    icon: Icons.stairs_rounded,
                    onTap: () => ref.read(unitCallProvider.notifier).selectFloor(state.floors[i].name),
                  ),
              ],
            ),
            UnitCallStep.units => ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 12.h, bottom: 24.h),
              itemCount: state.visibleUnits.length,
              separatorBuilder: (_, _) => SizedBox(height: 0.h),
              itemBuilder: (context, i) {
                final row = state.visibleUnits[i];
                final exp = state.expandedUnitIds.contains(row.id);
                return UnitCallUnitTile(
                  key: ValueKey<String>('unit-${row.id}'),
                  index: i,
                  row: row,
                  expanded: exp,
                  voipMasking: voip,
                  onToggleExpand: () => ref.read(unitCallProvider.notifier).toggleUnitExpanded(row.id),
                  onMemberTap: (m) {
                    if (voip) {
                      showVoipPlaceholder(context);
                    } else {
                      dialMembershipPhone(context, m.phone);
                    }
                  },
                );
              },
            ),
          },
        ),
      ),
    );
  }
}
