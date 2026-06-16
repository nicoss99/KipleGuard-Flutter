import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/app_bar_title_format.dart';
import '../../widget/api_failed_dialog.dart';
import '../../widget/app_progress_indicator.dart';
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';
import 'unit_call_phone.dart';
import 'unit_call_provider.dart';
import 'unit_call_state.dart';
import 'unit_call_strings.dart';
import 'widget/unit_call_selection_tile.dart';
import 'widget/unit_call_step_search_field.dart';
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
    final showSearch =
        state.officeMode ? state.step == UnitCallStep.units : true;
    final top = MediaQuery.paddingOf(context).top;

    ref.listen(unitCallProvider.select((s) => s.searchQuery), (prev, next) {
      if (_search.text != next) {
        _search.text = next;
      }
    });

    ref.listen(unitCallProvider.select((s) => s.error), (prev, next) {
      if (next == null || next == prev || !mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await showApiFailedDialog(context, message: next);
        ref.read(unitCallProvider.notifier).clearError();
      });
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
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColor.primary,
                          size: 20.sp,
                        ),
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
                            AppBarTitleFormat.format(state.appBarTitle),
                            key: ValueKey<String>(state.appBarTitle),
                            textAlign: TextAlign.center,
                            style: AppTextStyle.subtitle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 48.w),
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
                transitionBuilder: (child, anim) => SizeTransition(
                  sizeFactor: anim,
                  axisAlignment: -1,
                  child: child,
                ),
                child: showSearch
                    ? UnitCallStepSearchField(
                        key: ValueKey<String>('search-${state.step}'),
                        controller: _search,
                        hintText: _searchHint(state),
                        onChanged:
                            ref.read(unitCallProvider.notifier).setSearch,
                      )
                    : SizedBox(
                        height: 6.h,
                        key: const ValueKey<String>('nosearch'),
                      ),
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
    if (state.loading || (state.stepLoading && _stepListEmpty(state))) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppProgressIndicator(),
            SizedBox(height: 16.h),
            Text(_loadingMessage(state), style: AppTextStyle.bodyMuted),
          ],
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
          final slide = Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(anim);
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<UnitCallStep>(state.step),
          child: switch (state.step) {
            UnitCallStep.blocks => _stepList(
              state: state,
              emptyMessage: _filteredEmptyMessage(
                hasSourceRows: state.blocks.isNotEmpty,
                visibleCount: state.visibleBlocks.length,
                defaultEmpty: UnitCallStrings.emptyBlocks,
              ),
              children: [
                for (var i = 0; i < state.visibleBlocks.length; i++)
                  UnitCallSelectionTile(
                    key: ValueKey<String>('block-${state.visibleBlocks[i]}'),
                    index: i,
                    title: state.visibleBlocks[i],
                    icon: Icons.domain_rounded,
                    onTap: () => ref
                        .read(unitCallProvider.notifier)
                        .selectBlock(state.visibleBlocks[i]),
                  ),
              ],
            ),
            UnitCallStep.floors => _stepList(
              state: state,
              emptyMessage: _filteredEmptyMessage(
                hasSourceRows: state.floors.isNotEmpty,
                visibleCount: state.visibleFloors.length,
                defaultEmpty: UnitCallStrings.emptyFloors,
              ),
              children: [
                for (var i = 0; i < state.visibleFloors.length; i++)
                  UnitCallSelectionTile(
                    key: ValueKey<String>(
                      'floor-${state.visibleFloors[i].name}',
                    ),
                    index: i,
                    title: state.visibleFloors[i].name,
                    icon: Icons.stairs_rounded,
                    onTap: () => ref
                        .read(unitCallProvider.notifier)
                        .selectFloor(state.visibleFloors[i].name),
                  ),
              ],
            ),
            UnitCallStep.units =>
              state.visibleUnits.isEmpty
                  ? _stepList(
                      state: state,
                      emptyMessage: _filteredEmptyMessage(
                        hasSourceRows: state.units.isNotEmpty,
                        visibleCount: state.visibleUnits.length,
                        defaultEmpty: UnitCallStrings.emptyUnits,
                      ),
                      children: const [],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(top: 12.h, bottom: 24.h),
                      itemCount: state.visibleUnits.length,
                      separatorBuilder: (_, _) => const SizedBox.shrink(),
                      itemBuilder: (context, i) {
                        final row = state.visibleUnits[i];
                        final exp = state.expandedUnitIds.contains(row.id);
                        final hostsLoading = state.hostsLoadingUnitIds.contains(
                          row.id,
                        );
                        return UnitCallUnitTile(
                          key: ValueKey<String>('unit-${row.id}'),
                          index: i,
                          row: row,
                          expanded: exp,
                          hostsLoading: hostsLoading,
                          voipMasking: voip,
                          onToggleExpand: () => ref
                              .read(unitCallProvider.notifier)
                              .toggleUnitExpanded(row.id),
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

  String _searchHint(UnitCallState state) {
    if (state.officeMode) return UnitCallStrings.searchHint;
    return switch (state.step) {
      UnitCallStep.blocks => UnitCallStrings.searchBlockHint,
      UnitCallStep.floors => UnitCallStrings.searchFloorHint,
      UnitCallStep.units => UnitCallStrings.searchHint,
    };
  }

  String _filteredEmptyMessage({
    required bool hasSourceRows,
    required int visibleCount,
    required String defaultEmpty,
  }) {
    if (!hasSourceRows) return defaultEmpty;
    if (visibleCount == 0) return UnitCallStrings.searchNoMatch;
    return defaultEmpty;
  }

  bool _stepListEmpty(UnitCallState state) {
    if (state.officeMode) return state.units.isEmpty;
    return switch (state.step) {
      UnitCallStep.blocks => state.blocks.isEmpty,
      UnitCallStep.floors => state.floors.isEmpty,
      UnitCallStep.units => state.units.isEmpty,
    };
  }

  String _loadingMessage(UnitCallState state) {
    if (state.officeMode) return UnitCallStrings.loadingUnits;
    return switch (state.step) {
      UnitCallStep.blocks => UnitCallStrings.loadingBlocks,
      UnitCallStep.floors => UnitCallStrings.loadingFloors,
      UnitCallStep.units => UnitCallStrings.loadingUnits,
    };
  }

  Widget _stepList({
    required UnitCallState state,
    required String emptyMessage,
    required List<Widget> children,
  }) {
    if (children.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 48.h),
          Center(child: Text(emptyMessage, style: AppTextStyle.bodyMuted)),
        ],
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 12.h, bottom: 24.h),
      children: children,
    );
  }
}
