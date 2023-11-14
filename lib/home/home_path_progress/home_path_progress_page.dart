import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prime_ballet/common/arguments/home_exercise_video_arguments.dart';
import 'package:prime_ballet/common/arguments/home_progress_arguments.dart';
import 'package:prime_ballet/common/extensions/localization_extension.dart';
import 'package:prime_ballet/common/providers/consumer_state_with_provider.dart';
import 'package:prime_ballet/common/routes.dart';
import 'package:prime_ballet/common/ui/app_colors.dart';
import 'package:prime_ballet/common/widgets/app_text_dialog.dart';
import 'package:prime_ballet/common/widgets/app_top_bar.dart';
import 'package:prime_ballet/home/common/models/home_exercise_detail_ui.dart';
import 'package:prime_ballet/home/common/widgets/home_weeks_progress_view.dart';
import 'package:prime_ballet/home/home/common/widgets/home_progress_view.dart';
import 'package:prime_ballet/home/home/home_path_progress/provider/home_path_progress_provider.dart';
import 'package:prime_ballet/home/home/home_path_progress/provider/home_path_progress_state.dart';

class HomePathProgressPage extends ConsumerStatefulWidget {
  const HomePathProgressPage({
    required HomeProgressArguments arguments,
    super.key,
  }) : _arguments = arguments;

  final HomeProgressArguments _arguments;

  @override
  ConsumerState<HomePathProgressPage> createState() =>
      // ignore: no_logic_in_create_state
      _HomePathProgressState(_arguments);
}

class _HomePathProgressState extends ConsumerStateWithProvider<
    HomePathProgressProvider, HomePathProgressState, HomePathProgressPage> {
  _HomePathProgressState(HomeProgressArguments arguments)
      : super(param1: arguments);

  void _errorsListener(
    HomePathProgressState? previous,
    HomePathProgressState next,
  ) {
    if (next.errors?.isServerUnknownError ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.locale.unknownError)),
      );
    }
  }

  void _redirectToHomeListener(
    HomePathProgressState? previous,
    HomePathProgressState next,
  ) {
    if (next.isHomeRedirect) {
      Navigator.of(context).pushReplacementNamed(Routes.home);
    }
  }

  void _onTapResetProgress() {
    showDialog<void>(
      context: context,
      builder: (context) => AppTextDialog(
        title: context.locale.homePathProgressResetProgressDialogTitle,
        description:
            context.locale.homePathProgressResetProgressDialogDescription,
        buttonTitle: context.locale.yesButtonLabel,
        buttonWidth: 121.w,
        buttonHeight: 37.h,
        buttonOnTap: () => ref.read(provider.notifier).resetProgress(),
      ),
    );
  }

  void _onTapPauseProgress() {
    showDialog<void>(
      context: context,
      builder: (context) => AppTextDialog(
        title: context.locale.homeProgressPauseProgressDialogTitle,
        description: context.locale.homeProgressPauseProgressDialogDescription,
        buttonTitle: context.locale.homeProgressPauseButtonLabel,
        buttonWidth: 121.w,
        buttonHeight: 37.h,
        buttonOnTap: () => ref.read(provider.notifier).pauseProgress(),
      ),
    );
  }

  void _onTapPreviousWeek() {
    ref.read(provider.notifier).switchToPreviousWeek();
  }

  void _onTapNextWeek() {
    ref.read(provider.notifier).switchToNextWeek();
  }

  void _onTapExercise(HomeExerciseDetailUi exercise) {
    Navigator.pushNamed(
      context,
      Routes.exerciseVideo,
      arguments: HomeExerciseVideoArguments(
        exerciseDetailUi: exercise,
        isVideoFinishClose: true,
      ),
    );
  }

  Widget _buildBody() {
    final state = ref.watch(provider);

    return Column(
      children: [
        HomeProgressView(
          color: AppColors.lightBlue,
          progress: state.progress,
          onTapReset: _onTapResetProgress,
          onTapPause: _onTapPauseProgress,
          isLoading: state.isProgressLoading,
        ),
        SizedBox(height: 30.h),
        HomeWeeksProgressView(
          fromDate: state.fromDate,
          toDate: state.toDate,
          exerciseCollectionList: state.exerciseCollectionList,
          onTapPreviousWeek: _onTapPreviousWeek,
          onTapNextWeek: _onTapNextWeek,
          onTapExercise: _onTapExercise,
          isLoading: state.isExerciseLoading,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen(provider, _errorsListener)
      ..listen(provider, _redirectToHomeListener);

    return Scaffold(
      appBar: AppTopBar(title: context.locale.homePathProgressAppBarTitle),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(top: 24.h),
          child: _buildBody(),
        ),
      ),
    );
  }
}
