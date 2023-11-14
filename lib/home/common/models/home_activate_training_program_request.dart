import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prime_ballet/common/models/active_program_type.dart';

part 'home_activate_training_program_request.freezed.dart';
part 'home_activate_training_program_request.g.dart';

@freezed
class HomeActivateTrainingProgramRequest
    with _$HomeActivateTrainingProgramRequest {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory HomeActivateTrainingProgramRequest({
    required ActiveProgramType activeProgram,
  }) = _HomeActivateTrainingProgramRequest;

  factory HomeActivateTrainingProgramRequest.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$HomeActivateTrainingProgramRequestFromJson(json);
}
