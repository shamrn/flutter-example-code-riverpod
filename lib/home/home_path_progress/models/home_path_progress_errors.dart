import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_path_progress_errors.freezed.dart';

@freezed
class HomePathProgressErrors with _$HomePathProgressErrors {
  const factory HomePathProgressErrors({
    @Default(false) bool isServerUnknownError,
  }) = _HomePathProgressErrors;
}
