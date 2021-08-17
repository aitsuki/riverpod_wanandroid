part of 'models.dart';

@freezed
class Article with _$Article {
  const factory Article({
    required int id,
    required String title,
    required String author,
    required String shareUser,
    required String niceDate,
    required int chapterId,
    required String chapterName,
    required int superChapterId,
    required String superChapterName,
    required String link,
    required bool collect,
  }) = _Article;

  factory Article.fromJson(Map<String, dynamic> json) =>
      _$ArticleFromJson(json);
}
