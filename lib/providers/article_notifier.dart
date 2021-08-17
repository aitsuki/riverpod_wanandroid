import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_wandroid/models/models.dart';
import 'package:riverpod_wandroid/repository/repository.dart';

part 'article_notifier.freezed.dart';

final articleNotifierProvider = StateNotifierProvider.family
    .autoDispose<ArticleStateNotifier, ArticleState, int>((ref, chapterId) {
  ref.maintainState = true;
  return ArticleStateNotifier(ref.watch(repositoryProvider), chapterId);
});

@freezed
class ArticleState with _$ArticleState {
  const factory ArticleState({
    @Default(null) List<Article>? items,
    @Default(null) dynamic error,
    @Default(0) int? nextPage,
  }) = _ArticleState;
}

class ArticleStateNotifier extends StateNotifier<ArticleState> {
  ArticleStateNotifier(this.repository, this.chapterId)
      : super(const ArticleState());

  final Repository repository;
  final int chapterId;

  Future refresh() {
    return fetch(0, true);
  }

  Future fetch(int page, [bool clearCache = false]) async {
    try {
      final articles = await repository.fetchArticles(page, chapterId);
      state = state.copyWith(
          items: clearCache ? articles : [...state.items ?? [], ...articles],
          nextPage: articles.isEmpty ? null : page + 1,
          error: null);
    } catch (e) {
      log('fetch article failure', error: e);
      state = state.copyWith(error: e);
    }
  }
}
