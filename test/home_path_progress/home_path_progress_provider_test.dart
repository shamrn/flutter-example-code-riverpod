import 'dart:io';

import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:prime_ballet/common/arguments/home_progress_arguments.dart';
import 'package:prime_ballet/common/models/active_program_type.dart';
import 'package:prime_ballet/home/common/models/home_exercise_collection_response.dart';
import 'package:prime_ballet/home/common/models/home_exercise_collection_ui.dart';
import 'package:prime_ballet/home/common/models/home_exercise_detail_response.dart';
import 'package:prime_ballet/home/common/models/home_exercise_detail_ui.dart';
import 'package:prime_ballet/home/common/repositories/home_exercise_done_repository.dart';
import 'package:prime_ballet/home/home/common/models/home_activate_training_program_request.dart';
import 'package:prime_ballet/home/home/common/models/home_progress_response.dart';
import 'package:prime_ballet/home/home/common/models/home_progress_ui.dart';
import 'package:prime_ballet/home/home/common/repositories/home_activate_training_program_repository.dart';
import 'package:prime_ballet/home/home/common/repositories/home_progress_repository.dart';
import 'package:prime_ballet/home/home/home_path_progress/models/home_path_progress_errors.dart';
import 'package:prime_ballet/home/home/home_path_progress/provider/home_path_progress_provider.dart';
import 'package:prime_ballet/home/home/home_path_progress/provider/home_path_progress_state.dart';

import 'home_path_progress_provider_test.mocks.dart';

@GenerateMocks([
  HomeProgressRepository,
  HomeExerciseDoneRepository,
  HomeActivateTrainingProgramRepository,
])
void main() {
  final progressRepository = MockHomeProgressRepository();
  final exerciseDoneRepository = MockHomeExerciseDoneRepository();
  final activateTrainingProgramRepository =
      MockHomeActivateTrainingProgramRepository();

  final ref = ProviderContainer();

  final initialDate = DateTime(2023, 1, 5);
  final nowClock = Clock.fixed(initialDate);

  final initialFromDate = DateTime(2023, 1, 2);
  final initialToDate = DateTime(2023, 1, 8);

  final nextFromDate = initialFromDate.add(const Duration(
    days: DateTime.daysPerWeek,
  ));
  final nexToDate = initialToDate.add(const Duration(
    days: DateTime.daysPerWeek,
  ));

  final previousFromDate = initialFromDate.subtract(const Duration(
    days: DateTime.daysPerWeek,
  ));
  final previousToDate = initialToDate.subtract(const Duration(
    days: DateTime.daysPerWeek,
  ));

  final serverDateFormat = DateFormat('yyyy-MM-dd');

  final initialServerFromDate = serverDateFormat.format(initialFromDate);
  final initialServerToDate = serverDateFormat.format(initialToDate);

  final nextServerFromDate = serverDateFormat.format(nextFromDate);
  final nextServerToDate = serverDateFormat.format(nexToDate);

  final previousServerFromDate = serverDateFormat.format(previousFromDate);
  final previousServerToDate = serverDateFormat.format(previousToDate);

  const trainingProgramId = 1;
  const arguments = HomeProgressArguments(trainingProgramId: trainingProgramId);

  const activateTrainingProgramRequest = HomeActivateTrainingProgramRequest(
    activeProgram: ActiveProgramType.personal,
  );

  const exerciseCollectionResponseListFirst = [
    HomeExerciseCollectionResponse(
      title: 'title',
      exercises: [
        HomeExerciseDetailResponse(
          exerciseId: 1,
          title: 'title',
          duration: 200,
          image: 'image',
          video: 'video',
          timeSeconds: 100,
        ),
      ],
    ),
  ];

  const exerciseCollectionUiListFirst = [
    HomeExerciseCollectionUi(
      title: 'title',
      exercises: [
        HomeExerciseDetailUi(
          id: 1,
          name: 'title',
          imageUrl: 'image',
          videoUrl: 'video',
          durationVideoInSeconds: 200,
          viewedVideoInSeconds: 100,
        ),
      ],
    ),
  ];

  const exerciseCollectionResponseListSecond = [
    HomeExerciseCollectionResponse(
      title: 'title 2',
      exercises: [
        HomeExerciseDetailResponse(
          exerciseId: 2,
          title: 'title',
          duration: 200,
          image: 'image',
          video: 'video',
          timeSeconds: 100,
        ),
      ],
    ),
  ];

  const exerciseCollectionUiListSecond = [
    HomeExerciseCollectionUi(
      title: 'title 2',
      exercises: [
        HomeExerciseDetailUi(
          id: 2,
          name: 'title',
          imageUrl: 'image',
          videoUrl: 'video',
          durationVideoInSeconds: 200,
          viewedVideoInSeconds: 100,
        ),
      ],
    ),
  ];

  const progressResponse = HomeProgressResponse(
    playlistId: trainingProgramId,
    daysCompleted: 10,
    daysLeft: 20,
    percent: 50,
  );

  const progressUi = HomeProgressUi(
    id: trainingProgramId,
    value: 50,
    daysCompleted: 10,
    daysLeft: 20,
  );

  late StateNotifierProvider<HomePathProgressProvider, HomePathProgressState>
      provider;

  setUp(
    () => {
      provider = StateNotifierProvider<HomePathProgressProvider,
          HomePathProgressState>(
        (ref) => withClock(
          nowClock,
          () => HomePathProgressProvider(
            arguments: arguments,
            progressRepository: progressRepository,
            exerciseDoneRepository: exerciseDoneRepository,
            activateTrainingProgramRepository:
                activateTrainingProgramRepository,
          ),
        ),
      ),
    },
  );

  DioException createDioException({required int statusCode}) {
    return DioException(
      response: Response(
        statusCode: statusCode,
        requestOptions: RequestOptions(),
      ),
      requestOptions: RequestOptions(),
    );
  }

  Future<void> expectOnSuccessInitialState() async {
    await expectLater(
      ref.read(provider),
      HomePathProgressState(
        fromDate: initialFromDate,
        toDate: initialToDate,
      ),
    );
  }

  Future<void> expectOnSuccessLoadedState() async {
    await expectLater(
      ref.read(provider),
      HomePathProgressState(
        fromDate: initialFromDate,
        toDate: initialToDate,
        isProgressLoading: false,
        isExerciseLoading: false,
        progress: progressUi,
        exerciseCollectionList: exerciseCollectionUiListFirst,
      ),
    );
  }

  test('Check default state values', () {
    final initialState = HomePathProgressState(
      fromDate: initialFromDate,
      toDate: initialToDate,
    );

    expect(initialState.isProgressLoading, true);
    expect(initialState.isExerciseLoading, true);
    expect(initialState.progress, null);
    expect(initialState.exerciseCollectionList, <HomeExerciseCollectionUi>[]);
    expect(initialState.errors, null);
  });

  group(
    'Group test with: '
    '`fetchExercisesCollection.fetchExercisesCollection` answer `exerciseCollectionResponseListFirst`'
    '`totalProgressRepository.fetchProgress` answer `progressResponse`',
    () {
      when(exerciseDoneRepository.fetchDoneExercises(
        fromDate: initialServerFromDate,
        toDate: initialServerToDate,
        playlistId: trainingProgramId,
      )).thenAnswer(
        (_) async => exerciseCollectionResponseListFirst,
      );
      when(progressRepository.fetchProgress(trainingProgramId)).thenAnswer(
        (_) async => progressResponse,
      );

      test('Check `onInit` method when successful execution', () async {
        await expectOnSuccessInitialState();
        await expectOnSuccessLoadedState();
      });

      test(
        'Check `resetProgress` method when successful execution',
        () async {
          await expectOnSuccessInitialState();
          await expectOnSuccessLoadedState();

          await ref.read(provider.notifier).resetProgress();

          verify(progressRepository.reset(trainingProgramId)).called(1);

          await expectLater(
            ref.read(provider),
            HomePathProgressState(
              fromDate: initialFromDate,
              toDate: initialToDate,
              isProgressLoading: false,
              isExerciseLoading: false,
              isHomeRedirect: true,
              progress: progressUi,
              exerciseCollectionList: exerciseCollectionUiListFirst,
            ),
          );
        },
      );

      test(
        'Check `resetProgress` method when `resetProgressRepository`'
        'throws base exception',
        () async {
          when(progressRepository.reset(trainingProgramId)).thenThrow(
            Exception(),
          );

          await expectOnSuccessInitialState();
          await expectOnSuccessLoadedState();

          await ref.read(provider.notifier).resetProgress();

          await expectLater(
            ref.read(provider),
            HomePathProgressState(
              fromDate: initialFromDate,
              toDate: initialToDate,
              isProgressLoading: false,
              isExerciseLoading: false,
              progress: progressUi,
              exerciseCollectionList: exerciseCollectionUiListFirst,
              errors: const HomePathProgressErrors(isServerUnknownError: true),
            ),
          );
        },
      );

      test(
        'Check `pauseProgress` method when successful execution',
        () async {
          await expectOnSuccessInitialState();
          await expectOnSuccessLoadedState();

          await ref.read(provider.notifier).pauseProgress();

          verify(activateTrainingProgramRepository.activate(
            const HomeActivateTrainingProgramRequest(
              activeProgram: ActiveProgramType.personal,
            ),
          )).called(1);

          await expectLater(
            ref.read(provider),
            HomePathProgressState(
              fromDate: initialFromDate,
              toDate: initialToDate,
              isProgressLoading: false,
              isExerciseLoading: false,
              isHomeRedirect: true,
              progress: progressUi,
              exerciseCollectionList: exerciseCollectionUiListFirst,
            ),
          );
        },
      );

      test(
        'Check `pauseProgress` method when `resetProgressRepository`'
        'throws base exception',
        () async {
          when(activateTrainingProgramRepository
                  .activate(activateTrainingProgramRequest))
              .thenThrow(Exception());

          await expectOnSuccessInitialState();
          await expectOnSuccessLoadedState();

          await ref.read(provider.notifier).pauseProgress();

          await expectLater(
            ref.read(provider),
            HomePathProgressState(
              fromDate: initialFromDate,
              toDate: initialToDate,
              isProgressLoading: false,
              isExerciseLoading: false,
              progress: progressUi,
              exerciseCollectionList: exerciseCollectionUiListFirst,
              errors: const HomePathProgressErrors(isServerUnknownError: true),
            ),
          );
        },
      );

      test(
        'Check `switchToNextWeek` method when successful execution',
        () async {
          when(
            exerciseDoneRepository.fetchDoneExercises(
              fromDate: nextServerFromDate,
              toDate: nextServerToDate,
              playlistId: trainingProgramId,
            ),
          ).thenAnswer(
            (_) async => exerciseCollectionResponseListSecond,
          );

          await expectOnSuccessInitialState();
          await expectOnSuccessLoadedState();

          ref.read(provider.notifier).switchToNextWeek();

          await expectLater(
            ref.read(provider),
            HomePathProgressState(
              fromDate: nextFromDate,
              toDate: nexToDate,
              isProgressLoading: false,
              progress: progressUi,
              exerciseCollectionList: exerciseCollectionUiListFirst,
            ),
          );
          await expectLater(
            ref.read(provider),
            HomePathProgressState(
              fromDate: nextFromDate,
              toDate: nexToDate,
              isProgressLoading: false,
              isExerciseLoading: false,
              progress: progressUi,
              exerciseCollectionList: exerciseCollectionUiListSecond,
            ),
          );
        },
      );

      test(
        'Check `switchToNextWeek` method when server returns not found ( 404 status )',
        () async {
          when(
            exerciseDoneRepository.fetchDoneExercises(
              fromDate: nextServerFromDate,
              toDate: nextServerToDate,
              playlistId: trainingProgramId,
            ),
          ).thenThrow(createDioException(statusCode: HttpStatus.notFound));

          await expectOnSuccessInitialState();
          await expectOnSuccessLoadedState();

          ref.read(provider.notifier).switchToNextWeek();

          await expectLater(
            ref.read(provider),
            HomePathProgressState(
              fromDate: nextFromDate,
              toDate: nexToDate,
              isProgressLoading: false,
              isExerciseLoading: false,
              progress: progressUi,
              exerciseCollectionList: [],
            ),
          );
        },
      );

      test(
        'Check `switchToNextWeek` method when dio exception',
        () async {
          when(
            exerciseDoneRepository.fetchDoneExercises(
              fromDate: nextServerFromDate,
              toDate: nextServerToDate,
              playlistId: trainingProgramId,
            ),
          ).thenThrow(
            createDioException(statusCode: HttpStatus.internalServerError),
          );

          await expectOnSuccessInitialState();
          await expectOnSuccessLoadedState();

          ref.read(provider.notifier).switchToNextWeek();

          await expectLater(
            ref.read(provider),
            HomePathProgressState(
              fromDate: nextFromDate,
              toDate: nexToDate,
              isProgressLoading: false,
              isExerciseLoading: false,
              progress: progressUi,
              exerciseCollectionList: exerciseCollectionUiListFirst,
              errors: const HomePathProgressErrors(isServerUnknownError: true),
            ),
          );
        },
      );

      test(
        'Check `switchToNextWeek` method when base exception',
        () async {
          when(
            exerciseDoneRepository.fetchDoneExercises(
              fromDate: nextServerFromDate,
              toDate: nextServerToDate,
              playlistId: trainingProgramId,
            ),
          ).thenThrow(Exception());

          await expectOnSuccessInitialState();
          await expectOnSuccessLoadedState();

          ref.read(provider.notifier).switchToNextWeek();

          await expectLater(
            ref.read(provider),
            HomePathProgressState(
              fromDate: nextFromDate,
              toDate: nexToDate,
              isProgressLoading: false,
              isExerciseLoading: false,
              progress: progressUi,
              exerciseCollectionList: exerciseCollectionUiListFirst,
              errors: const HomePathProgressErrors(isServerUnknownError: true),
            ),
          );
        },
      );

      test(
        'Check `switchToPreviousWeek` method when successful execution',
        () async {
          when(
            exerciseDoneRepository.fetchDoneExercises(
              fromDate: previousServerFromDate,
              toDate: previousServerToDate,
              playlistId: trainingProgramId,
            ),
          ).thenAnswer(
            (_) async => exerciseCollectionResponseListSecond,
          );

          await expectOnSuccessInitialState();
          await expectOnSuccessLoadedState();

          ref.read(provider.notifier).switchToPreviousWeek();

          await expectLater(
            ref.read(provider),
            HomePathProgressState(
              fromDate: previousFromDate,
              toDate: previousToDate,
              isProgressLoading: false,
              progress: progressUi,
              exerciseCollectionList: exerciseCollectionUiListFirst,
            ),
          );
          await expectLater(
            ref.read(provider),
            HomePathProgressState(
              fromDate: previousFromDate,
              toDate: previousToDate,
              isProgressLoading: false,
              isExerciseLoading: false,
              progress: progressUi,
              exerciseCollectionList: exerciseCollectionUiListSecond,
            ),
          );
        },
      );

      test(
        'Check `switchToPreviousWeek` method when server returns not found ( 404 status )',
        () async {
          when(
            exerciseDoneRepository.fetchDoneExercises(
              fromDate: previousServerFromDate,
              toDate: previousServerToDate,
              playlistId: trainingProgramId,
            ),
          ).thenThrow(createDioException(statusCode: HttpStatus.notFound));

          await expectOnSuccessInitialState();
          await expectOnSuccessLoadedState();

          ref.read(provider.notifier).switchToPreviousWeek();

          await expectLater(
            ref.read(provider),
            HomePathProgressState(
              fromDate: previousFromDate,
              toDate: previousToDate,
              isProgressLoading: false,
              isExerciseLoading: false,
              progress: progressUi,
              exerciseCollectionList: [],
            ),
          );
        },
      );

      test(
        'Check `switchToPreviousWeek` method when dio exception',
        () async {
          when(
            exerciseDoneRepository.fetchDoneExercises(
              fromDate: previousServerFromDate,
              toDate: previousServerToDate,
              playlistId: trainingProgramId,
            ),
          ).thenThrow(
            createDioException(statusCode: HttpStatus.internalServerError),
          );

          await expectOnSuccessInitialState();
          await expectOnSuccessLoadedState();

          ref.read(provider.notifier).switchToPreviousWeek();

          await expectLater(
            ref.read(provider),
            HomePathProgressState(
              fromDate: previousFromDate,
              toDate: previousToDate,
              isProgressLoading: false,
              isExerciseLoading: false,
              progress: progressUi,
              exerciseCollectionList: exerciseCollectionUiListFirst,
              errors: const HomePathProgressErrors(isServerUnknownError: true),
            ),
          );
        },
      );

      test(
        'Check `switchToPreviousWeek` method when base exception',
        () async {
          when(
            exerciseDoneRepository.fetchDoneExercises(
              fromDate: previousServerFromDate,
              toDate: previousServerToDate,
              playlistId: trainingProgramId,
            ),
          ).thenThrow(Exception());

          await expectOnSuccessInitialState();
          await expectOnSuccessLoadedState();

          ref.read(provider.notifier).switchToPreviousWeek();

          await expectLater(
            ref.read(provider),
            HomePathProgressState(
              fromDate: previousFromDate,
              toDate: previousToDate,
              isProgressLoading: false,
              isExerciseLoading: false,
              progress: progressUi,
              exerciseCollectionList: exerciseCollectionUiListFirst,
              errors: const HomePathProgressErrors(isServerUnknownError: true),
            ),
          );
        },
      );
    },
  );

  test(
    'Check `onInit` method when `exerciseDoneRepository`'
    'throws base exception',
    () async {
      when(exerciseDoneRepository.fetchDoneExercises(
        fromDate: initialServerFromDate,
        toDate: initialServerToDate,
        playlistId: trainingProgramId,
      )).thenThrow(Exception());
      when(progressRepository.fetchProgress(trainingProgramId)).thenAnswer(
        (_) async => progressResponse,
      );

      await expectLater(
        ref.read(provider),
        HomePathProgressState(
          fromDate: initialFromDate,
          toDate: initialToDate,
          isExerciseLoading: false,
          errors: const HomePathProgressErrors(isServerUnknownError: true),
        ),
      );
      await expectLater(
        ref.read(provider),
        HomePathProgressState(
          fromDate: initialFromDate,
          toDate: initialToDate,
          isProgressLoading: false,
          isExerciseLoading: false,
          progress: progressUi,
          errors: const HomePathProgressErrors(isServerUnknownError: true),
        ),
      );
    },
  );

  test(
    'Check `onInit` method when `totalProgressRepository`'
    'throws base exception',
    () async {
      when(exerciseDoneRepository.fetchDoneExercises(
        fromDate: initialServerFromDate,
        toDate: initialServerToDate,
        playlistId: trainingProgramId,
      )).thenAnswer(
        (_) async => exerciseCollectionResponseListFirst,
      );
      when(progressRepository.fetchProgress(trainingProgramId))
          .thenThrow(Exception());

      await expectLater(
        ref.read(provider),
        HomePathProgressState(
          fromDate: initialFromDate,
          toDate: initialToDate,
          isProgressLoading: false,
          errors: const HomePathProgressErrors(isServerUnknownError: true),
        ),
      );
      await expectLater(
        ref.read(provider),
        HomePathProgressState(
          fromDate: initialFromDate,
          toDate: initialToDate,
          isProgressLoading: false,
          isExerciseLoading: false,
          exerciseCollectionList: exerciseCollectionUiListFirst,
          errors: const HomePathProgressErrors(isServerUnknownError: true),
        ),
      );
    },
  );
}
