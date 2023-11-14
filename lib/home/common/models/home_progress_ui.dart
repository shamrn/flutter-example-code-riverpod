import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prime_ballet/home/home/common/models/home_progress_response.dart';

part 'home_progress_ui.freezed.dart';

@freezed
class HomeProgressUi with _$HomeProgressUi {
  const factory HomeProgressUi({
    required int id,
    required int value,
    required int daysCompleted,
    required int daysLeft,
  }) = _HomeProgressUi;

  factory HomeProgressUi.fromResponse(HomeProgressResponse response) =>
      HomeProgressUi(
        id: response.playlistId,
        value: response.percent,
        daysCompleted: response.daysCompleted,
        daysLeft: response.daysLeft,
      );
}
