import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/map/providers/states/location_permission_provider_state.dart';
import 'package:hazard_app/features/onboarding/views/widgets/manual_location_popup.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/views/widgets/base_bottomsheet.dart';
import 'package:hazard_app/others/app_colors.dart';

enum LocationOption { none, current, manual }

class ChangeLocationBottomsheetContent extends ConsumerStatefulWidget {
  const ChangeLocationBottomsheetContent({super.key});

  @override
  ConsumerState<ChangeLocationBottomsheetContent> createState() =>
      _ChangeLocationBottomsheetContentState();
}

class _ChangeLocationBottomsheetContentState
    extends ConsumerState<ChangeLocationBottomsheetContent> {
  LocationOption _selectedOption = LocationOption.none;
  bool _showManualLocationPopup = false;
  bool _showDenyPopup = false;

  @override
  Widget build(BuildContext context) {
    _listenToGetLocationState();

    return BaseBottomsheet(
      safeAreaBottom: false,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(20.spMin),
            child: SizedBox(
              height: 0.7.sh,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildHeaderSection(),
                  24.hSizedBox,
                  _buildLocationOptions(),
                  24.hSizedBox,
                  _buildSaveButton().pB(24.0),
                ],
              ),
            ),
          ),
          if (_showManualLocationPopup) _buildManualLocationPopup(),
          if (_showDenyPopup) _buildDenyPopup(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        Text(
          'Change your location',
          style: TextStyle(
            fontSize: 24.spMin,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
          textAlign: TextAlign.center,
        ),
        12.hSizedBox,
        Text(
          'Update your home or current area so we can tailor alerts that matter most to you.',
          style: TextStyle(
            color: AppColors.grey,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        20.hSizedBox,
        Container(
          padding: EdgeInsets.all(16.spMin),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.orange.withValues(alpha: 0.2),
                AppColors.purple.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withValues(alpha: 0.3),
                blurRadius: 20.spMin,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            '📍',
            style: TextStyle(fontSize: 72.spMin),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationOptions() {
    return Column(
      children: [
        _buildOptionCard(
          option: LocationOption.current,
          icon: Icons.my_location,
          title: 'Use my location',
          subtitle: 'Automatically detect current area',
        ),
        12.hSizedBox,
        _buildOptionCard(
          option: LocationOption.manual,
          icon: Icons.edit_location,
          title: 'Enter your area manually',
          subtitle: 'Type your location',
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required LocationOption option,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedOption == option;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = option;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.all(20.spMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.spMin),
          border: Border.all(
            color: isSelected
                ? AppColors.orange
                : AppColors.lightGrey.withValues(alpha: 0.5),
            width: 2,
          ),
          color: isSelected
              ? AppColors.orange.withValues(alpha: 0.05)
              : AppColors.white,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.orange.withValues(alpha: 0.2),
                    blurRadius: 10.spMin,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(12.spMin),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.orange500
                    : AppColors.extraLightGrey,
                borderRadius: BorderRadius.circular(12.spMin),
              ),
              child: Icon(
                icon,
                size: 24.spMin,
                color: isSelected ? AppColors.white : AppColors.grey,
              ),
            ),
            16.wSizedBox,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.spMin,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  4.hSizedBox,
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.spMin,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  '✓',
                  style: TextStyle(
                    fontSize: 24.spMin,
                    color: AppColors.orange,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedOption != LocationOption.none ? _onSave : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          disabledBackgroundColor: AppColors.lightGrey,
          padding: EdgeInsets.symmetric(vertical: 14.spMin),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.spMin),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Save',
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w600,
                color: _selectedOption != LocationOption.none
                    ? AppColors.white
                    : AppColors.grey,
              ),
            ),
            8.wSizedBox,
            Icon(
              Icons.check,
              size: 20.spMin,
              color: _selectedOption != LocationOption.none
                  ? AppColors.white
                  : AppColors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualLocationPopup() {
    return Positioned.fill(
      child: ManualLocationPopup(
        onCancel: () {
          setState(() {
            _showManualLocationPopup = false;
          });
        },
        onConfirm: (place) {
          setState(() {
            _showManualLocationPopup = false;
          });
          context.pop(place.toAlrtLocation);
        },
      ),
    );
  }

  Widget _buildDenyPopup() {
    return Positioned.fill(
      child: Container(
        color: AppColors.black.withValues(alpha: 0.3),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20.spMin),
            margin: EdgeInsets.symmetric(horizontal: 16.spMin),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(30.spMin),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 20.spMin,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showDenyPopup = false;
                          });
                        },
                        icon: Icon(
                          Icons.close,
                          size: 20.spMin,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 80.spMin,
                    height: 80.spMin,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(40.spMin),
                    ),
                    child: Icon(
                      Icons.location_pin,
                      size: 40.spMin,
                      color: Colors.red,
                    ),
                  ),
                  24.hSizedBox,
                  Text(
                    'We can\'t access your location',
                    style: TextStyle(
                      fontSize: 20.spMin,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  12.hSizedBox,
                  Text(
                    'To use your current location, allow location access in your phone settings.',
                    style: TextStyle(
                      fontSize: 16.spMin,
                      color: AppColors.grey,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  24.hSizedBox,
                  _buildIconButton(
                    title: "Search for my area",
                    icon: Icons.search,
                    onPressed: () {
                      setState(() {
                        _showDenyPopup = false;
                        _selectedOption = LocationOption.manual;
                        _showManualLocationPopup = true;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          padding: EdgeInsets.symmetric(vertical: 14.spMin),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.spMin),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20.spMin,
              color: AppColors.white,
            ),
            8.wSizedBox,
            Text(
              title,
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _listenToGetLocationState() {
    ref.listen(
      providerOfLocation.select(
        (value) => value.getLocationState,
      ),
      (previous, next) {
        next.maybeWhen(
          success: (location) {
            context.pop(location);
          },
          error: (error) {
            setState(() {
              _showDenyPopup = true;
            });
          },
          orElse: () {},
        );
      },
    );
  }

  void _onSave() {
    if (_selectedOption == LocationOption.current) {
      ref.read(providerOfLocation.notifier).getLocation();
    } else if (_selectedOption == LocationOption.manual) {
      setState(() {
        _showManualLocationPopup = true;
      });
    }
  }
}
