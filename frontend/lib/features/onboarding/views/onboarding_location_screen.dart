import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/map/providers/states/location_permission_provider_state.dart';
import 'package:hazard_app/features/onboarding/enums/onboarding_step_types.dart';
import 'package:hazard_app/features/onboarding/providers/onboarding_provider.dart';
import 'package:hazard_app/features/onboarding/views/widgets/gradient_button.dart';
import 'package:hazard_app/features/onboarding/views/widgets/progress_bar.dart';
import 'package:hazard_app/features/onboarding/views/widgets/confirmation_popup.dart';
import 'package:hazard_app/features/onboarding/views/widgets/manual_location_popup.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/features/shared/services/emergency_number.dart';

enum LocationOption { none, current, manual, skip }

class OnboardingLocationScreen extends ConsumerStatefulWidget {
  const OnboardingLocationScreen({super.key});

  static const route = '/onboarding/location';

  static const placesSearchKey = 'OnboardingLocationScreen_placesSearchKey';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OnboardingLocationScreenState();
}

class _OnboardingLocationScreenState
    extends ConsumerState<OnboardingLocationScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pinController;

  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pinPulseAnimation;

  LocationOption _selectedOption = LocationOption.none;
  bool _showConfirmation = false;
  bool _showDenyPopup = false;
  bool _showManualLocationPopup = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pinController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeInAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          ),
        );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(100, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          ),
        );

    _scaleAnimation =
        Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
          ),
        );

    _pinPulseAnimation =
        Tween<double>(
          begin: 1.0,
          end: 1.05,
        ).animate(
          CurvedAnimation(
            parent: _pinController,
            curve: Curves.easeInOut,
          ),
        );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _mainController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _pinController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _handleSelectOption(LocationOption option) {
    setState(() {
      _selectedOption = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenToGetLocationState();

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.orange.withValues(alpha: 0.1),
              AppColors.purple.withValues(alpha: 0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: _slideAnimation.value,
                    child: Opacity(
                      opacity: _fadeInAnimation.value,
                      child: _buildContent(),
                    ),
                  );
                },
              ),
            ),
            if (_showConfirmation) _buildConfirmationPopup(),
            if (_showDenyPopup) _buildDenyPopup(),
            if (_showManualLocationPopup) _buildManualLocationPopup(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30.spMin),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 15.spMin,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.spMin),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40.spMin,
                      height: 40.spMin,
                      decoration: BoxDecoration(
                        color: AppColors.extraLightGrey,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18.spMin,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
              24.hSizedBox,
              ProgressBar(
                currentStep: 3,
                totalSteps: OnboardingStep.values.length - 1,
                label: 'Step 3 of ${OnboardingStep.values.length - 1}',
              ),
              40.hSizedBox,
              _buildHeaderSection(),
              40.hSizedBox,
              _buildLocationOptions(),
              40.hSizedBox,
              _buildActionButtons(),
              20.hSizedBox,
            ],
          ),
        ),
      ),
    ).pad(20.0);
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: _buildPinIcon(),
            );
          },
        ),
        24.hSizedBox,
        AnimatedBuilder(
          animation: _fadeInAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeInAnimation.value,
              child: Column(
                children: [
                  Text(
                    'Where should we keep you safe?',
                    style: TextStyle(
                      fontSize: 28.spMin,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  12.hSizedBox,
                  Text(
                    'Choose your home or current area so we can tailor alerts that matter most.',
                    style: TextStyle(
                      fontSize: 16.spMin,
                      color: AppColors.grey,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPinIcon() {
    return AnimatedBuilder(
      animation: _pinPulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pinPulseAnimation.value,
          child: Text(
            '📍',
            style: TextStyle(fontSize: 72.spMin),
          ),
        );
      },
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

    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: GestureDetector(
            onTap: () => _handleSelectOption(option),
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
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Column(
            children: [
              AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 100),
                child: GradientButton(
                  title: "Next",
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 20.spMin,
                    color: AppColors.white,
                  ),
                  onPressed: _onNext,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfirmationPopup() {
    return ConfirmationPopup(
      show: true,
      message: "Location set! You can now receive alerts for your area.",
      onComplete: _handleConfirmationComplete,
    );
  }

  Widget _buildDenyPopup() {
    // Global app: never hard-code an Australian number in onboarding copy.
    final emergencyNumber = ref.watch(providerOfEmergencyNumber);
    return _buildPopupOverlay(
      child: Container(
        padding: EdgeInsets.all(20.spMin),
        margin: EdgeInsets.symmetric(horizontal: 16.spMin),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                'Location Permission Request',
                style: TextStyle(
                  fontSize: 20.spMin,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              12.hSizedBox,
              Text(
                'We need your location to provide you with the most relevant alerts and updates.',
                style: TextStyle(
                  fontSize: 16.spMin,
                  color: AppColors.grey,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              24.hSizedBox,
              Container(
                padding: EdgeInsets.all(20.spMin),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16.spMin),
                  border: Border.all(
                    color: AppColors.orange.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location access lets us:',
                      style: TextStyle(
                        fontSize: 14.spMin,
                        color: AppColors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    12.hSizedBox,
                    _buildFeatureItem('Match alerts to your area'),
                    8.hSizedBox,
                    _buildFeatureItem('Show you nearby safety information'),
                    8.hSizedBox,
                    _buildFeatureItem('Reduce irrelevant notifications'),
                    12.hSizedBox,
                    Text(
                      'You can still search for your area manually if you '
                      'prefer.',
                      style: TextStyle(
                        fontSize: 14.spMin,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              24.hSizedBox,
              _buildIconButton(
                title: "Yes, allow location access",
                icon: Icons.location_on,
                onPressed: () async {
                  await ref
                      .read(providerOfOnboarding.notifier)
                      .openLocationSettings();
                  if (!mounted) return;
                  setState(() {
                    _showDenyPopup = false;
                  });
                },
              ),
              12.hSizedBox,
              _buildIconButton(
                title: "No, I'll search for my area",
                icon: Icons.search,
                onPressed: () {
                  setState(() {
                    _showDenyPopup = false;
                    _selectedOption = LocationOption.manual;
                  });
                },
                isOutline: true,
              ),
              24.hSizedBox,
              Column(
                children: [
                  Text(
                    'You can change this anytime in Settings → Privacy → Location.',
                    style: TextStyle(
                      fontSize: 12.spMin,
                      color: AppColors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  4.hSizedBox,
                  Text(
                    'ALRT isn\'t an emergency service. '
                    'Call $emergencyNumber in an emergency.',
                    style: TextStyle(
                      fontSize: 12.spMin,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4.spMin,
          height: 4.spMin,
          margin: EdgeInsets.only(top: 6.spMin, right: 8.spMin),
          decoration: BoxDecoration(
            color: AppColors.orange,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.spMin,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    bool isOutline = false,
  }) {
    if (isOutline) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.lightGrey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(100.spMin),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(100.spMin),
            onTap: onPressed,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14.spMin),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20.spMin,
                    color: AppColors.grey,
                  ),
                  8.wSizedBox,
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.spMin,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return GradientButton(
      title: title,
      icon: Icon(
        icon,
        size: 20.spMin,
        color: AppColors.white,
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildPopupOverlay({required Widget child}) {
    return Positioned.fill(
      child: Container(
        color: AppColors.black.withValues(alpha: 0.3),
        child: Center(
          child: child,
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
          success: _onLocationReceived,
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

  void _handleConfirmationComplete() {
    setState(() {
      _showConfirmation = false;
    });

    // context.push(OnboardingStep.location.nextStep.route);
  }

  void _onNext() async {
    if (_selectedOption == LocationOption.none) {
      context.showErrorToast(
        message: 'Please select a location option to proceed.',
      );
      return;
    }

    if (_selectedOption == LocationOption.current) {
      ref.read(providerOfLocation.notifier).getLocation();
    } else {
      setState(() {
        _showManualLocationPopup = true;
      });
    }
  }

  void _onLocationReceived(final AlrtLocation location) async {
    final result = await ref
        .read(providerOfOnboarding.notifier)
        .setOnboardingLocation(location: location);
    if (!mounted) return;

    result.when(
      (onboardingResponse) {
        setState(() {
          _showConfirmation = true;
        });
      },
      (error) {
        context.showErrorToast(
          message: error.message,
        );
      },
    );
  }

  Widget _buildManualLocationPopup() {
    return ManualLocationPopup(
      onCancel: () {
        setState(() {
          _showManualLocationPopup = false;
        });
      },
      onConfirm: (place) {
        setState(() {
          _showManualLocationPopup = false;
        });
        _onLocationReceived(place.toAlrtLocation);
      },
    );
  }
}
