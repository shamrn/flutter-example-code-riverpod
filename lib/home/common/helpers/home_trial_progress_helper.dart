import 'package:injectable/injectable.dart';
import 'package:prime_ballet/home/common/models/home_exercise_collection_ui.dart';
import 'package:prime_ballet/home/common/repositories/home_local_training_progress_repository.dart';

@lazySingleton
class HomeTrialProgressHelper {
  HomeTrialProgressHelper(this._homeLocalTrainingProgressRepository);

  static const _percentWhenVideoIsViewed = 0.9;

  final HomeLocalTrainingProgressRepository
  _homeLocalTrainingProgressRepository;

  int getSecondsViewedVideo({required int trialExerciseId}) {
    return _homeLocalTrainingProgressRepository.getSecondsViewedVideo(
      trialExerciseId: trialExerciseId,
    );
  }

  int getTotalProgressValue(HomeExerciseCollectionUi trialPlaylist) {
    var numberViewedVideos = 0;

    for (final exercise in trialPlaylist.exercises) {
      final viewedVideoInSeconds = getSecondsViewedVideo(
        trialExerciseId: exercise.id,
      );

      if (viewedVideoInSeconds / exercise.durationVideoInSeconds >
          _percentWhenVideoIsViewed) {
        numberViewedVideos++;
      }
    }

    return (numberViewedVideos / trialPlaylist.exercises.length * 100).toInt();
  }
}
