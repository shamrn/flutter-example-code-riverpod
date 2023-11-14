import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prime_ballet/common/extensions/localization_extension.dart';
import 'package:prime_ballet/common/ui/app_colors.dart';
import 'package:prime_ballet/common/ui/app_text_styles.dart';
import 'package:prime_ballet/common/widgets/app_container_shimmer.dart';

class HomeProgressIndicatorLine extends StatelessWidget {
  const HomeProgressIndicatorLine({
    required Color color,
    required int value,
    required double borderRadiusValue,
    bool isLoading = false,
    super.key,
  })  : _color = color,
        _value = value,
        _borderRadiusValue = borderRadiusValue,
        _isLoading = isLoading,
        assert(value >= 0 && value <= 100);

  final Color _color;
  final int _value;
  final double _borderRadiusValue;
  final bool _isLoading;

  double _getProgressWidth(double maxWidth) {
    return _value < 15.0 ? maxWidth * 0.15 : maxWidth * (_value / 100);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          Container(
            height: constraints.maxHeight,
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.4),
              borderRadius: BorderRadius.circular(_borderRadiusValue),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            alignment: Alignment.centerLeft,
            crossFadeState: _isLoading
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: AppContainerShimmer(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              borderRadius: BorderRadius.circular(_borderRadiusValue),
            ),
            secondChild: Container(
              width: _getProgressWidth(constraints.maxWidth),
              height: constraints.maxHeight,
              decoration: BoxDecoration(
                color: _color,
                borderRadius: BorderRadius.circular(_borderRadiusValue),
              ),
              child: Center(
                child: Text(
                  context.locale.homeProgressIndicatorLineValue(
                    _value,
                  ),
                  style: AppTextStyles.latoBold.copyWith(
                    color: AppColors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
