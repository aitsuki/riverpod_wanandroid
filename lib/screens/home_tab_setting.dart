import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderables/reorderables.dart';
import 'package:riverpod_wandroid/models/models.dart';
import 'package:riverpod_wandroid/providers/home_tab_notifier.dart';
import 'package:riverpod_wandroid/repository/repository.dart';
import 'package:riverpod_wandroid/widgets/page_error.dart';
import 'package:riverpod_wandroid/widgets/page_loading.dart';

final _chaptersProvider = FutureProvider<List<Chapter>>((ref) {
  final repository = ref.watch(repositoryProvider);
  // 先确定HomeTab已经加载(虽然没有加载是进不来这个页面的)
  return ref
      .watch(loadHomeTabsProvider.future)
      .then((value) => repository.fetchChapters());
});

final _selectedParentProvider =
    StateProvider<Chapter?>((ref) => throw UnimplementedError());

class HomeTabSetting extends StatelessWidget {
  const HomeTabSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('栏目订阅'),
      ),
      body: Consumer(builder: (context, ref, _) {
        return ref.watch(_chaptersProvider).when(
              data: (chapters) {
                return ProviderScope(
                  overrides: [
                    _selectedParentProvider.overrideWithProvider(StateProvider(
                        (ref) => chapters.isEmpty ? null : chapters[0])),
                  ],
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 0, 8),
                          child: Text('我的订阅'),
                        ),
                        const _SubscribedChapters(),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 0, 8),
                          child: Text('一级分类'),
                        ),
                        _ParentChapters(chapters),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 0, 8),
                          child: Text('二级分类'),
                        ),
                        const _ChildChapters(),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const PageLoading(),
              error: (_, __) =>
                  PageError(onReload: () => ref.refresh(loadHomeTabsProvider)),
            );
      }),
    );
  }
}

class _SubscribedChapters extends ConsumerWidget {
  const _SubscribedChapters({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(homeTabNotifierProvider);
    final unorderableTabs = tabs.where((tab) => !tab.editable);
    final orderableTabs = tabs.where((tab) => tab.editable);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ReorderableWrap(
        needsLongPressDraggable: false,
        runSpacing: 16,
        buildDraggableFeedback: (context, constraints, child) {
          return Material(
            child: child,
            color: Colors.transparent,
            elevation: 12,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          );
        },
        spacing: 8,
        onReorder: (int oldIndex, int newIndex) {
          final offset = unorderableTabs.length;
          ref
              .read(homeTabNotifierProvider.notifier)
              .reorder(oldIndex + offset, newIndex + offset);
        },
        header: unorderableTabs
            .map((tab) => Chip(
                  label: Text(tab.name),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ))
            .toList(),
        children: orderableTabs.map((tab) {
          return Chip(
            label: Text(tab.name),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onDeleted: tab.editable
                ? () => ref.read(homeTabNotifierProvider.notifier).remove(tab)
                : null,
          );
        }).toList(),
      ),
    );
  }
}

class _ParentChapters extends StatelessWidget {
  const _ParentChapters(this.chapters, {Key? key}) : super(key: key);

  final List<Chapter> chapters;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      clipBehavior: Clip.none,
      scrollDirection: Axis.horizontal,
      child: Container(
        width: chapters.length * 92 / 3, // 分三行显示，假设每个控件宽100
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          spacing: 8,
          children:
              chapters.map((chapter) => _ParentChapterItem(chapter)).toList(),
        ),
      ),
    );
  }
}

class _ParentChapterItem extends ConsumerWidget {
  const _ParentChapterItem(this.chapter, {Key? key}) : super(key: key);

  final Chapter chapter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedChapter = ref.watch(_selectedParentProvider).state;
    return ChoiceChip(
      label: Text(chapter.name),
      selected: chapter.id == selectedChapter?.id,
      onSelected: (selected) =>
          ref.read(_selectedParentProvider).state = chapter,
    );
  }
}

class _ChildChapters extends ConsumerWidget {
  const _ChildChapters({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentChapter = ref.watch(_selectedParentProvider).state;
    final chapters = parentChapter?.children ?? [];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
          spacing: 8,
          children: [parentChapter, ...chapters]
              .skipWhile((value) => value == null)
              .map((chapter) => _ChildChapterItem(chapter!))
              .toList()),
    );
  }
}

class _ChildChapterItem extends ConsumerWidget {
  const _ChildChapterItem(this.chapter, {Key? key}) : super(key: key);

  final Chapter chapter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(homeTabNotifierProvider.select((state) {
      final result = state.where((tab) => tab.chapterId == chapter.id).toList();
      if (result.isEmpty) {
        return null;
      }
      return result[0];
    }));

    // 没有选中，或者已选中但可以编辑时才可以操作。
    var onSelected = selected == null || selected.editable
        ? (bool value) {
            final notifier = ref.read(homeTabNotifierProvider.notifier);
            if (value) {
              notifier.add(HomeTab(chapter.id, chapter.name, true));
            } else {
              notifier.remove(HomeTab(chapter.id, chapter.name, true));
            }
          }
        : null;

    return FilterChip(
      label: Text(chapter.name),
      selected: selected != null,
      onSelected: onSelected,
    );
  }
}
