import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/api_error_message.dart';
import '../../core/dashboard_prefs.dart';
import '../../theme/app_color.dart';
import '../../theme/app_spacing.dart';
import '../../widget/app_progress_indicator.dart';
import '../../widget/api_failed_dialog.dart';
import '../../widget/modal_progress_hud.dart';
import '../../widget/standard_primary_header.dart';
import '../auth/guard_repository.dart';
import 'guard_residence_choices.dart';
import 'residence_choice.dart';
import 'select_site_strings.dart';
import 'widget/select_site_residence_tile.dart';
import 'widget/select_site_search_bar.dart';
import 'widget/select_site_status_message.dart';

/// Site picker — `GET api/v1/guard/residences?current_residence_uuid=...`.
class SelectSitePage extends ConsumerStatefulWidget {
  const SelectSitePage({super.key});

  @override
  ConsumerState<SelectSitePage> createState() => _SelectSitePageState();
}

class _SelectSitePageState extends ConsumerState<SelectSitePage> {
  final _searchController = TextEditingController();
  List<ResidenceChoice> _choices = [];
  String _selectedId = '';
  String _query = '';
  bool _loading = true;
  bool _picking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ResidenceChoice> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _choices;
    return _choices.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      List<ResidenceChoice> list;
      final snap = await DashboardPrefs.loadSnapshot();
      try {
        final result = await ref.read(guardRepositoryProvider).fetchResidences(
              currentResidenceUuid: snap.residenceId,
            );
        list = guardResidencesToChoices(result.residences);
        _selectedId = result.currentResidence?.uuid.isNotEmpty == true
            ? result.currentResidence!.uuid
            : snap.residenceId;
      } catch (_) {
        list = await loadGuardResidenceChoices();
        _selectedId = snap.residenceId;
      }
      if (list.isEmpty) {
        throw StateError('No residences available');
      }
      _sortChoices(list, _selectedId);
      if (mounted) {
        setState(() {
          _choices = list;
          _loading = false;
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = userFacingErrorMessage(e);
        });
        await showApiFailedDialog(context, error: e);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Something went wrong';
        });
        await showApiFailedDialog(context, error: e);
      }
    }
  }

  void _sortChoices(List<ResidenceChoice> list, String selectedId) {
    if (selectedId.isEmpty) {
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return;
    }
    final sel = list.where((e) => e.uuid == selectedId).toList();
    final rest = list.where((e) => e.uuid != selectedId).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    list
      ..clear()
      ..addAll([...sel, ...rest]);
  }

  Future<void> _pick(ResidenceChoice c) async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      await c.persist();
      if (mounted) context.pop(c);
    } catch (_) {
      if (mounted) {
        setState(() => _picking = false);
        await showApiFailedDialog(
          context,
          message: 'Could not save site selection',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final visible = _visible;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: standardPrimaryOverlayStyle(),
      child: ModalProgressHud(
        inAsyncCall: _picking,
        child: Scaffold(
          backgroundColor: AppColor.lightGreyBar,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StandardPrimaryHeader(
                title: SelectSiteStrings.pageTitle,
                onBack: _picking ? () {} : () => context.pop(),
              ),
              if (!_loading && _error == null && _choices.isNotEmpty)
                SelectSiteSearchBar(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                ),
              Expanded(child: _body(visible, bottom)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(List<ResidenceChoice> visible, double bottom) {
    if (_loading) {
      return const Center(child: AppProgressIndicator());
    }
    if (_error != null) {
      return SelectSiteStatusMessage(
        icon: Icons.cloud_off_outlined,
        title: _error!,
        actionLabel: SelectSiteStrings.retry,
        onAction: _load,
      );
    }
    if (_choices.isEmpty) {
      return SelectSiteStatusMessage(
        icon: Icons.domain_disabled_outlined,
        title: SelectSiteStrings.emptyTitle,
        subtitle: SelectSiteStrings.emptySubtitle,
      );
    }
    if (visible.isEmpty) {
      return const SelectSiteStatusMessage(
        icon: Icons.search_off_outlined,
        title: 'No matching sites',
        subtitle: 'Try a different search term.',
      );
    }
    return RefreshIndicator(
      color: AppColor.primary,
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 4.h, bottom: bottom + AppSpacing.md),
        itemCount: visible.length,
        itemBuilder: (context, index) {
          final c = visible[index];
          return SelectSiteResidenceTile(
            choice: c,
            isCurrent: c.uuid == _selectedId,
            onTap: _picking ? () {} : () => _pick(c),
          );
        },
      ),
    );
  }
}
