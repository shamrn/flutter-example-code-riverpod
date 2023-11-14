import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prime_ballet/home/common/models/home_exercise_collection_ui.dart';
import 'package:prime_ballet/home/home/common/models/home_progress_ui.dart';
import 'package:prime_ballet/home/home/home_path_progress/models/home_path_progress_errors.dart';

part 'home_path_progress_state.freezed.dart';

@freezed
class HomePathProgressState with _$HomePathProgressState {
  const factory HomePathProgressState({
    required DateTime fromDate,
    required DateTime toDate,
    @Default(true) bool isProgressLoading,
    @Default(true) bool isExerciseLoading,
    @Default(false) bool isHomeRedirect,
    HomeProgressUi? progress,
    @Default([]) List<HomeExerciseCollectionUi> exerciseCollectionList,
    HomePathProgressErrors? errors,
  }) = _HomePathProgressState;
}
