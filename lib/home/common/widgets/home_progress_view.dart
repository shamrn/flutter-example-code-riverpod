import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prime_ballet/common/extensions/localization_extension.dart';
import 'package:prime_ballet/common/ui/app_assets.dart';
import 'package:prime_ballet/common/ui/app_colors.dart';
import 'package:prime_ballet/common/ui/app_text_styles.dart';
import 'package:prime_ballet/common/widgets/app_container_shimmer.dart';
import 'package:prime_ballet/home/home/common/models/home_progress_ui.dart';
import 'package:prime_ballet/home/home/common/widgets/home_progress_indicator_line.dart';

class HomeProgressView extends StatelessWidget {
  const HomeProgressView({
    required Color color,
    required VoidCallback onTapReset,
    required VoidCallback onTapPause,
    required HomeProgressUi? progress,
    bool isLoading = false,
    super.key,
  })  : _color = color,
        _progress = progress,
        _onTapReset = onTapReset,
        _onTapPause = onTapPause,
        _isLoading = isLoading;

  final Color _color;
  final VoidCallback _onTapReset;
  final VoidCallback _onTapPause;
  final HomeProgressUi? _progress;
  final bool _isLoading;

  Widget _buildIndicatorSection(BuildContext context) {
    return SizedBox(
      height: 32.h,
      child: Row(
        children: [
          Expanded(
            child: HomeProgressIndicatorLine(
              color: _color,
              value: _progress?.value ?? 0,
              borderRadiusValue: 8.r,
              isLoading: _isLoading,
            ),
          ),
          IconButton(
            onPressed: _onTapReset,
            icon: SvgPicture.asset(AppAssets.refreshIcon),
          ),
          IconButton(
            onPressed: _onTapPause,
            icon: SvgPicture.asset(AppAssets.pauseIcon),
          ),
        ],
      ),
    );
  }

  Widget _buildDay({required String title, required int numberDays}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 16.w),
        height: 130.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.latoRegular.copyWith(
                fontSize: 13.sp,
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _isLoading
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: AppContainerShimmer(
                width: 30.w,
                height: 34.h,
                borderRadius: BorderRadius.circular(8.r),
              ),
              secondChild: Text(
                numberDays.toString(),
                style: AppTextStyles.serifBold.copyWith(
                  color: _color,
                  fontSize: 32.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDay(
          title: context.locale.homeProgressViewDaysCompletedTitle,
          numberDays: _progress?.daysCompleted ?? 0,
        ),
        SizedBox(width: 10.w),
        _buildDay(
          title: context.locale.homeProgressViewDaysLeftTitle,
          numberDays: _progress?.daysLeft ?? 0,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          _buildIndicatorSection(context),
          SizedBox(height: 30.h),
          _buildDaysSection(context),
        ],
      ),
    );
  }
}
