import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:prime_ballet/common/arguments/home_progress_arguments.dart';
import 'package:prime_ballet/common/models/active_program_type.dart';
import 'package:prime_ballet/common/providers/base_state_notifier.dart';
import 'package:prime_ballet/home/common/helpers/home_week_date_helper.dart';
import 'package:prime_ballet/home/common/models/home_exercise_collection_ui.dart';
import 'package:prime_ballet/home/common/repositories/home_exercise_done_repository.dart';
import 'package:prime_ballet/home/home/common/models/home_activate_training_program_request.dart';
import 'package:prime_ballet/home/home/common/models/home_progress_ui.dart';
import 'package:prime_ballet/home/home/common/repositories/home_activate_training_program_repository.dart';
import 'package:prime_ballet/home/home/common/repositories/home_progress_repository.dart';
import 'package:prime_ballet/home/home/home_path_progress/models/home_path_progress_errors.dart';
import 'package:prime_ballet/home/home/home_path_progress/provider/home_path_progress_state.dart';

@injectable
class HomePathProgressProvider
    extends BaseStateNotifier<HomePathProgressState> {
  HomePathProgressProvider({
    @factoryParam required HomeProgressArguments arguments,
    required HomeProgressRepository progressRepository,
    required HomeExerciseDoneRepository exerciseDoneRepository,
    required HomeActivateTrainingProgramRepository
        activateTrainingProgramRepository,
  })  : _arguments = arguments,
        _progressRepository = progressRepository,
        _exerciseDoneRepository = exerciseDoneRepository,
        _activateTrainingProgramRepository = activateTrainingProgramRepository,
        super(HomePathProgressState(
          fromDate: HomeWeekDateHelper.getStartWeek(clock.now()),
          toDate: HomeWeekDateHelper.getEndWeek(clock.now()),
        ));

  final HomeProgressArguments _arguments;
  final HomeProgressRepository _progressRepository;
  final HomeExerciseDoneRepository _exerciseDoneRepository;
  final HomeActivateTrainingProgramRepository
      _activateTrainingProgramRepository;

  @override
  Future<void> onInit() async {
    try {
      unawaited(_fetchExercisesCollection(
        fromDate: state.fromDate,
        toDate: state.toDate,
      ));

      final progressResponse = await _progressRepository.fetchProgress(
        _arguments.trainingProgramId,
      );

      state = state.copyWith(
        isProgressLoading: false,
        progress: HomeProgressUi.fromResponse(progressResponse),
      );
    } on Exception catch (_) {
      state = state.copyWith(
        isProgressLoading: false,
        errors: const HomePathProgressErrors(isServerUnknownError: true),
      );
    }
  }

  Future<void> resetProgress() async {
    try {
      await _progressRepository.reset(_arguments.trainingProgramId);

      state = state.copyWith(isHomeRedirect: true);
    } on Exception catch (_) {
      state = state.copyWith(
        errors: const HomePathProgressErrors(isServerUnknownError: true),
      );
    }
  }

  Future<void> pauseProgress() async {
    try {
      await _activateTrainingProgramRepository.activate(
        const HomeActivateTrainingProgramRequest(
          activeProgram: ActiveProgramType.personal,
        ),
      );

      state = state.copyWith(isHomeRedirect: true);
    } on Exception catch (_) {
      state = state.copyWith(
        errors: const HomePathProgressErrors(isServerUnknownError: true),
      );
    }
  }

  void switchToNextWeek() {
    _fetchExercisesCollection(
      fromDate: HomeWeekDateHelper.addOneWeek(state.fromDate),
      toDate: HomeWeekDateHelper.addOneWeek(state.toDate),
    );
  }

  void switchToPreviousWeek() {
    _fetchExercisesCollection(
      fromDate: HomeWeekDateHelper.subtractOneWeek(state.fromDate),
      toDate: HomeWeekDateHelper.subtractOneWeek(state.toDate),
    );
  }

  Future<void> _fetchExercisesCollection({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    state = state.copyWith(
      isExerciseLoading: true,
      fromDate: fromDate,
      toDate: toDate,
    );

    try {
      final exerciseCollectionResponse =
          await _exerciseDoneRepository.fetchDoneExercises(
        fromDate: HomeWeekDateHelper.dateToServerDate(fromDate),
        toDate: HomeWeekDateHelper.dateToServerDate(toDate),
        playlistId: _arguments.trainingProgramId,
      );

      state = state.copyWith(
        isExerciseLoading: false,
        exerciseCollectionList: exerciseCollectionResponse
            .map(HomeExerciseCollectionUi.fromResponse)
            .toList(),
      );
    } on DioException catch (dioException) {
      if (dioException.response?.statusCode == HttpStatus.notFound) {
        state = state.copyWith(
          isExerciseLoading: false,
          exerciseCollectionList: [],
        );

        return;
      }

      state = state.copyWith(
        isExerciseLoading: false,
        errors: const HomePathProgressErrors(isServerUnknownError: true),
      );
    } on Exception catch (_) {
      state = state.copyWith(
        isExerciseLoading: false,
        errors: const HomePathProgressErrors(isServerUnknownError: true),
      );
    }
  }
}
