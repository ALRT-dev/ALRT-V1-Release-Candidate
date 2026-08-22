import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/profile/providers/my_location_subscriptions_provider.dart';
import 'package:hazard_app/features/profile/providers/states/my_location_subscriptions_provider_state.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/views/widgets/base_bottomsheet.dart';
import 'package:hazard_app/features/shared/views/widgets/spinner.dart';
import 'package:hazard_app/others/app_colors.dart';

class RadiusOption {
  final int value;
  final String label;
  final String description;

  const RadiusOption({
    required this.value,
    required this.label,
    required this.description,
  });
}

class ChangeRadiusBottomsheetContent extends ConsumerStatefulWidget {
  const ChangeRadiusBottomsheetContent({
    super.key,
    required this.initialRadius,
  });

  final int initialRadius;

  @override
  ConsumerState<ChangeRadiusBottomsheetContent> createState() =>
      _ChangeRadiusBottomsheetContentState();
}

class _ChangeRadiusBottomsheetContentState
    extends ConsumerState<ChangeRadiusBottomsheetContent> {
  late int _selectedRadius = widget.initialRadius.clamp(1, 5);

  final List<RadiusOption> _radiusOptions = const [
    RadiusOption(value: 1, label: '1 km', description: 'Immediate vicinity'),
    RadiusOption(value: 2, label: '2 km', description: 'Close neighborhood'),
    RadiusOption(value: 3, label: '3 km', description: 'Local area'),
    RadiusOption(value: 4, label: '4 km', description: 'Extended area'),
    RadiusOption(value: 5, label: '5 km', description: 'Wider community'),
  ];

  @override
  Widget build(BuildContext context) {
    _listenToRadiusUpdateState();

    return BaseBottomsheet(
      safeAreaBottom: false,
      canPop: (ref) => ref.watch(
        providerOfMyLocationSubscriptions.select(
          (value) => value.updateUserLocationSubscriptionRadiusState.maybeWhen(
            orElse: () => true,
            loading: () => false,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.spMin),
        child: SizedBox(
          height: 0.8.sh,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeaderSection(),
                24.hSizedBox,
                _buildRadiusVisualizer(),
                24.hSizedBox,
                _buildRadiusOptions(),
                24.hSizedBox,
                _buildNextButton(),
                24.hSizedBox,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        Text(
          'Set your radius',
          style: TextStyle(
            fontSize: 24.spMin,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
          textAlign: TextAlign.center,
        ),
        12.hSizedBox,
        Text(
          'Choose how far from your location you want to make, confirm, or deny alerts. This helps keep information local and relevant.',
          style: TextStyle(
            color: AppColors.grey,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRadiusVisualizer() {
    return Container(
      height: 280.spMin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.orange.withValues(alpha: 0.05),
            Colors.red.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30.spMin),
        border: Border.all(
          color: AppColors.orange.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.spMin),
        child: Stack(
          children: [
            Center(child: _buildRadiusCircles()),
            Center(child: _buildCenterPin()),
            if (_selectedRadius > 0) _buildRadiusLabel(),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusCircles() {
    return Stack(
      alignment: Alignment.center,
      children: List.generate(_selectedRadius, (index) {
        final size = (index + 1) * 80.spMin;
        return Opacity(
          opacity: 0.3 - (index * 0.05),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.orange,
                width: 2,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCenterPin() {
    return Container(
      width: 40.spMin,
      height: 40.spMin,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF22d3ee), // cyan-400
            Color(0xFF10b981), // green-500
            Color(0xFF3b82f6), // blue-500
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8.spMin,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 12.spMin,
          height: 12.spMin,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildRadiusLabel() {
    return Positioned(
      bottom: 10.spMin,
      left: 0.0,
      right: 0.0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20.spMin,
            vertical: 8.spMin,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(100.spMin),
            border: Border.all(
              color: AppColors.orange.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 8.spMin,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '$_selectedRadius km radius',
            style: TextStyle(
              fontSize: 14.spMin,
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadiusOptions() {
    return Column(
      children: _radiusOptions.asMap().entries.map((entry) {
        final option = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: 12.spMin),
          child: _buildRadiusOptionCard(option),
        );
      }).toList(),
    );
  }

  Widget _buildRadiusOptionCard(RadiusOption option) {
    final isSelected = _selectedRadius == option.value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRadius = option.value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.all(16.spMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.spMin),
          border: Border.all(
            color: isSelected ? AppColors.orange : AppColors.lightGrey,
            width: 2,
          ),
          color: isSelected
              ? AppColors.orange.withValues(alpha: 0.05)
              : AppColors.white,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.orange.withValues(
                      alpha: 0.2,
                    ),
                    blurRadius: 8.spMin,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                4.hSizedBox,
                Text(
                  option.description,
                  style: TextStyle(
                    fontSize: 14.spMin,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              child: Text(
                isSelected ? '✓' : '○',
                style: TextStyle(
                  fontSize: 24.spMin,
                  color: isSelected ? AppColors.orange : AppColors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref.watch(
          providerOfMyLocationSubscriptions.select(
            (value) =>
                value.updateUserLocationSubscriptionRadiusState.maybeWhen(
                  orElse: () => false,
                  loading: () => true,
                ),
          ),
        );
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onSavePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              disabledBackgroundColor: AppColors.lightGrey,
              padding: EdgeInsets.symmetric(vertical: 14.spMin),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.spMin),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? Spinner(
                    color: AppColors.white,
                    size: 23.spMin,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16.spMin,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                      8.wSizedBox,
                      Icon(
                        Icons.check,
                        size: 20.spMin,
                        color: AppColors.white,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  void _listenToRadiusUpdateState() {
    ref.listen(
      providerOfMyLocationSubscriptions.select(
        (value) => value.updateUserLocationSubscriptionRadiusState,
      ),
      (previous, next) {
        next.maybeWhen(
          orElse: () {},
          success: () {
            context.pop();
          },
          error: (error) {
            context.showErrorToast(
              message: error.message,
            );
          },
        );
      },
    );
  }

  /// Handles the save button press action.
  void _onSavePressed() {
    ref
        .read(providerOfMyLocationSubscriptions.notifier)
        .updateLocationSubscriptionRadius(
          newRadiusInKm: _selectedRadius.toDouble(),
        );
  }
}
