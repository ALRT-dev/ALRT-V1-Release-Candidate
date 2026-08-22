import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/models/location_subscription_model.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/features/shared/views/widgets/base_bottomsheet.dart';
import 'package:hazard_app/others/app_colors.dart';

enum MyLocationOption {
  changeLocation,
  changeRadius,
}

class ChangeMyLocationSubscriptionBottomsheetContent
    extends ConsumerStatefulWidget {
  const ChangeMyLocationSubscriptionBottomsheetContent({
    super.key,
    required this.locationSubscription,
  });

  final LocationSubscription locationSubscription;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MyLocationOptionsBottomsheetState();
}

class _MyLocationOptionsBottomsheetState
    extends ConsumerState<ChangeMyLocationSubscriptionBottomsheetContent> {
  @override
  Widget build(BuildContext context) {
    return BaseBottomsheet(
      child: Padding(
        padding: EdgeInsets.all(20.spMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            24.spMin.verticalSpace,
            _buildOptions(),
            16.spMin.verticalSpace,
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40.spMin,
      height: 4.spMin,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(2.spMin),
      ),
    );
  }

  Widget _buildOptions() {
    return Row(
      children: [
        Expanded(
          child: _buildOptionCard(
            icon: Icons.location_on_rounded,
            label: 'Change Location',
            color: AppColors.green,
            onTap: () => _handleOptionPress(MyLocationOption.changeLocation),
          ),
        ),
        16.spMin.horizontalSpace,
        Expanded(
          child: _buildOptionCard(
            icon: Icons.adjust_rounded,
            label: 'Change Radius',
            color: AppColors.orange,
            onTap: () => _handleOptionPress(MyLocationOption.changeRadius),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 24.spMin,
          horizontal: 16.spMin,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.spMin),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.spMin),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: 28.spMin,
              ),
            ),
            12.spMin.verticalSpace,
            Text(
              label,
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleOptionPress(MyLocationOption option) {
    if (option == MyLocationOption.changeLocation) {
      showChangeLocationBottomsheet(context: context);
    } else if (option == MyLocationOption.changeRadius) {
      final ownLocationRadiusKm =
          ref.read(providerOfLoggedInUser)?.ownLocationSubscriptionRadiusKm ??
          5;
      showChangeRadiusBottomsheet(
        context: context,
        initialRadius: ownLocationRadiusKm,
      );
    }
  }
}
