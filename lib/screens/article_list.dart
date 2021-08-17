import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:riverpod_wandroid/models/models.dart';
import 'package:riverpod_wandroid/providers/article_notifier.dart';

class ArticleList extends ConsumerStatefulWidget {
  const ArticleList(this.chapterId, {Key? key}) : super(key: key);

  final int chapterId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ArticleListState();
  }
}

class _ArticleListState extends ConsumerState<ArticleList> {
  final _pagingController = PagingController<int, Article>(firstPageKey: 0);

  @override
  void initState() {
    _updatePagingValue();
    _pagingController.addPageRequestListener((pageKey) {
      ref
          .read(articleNotifierProvider(widget.chapterId).notifier)
          .fetch(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  void _updatePagingValue() {
    final state = ref.read(articleNotifierProvider(widget.chapterId));
    _pagingController.value = PagingState(
      itemList: state.items,
      nextPageKey: state.nextPage,
      error: state.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(articleNotifierProvider(widget.chapterId), (itemCount) {
      _updatePagingValue();
    });

    final handle = NestedScrollView.sliverOverlapAbsorberHandleFor(context);
    final offset = handle.layoutExtent ?? 0;
    return RefreshIndicator(
      edgeOffset: offset,
      onRefresh:
          ref.read(articleNotifierProvider(widget.chapterId).notifier).refresh,
      child: CustomScrollView(
        slivers: [
          SliverOverlapInjector(handle: handle),
          PagedSliverList(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Article>(
              itemBuilder: (context, article, index) {
                return ArticleItem(article);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleItem extends StatelessWidget {
  const ArticleItem(this.article, {Key? key}) : super(key: key);

  final Article article;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(article.title),
      subtitle: Text(article.niceDate),
    );
  }
}
