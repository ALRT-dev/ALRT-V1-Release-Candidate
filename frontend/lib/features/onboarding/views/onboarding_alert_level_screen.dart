import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/onboarding/enums/onboarding_step_types.dart';
import 'package:hazard_app/features/onboarding/enums/push_notification_preference_types.dart';
import 'package:hazard_app/features/onboarding/providers/onboarding_provider.dart';
import 'package:hazard_app/features/onboarding/views/widgets/gradient_button.dart';
import 'package:hazard_app/features/onboarding/views/widgets/progress_bar.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

/// The three alert levels the user can choose during onboarding.
class _AlertLevelOption {
  final PushNotificationPreference preference;
  final IconData icon;
  final String label;
  final String description;
  final Color accentColor;

  const _AlertLevelOption({
    required this.preference,
    required this.icon,
    required this.label,
    required this.description,
    required this.accentColor,
  });
}

/// Onboarding step 3: choose an alert level (all, official only, or quiet).
///
/// "Turn on alerts" triggers the OS notification permission prompt via
/// Firebase Messaging before saving the preference and advancing.
class OnboardingAlertLevelScreen extends ConsumerStatefulWidget {
  const OnboardingAlertLevelScreen({super.key});

  static const route = '/onboarding/alert-level';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OnboardingAlertLevelScreenState();
}

class _OnboardingAlertLevelScreenState
    extends ConsumerState<OnboardingAlertLevelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  static const _step = OnboardingStep.alertLevel;

  static const List<_AlertLevelOption> _levels = [
    _AlertLevelOption(
      preference: PushNotificationPreference.all,
      icon: Icons.notifications_active_rounded,
      label: 'All alerts',
      description: 'Official and community alerts near you',
      accentColor: AppColors.orange,
    ),
    _AlertLevelOption(
      preference: PushNotificationPreference.official,
      icon: Icons.verified_rounded,
      label: 'Official only',
      description: 'Verified alerts from authorities',
      accentColor: AppColors.blue,
    ),
    _AlertLevelOption(
      preference: PushNotificationPreference.quiet,
      icon: Icons.notifications_off_rounded,
      label: 'Keep it quiet',
      description: 'Alerts appear in the app but no push notifications',
      accentColor: AppColors.mediumGrey,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(providerOfOnboarding.select((value) => null));

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.orange.withValues(alpha: 0.08),
              AppColors.purple.withValues(alpha: 0.06),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: _buildCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Container(
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
            child: Padding(
              padding: EdgeInsets.all(20.spMin),
              child: Column(
                children: [
                  _buildBackButton(),
                  24.hSizedBox,
                  ProgressBar(
                    currentStep: _step.index,
                    totalSteps: OnboardingStep.values.length - 1,
                    label:
                        'Step ${_step.index} of ${OnboardingStep.values.length - 1}',
                  ),
                  32.hSizedBox,
                  _buildHeader(),
                  32.hSizedBox,
                  _buildLevelOptions(),
                  32.hSizedBox,
                  _buildTurnOnButton(),
                  20.hSizedBox,
                ],
              ),
            ),
          ).pad(20.0),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Row(
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
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(14.spMin),
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications_rounded,
            size: 40.spMin,
            color: AppColors.orange,
          ),
        ),
        20.hSizedBox,
        Text(
          'Choose your alert level',
          style: TextStyle(
            fontSize: 26.spMin,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
          textAlign: TextAlign.center,
        ),
        10.hSizedBox,
        Text(
          'How do you want to hear about safety alerts? You can change this anytime.',
          style: TextStyle(
            fontSize: 15.spMin,
            color: AppColors.grey,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLevelOptions() {
    return Column(
      children: _levels.map((level) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.spMin),
          child: _buildLevelCard(level),
        );
      }).toList(),
    );
  }

  Widget _buildLevelCard(_AlertLevelOption option) {
    return Consumer(
      builder: (context, ref, child) {
        final isSelected = ref.watch(
          providerOfOnboarding.select(
            (state) =>
                state.selectedNotificationPreference == option.preference,
          ),
        );

        return GestureDetector(
          onTap: () => ref
              .read(providerOfOnboarding.notifier)
              .updateSelectedNotificationPreference(option.preference),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: EdgeInsets.all(18.spMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.spMin),
              border: Border.all(
                color: isSelected
                    ? option.accentColor
                    : AppColors.lightGrey.withValues(alpha: 0.5),
                width: isSelected ? 2 : 1,
              ),
              color: isSelected
                  ? option.accentColor.withValues(alpha: 0.05)
                  : AppColors.white,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.spMin),
                  decoration: BoxDecoration(
                    color: option.accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.spMin),
                  ),
                  child: Icon(
                    option.icon,
                    size: 24.spMin,
                    color: option.accentColor,
                  ),
                ),
                14.wSizedBox,
                Expanded(
                  child: Column(
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
                          fontSize: 13.spMin,
                          color: AppColors.grey,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 24.spMin,
                    color: option.accentColor,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTurnOnButton() {
    return Consumer(
      builder: (context, ref, child) {
        final hasSelection = ref.watch(
          providerOfOnboarding.select(
            (state) => state.selectedNotificationPreference != null,
          ),
        );

        return GradientButton(
          title: 'Turn on alerts',
          icon: Icon(
            Icons.notifications_active_rounded,
            size: 20.spMin,
            color: AppColors.white,
          ),
          onPressed: hasSelection ? _onTurnOnAlerts : null,
        );
      },
    );
  }

  Future<void> _onTurnOnAlerts() async {
    final selectedPref = ref.read(providerOfOnboarding).selectedNotificationPreference;

    // For non-quiet levels, prime the OS notification permission prompt.
    if (selectedPref != PushNotificationPreference.quiet) {
      await FirebaseMessaging.instance.requestPermission(
        carPlay: false,
      );
    }

    if (!mounted) return;

    // Save the preference to the backend.
    final result = await ref
        .read(providerOfOnboarding.notifier)
        .setOnboardingNotificationPreferences();

    if (!mounted) return;

    result.when(
      (_) => context.push(_step.nextStep.route),
      (error) => context.showErrorToast(message: error.message),
    );
  }
}
