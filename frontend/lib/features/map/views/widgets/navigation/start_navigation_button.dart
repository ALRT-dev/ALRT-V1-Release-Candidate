import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/views/widgets/button.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StartNavigationButton extends ConsumerStatefulWidget {
  const StartNavigationButton({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StartNavigationButtonState();
}

class _StartNavigationButtonState extends ConsumerState<StartNavigationButton> {
  @override
  Widget build(BuildContext context) {
    final isNavigating = ref.watch(
      providerOfMap.select(
        (value) => value.currentRoutePlan?.isNavigating ?? false,
      ),
    );

    return SizedBox(
      height: 42.spMin,
      child: Row(
        children: [
          Expanded(
            child: Button.gradient(
              gradient: LinearGradient(
                colors: [
                  AppColors.orange300,
                  AppColors.red200,
                ],
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 16.spMin,
              ),
              borderRadius: 12.0,
              value: 'Start Navigation',
              icon: Icon(LucideIcons.navigation),
              valueStyle: TextStyle(
                fontSize: 14.spMin,
              ),
              isLoading: isNavigating,
              onPressed: _handleStartNavigation,
            ),
          ),
          10.wSizedBox,
          Button.gradient(
            gradient: LinearGradient(
              colors: [
                AppColors.orange300,
                AppColors.red200,
              ],
            ),
            padding: EdgeInsets.zero,
            borderRadius: 12.0,
            icon: Icon(
              LucideIcons.x400,
              size: 20.spMin,
              color: AppColors.white,
            ),
            onPressed: _handleCancelNavigation,
          ),
        ],
      ),
    );
  }

  void _handleStartNavigation() {
    final isNavigating = ref.read(
      providerOfMap.select(
        (value) => value.currentRoutePlan?.isNavigating ?? false,
      ),
    );
    if (isNavigating) return;

    ref.read(providerOfMap.notifier).startNavigation();
  }

  void _handleCancelNavigation() {
    ref.read(providerOfMap.notifier).updateCurrentRoutePlan(null);
  }
}
