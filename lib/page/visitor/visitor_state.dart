import 'package:flutter/foundation.dart';

import 'visitor_model.dart';

@immutable
class VisitorState {
  const VisitorState({
    required this.selectedDay,
    required this.tabIndex,
    required this.items,
    this.totalCheckIn,
    this.totalIncoming,
    this.totalOvertime,
    this.totalVisitors,
    this.searchActive = false,
    this.searchQuery = '',
    this.allOvertimeSection = false,
    this.page = 1,
    this.hasMore = true,
    this.loadingMore = false,
    this.loading = false,
    this.error,
  });

  final DateTime selectedDay;
  final int tabIndex;
  final List<VisitorListItem> items;
  final int? totalCheckIn;
  final int? totalIncoming;
  final int? totalOvertime;
  final int? totalVisitors;
  final bool searchActive;
  final String searchQuery;
  final bool allOvertimeSection;
  final int page;
  final bool hasMore;
  final bool loadingMore;
  final bool loading;
  final String? error;

  VisitorState copyWith({
    DateTime? selectedDay,
    int? tabIndex,
    List<VisitorListItem>? items,
    int? totalCheckIn,
    int? totalIncoming,
    int? totalOvertime,
    int? totalVisitors,
    bool? searchActive,
    String? searchQuery,
    bool? allOvertimeSection,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return VisitorState(
      selectedDay: selectedDay ?? this.selectedDay,
      tabIndex: tabIndex ?? this.tabIndex,
      items: items ?? this.items,
      totalCheckIn: totalCheckIn ?? this.totalCheckIn,
      totalIncoming: totalIncoming ?? this.totalIncoming,
      totalOvertime: totalOvertime ?? this.totalOvertime,
      totalVisitors: totalVisitors ?? this.totalVisitors,
      searchActive: searchActive ?? this.searchActive,
      searchQuery: searchQuery ?? this.searchQuery,
      allOvertimeSection: allOvertimeSection ?? this.allOvertimeSection,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
