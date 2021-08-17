part of 'models.dart';

@freezed
class Chapter with _$Chapter {
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory Chapter({
    required int id,
    required String name,
    required int parentChapterId,
    required List<Chapter> children,
  }) = _Chapter;

  factory Chapter.fromJson(Map<String, dynamic> json) =>
      _$ChapterFromJson(json);
}
