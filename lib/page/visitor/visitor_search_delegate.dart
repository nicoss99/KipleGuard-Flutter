import 'package:flutter/material.dart';

import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';
import 'visitor_strings.dart';

class VisitorSearchDelegate extends SearchDelegate<String?> {
  VisitorSearchDelegate({String? initialQuery}) {
    query = initialQuery ?? '';
  }

  @override
  String get searchFieldLabel => VisitorStrings.searchHint;

  @override
  TextStyle? get searchFieldStyle => AppTextStyle.body;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.white,
        elevation: 0,
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, '');
          } else {
            query = '';
            showSuggestions(context);
          }
        },
      ),
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () => close(context, query),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      close(context, query);
    });
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Text(
        'Type visitor name, plate, pass or unit and tap search.',
        style: AppTextStyle.bodyMuted,
        textAlign: TextAlign.center,
      ),
    );
  }
}
