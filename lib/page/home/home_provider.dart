import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'home_state.dart';

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState();
}
