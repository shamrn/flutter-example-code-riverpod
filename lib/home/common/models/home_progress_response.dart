import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_progress_response.freezed.dart';
part 'home_progress_response.g.dart';

@freezed
class HomeProgressResponse with _$HomeProgressResponse {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory HomeProgressResponse({
    required int playlistId,
    required int daysCompleted,
    required int daysLeft,
    required int percent,
  }) = _HomeProgressResponse;

  factory HomeProgressResponse.fromJson(Map<String, dynamic> json) =>
      _$HomeProgressResponseFromJson(json);
}
