import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_wandroid/providers/home_tab_notifier.dart';
import 'package:riverpod_wandroid/screens/article_list.dart';
import 'package:riverpod_wandroid/widgets/page_error.dart';
import 'package:riverpod_wandroid/widgets/page_loading.dart';
import 'package:riverpod_wandroid/widgets/tab_bar_container.dart';

class Home extends ConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadResult = ref.watch(loadHomeTabsProvider);
    return Scaffold(
      body: loadResult.when(
        data: (_) => _HomeContent(),
        loading: () => const PageLoading(),
        error: (_, __) =>
            PageError(onReload: () => ref.refresh(loadHomeTabsProvider)),
      ),
    );
  }
}

class _HomeContent extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _HomeContentState();
  }
}

class _HomeContentState extends ConsumerState<ConsumerStatefulWidget>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeTabs = ref.watch(homeTabNotifierProvider);
    _tabController?.index = 0;
    _tabController = TabController(length: homeTabs.length, vsync: this);
    return DefaultTabController(
      length: homeTabs.length,
      child: NestedScrollView(
        // TODO(aitsuki): 这个功能导致页面滚动初始化（下拉出现appbar时）
        // 如果不使用PageStorageKey而是AutomaticKeepAliveMixin，那么又会出现列表同步
        // 滚动的bug。试过extended_nested_scroll_view，并未解决列表初始化问题。
        // https://github.com/flutter/flutter/issues/40740
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                pinned: true,
                floating: true,
                snap: true,
                forceElevated: innerBoxIsScrolled,
                bottom: TabBarContainer(
                  child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/tab_setting'),
                      child: const Icon(Icons.add, color: Colors.white)),
                  tabBar: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: homeTabs.map((tab) => Tab(text: tab.name)).toList(),
                  ),
                ),
              ),
            )
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: homeTabs.map((tab) {
            return SafeArea(
              top: false,
              bottom: false,
              child: ArticleList(
                tab.chapterId,
                key: PageStorageKey<String>(tab.name),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
