part of 'models.dart';

@freezed
class HomeTab with _$HomeTab {
  const factory HomeTab(int chapterId, String name, bool editable) = _HomeTab;
}
