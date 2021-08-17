part of 'models.dart';

@freezed
class HomeBanner with _$HomeBanner {
  const factory HomeBanner({
    required int id,
    required String url,
    required String imagePath,
  }) = _HomeBanner;

  factory HomeBanner.fromJson(Map<String, dynamic> json) =>
      _$HomeBannerFromJson(json);
}
