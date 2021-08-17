import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_wandroid/models/models.dart';

final loadHomeTabsProvider = FutureProvider<void>((ref) async {
  await ref.read(homeTabNotifierProvider.notifier).loadTabs();
});

final homeTabNotifierProvider =
    StateNotifierProvider<HomeTabNotifier, List<HomeTab>>((ref) {
  return HomeTabNotifier();
});

class HomeTabNotifier extends StateNotifier<List<HomeTab>> {
  HomeTabNotifier() : super([]);

  Future<void> loadTabs() async {
    final homeTabs =
        await Future.delayed(const Duration(seconds: 3)).then((value) => [
              const HomeTab(0, '推荐', false),
              const HomeTab(440, '每日一问', false),
            ]);
    state = homeTabs;
  }

  void add(HomeTab tab) {
    state = [...state, tab];
  }

  void remove(HomeTab tab) {
    state = [...state..remove(tab)];
  }

  void reorder(int oldIndex, int newIndex) {
    final newState = [...state];
    newState.insert(newIndex, newState.removeAt(oldIndex));
    state = newState;
  }
}
