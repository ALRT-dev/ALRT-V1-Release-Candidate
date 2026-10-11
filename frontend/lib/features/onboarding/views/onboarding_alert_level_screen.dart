import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/onboarding/enums/onboarding_step_types.dart';
import 'package:hazard_app/features/onboarding/enums/push_notification_preference_types.dart';
import 'package:hazard_app/features/onboarding/providers/onboarding_provider.dart';
import 'package:hazard_app/features/onboarding/views/widgets/gradient_button.dart';
import 'package:hazard_app/features/onboarding/views/widgets/onboarding_page.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The three alert levels the user can choose during onboarding.
class _AlertLevelOption {
  final PushNotificationPreference preference;
  final String label;
  final String description;

  const _AlertLevelOption({
    required this.preference,
    required this.label,
    required this.description,
  });
}

/// Onboarding step 3 (board Onb3): choose what to hear about.
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

  static const _radioRing = Color(0xFFD9D6D0);
  static const _infoPeach = Color(0xFFFFF1E8);

  static const List<_AlertLevelOption> _levels = [
    _AlertLevelOption(
      preference: PushNotificationPreference.official,
      label: 'Official warnings only',
      description:
          'Warnings and advice from emergency services, weather and road '
          'agencies near your places. Nothing from the community.',
    ),
    _AlertLevelOption(
      preference: PushNotificationPreference.all,
      label: 'Official and community',
      description:
          'The same, plus reports from people nearby once neighbours have '
          'confirmed them.',
    ),
    _AlertLevelOption(
      preference: PushNotificationPreference.quiet,
      label: 'Keep it quiet',
      description: 'Only the most serious official warnings, as they happen.',
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

    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideUp,
        child: OnboardingPage(
          step: _step,
          children: [
            Text(
              'What do you want to hear about?',
              style: TextStyle(
                fontSize: 26.spMin,
                fontWeight: FontWeight.w700,
                height: 1.15,
                color: AppColors.ink,
              ),
            ),
            8.hSizedBox,
            Text(
              'Pick one, then your phone asks once. Change it any time in '
              'Notifications.',
              style: TextStyle(
                fontSize: 15.spMin,
                height: 1.45,
                color: AppColors.mediumGrey,
              ),
            ),
            24.hSizedBox,
            for (final level in _levels) ...[
              _buildLevelCard(level),
              12.hSizedBox,
            ],
            4.hSizedBox,
            _buildInfoBox(),
            const Spacer(),
            24.hSizedBox,
            _buildTurnOnButton(),
          ],
        ),
      ),
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
            padding: EdgeInsets.all(16.spMin),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14.spMin),
              border: Border.all(
                color: isSelected ? AppColors.ink : AppColors.lightGrey,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Radio(selected: isSelected),
                12.wSizedBox,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        style: TextStyle(
                          fontSize: 15.spMin,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: AppColors.ink,
                        ),
                      ),
                      4.hSizedBox,
                      Text(
                        option.description,
                        style: TextStyle(
                          fontSize: 13.spMin,
                          color: AppColors.mediumGrey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: _infoPeach,
        borderRadius: BorderRadius.circular(12.spMin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.info, size: 18.spMin, color: AppColors.orange),
          10.wSizedBox,
          Expanded(
            child: Text(
              'ALRT shows the warning as the agency issued it. It never '
              'raises or lowers a level because of the words inside.',
              style: TextStyle(
                fontSize: 13.spMin,
                height: 1.4,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
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
          onPressed: hasSelection ? _onTurnOnAlerts : null,
        );
      },
    );
  }

  Future<void> _onTurnOnAlerts() async {
    final selectedPref = ref
        .read(providerOfOnboarding)
        .selectedNotificationPreference;

    // Every level still delivers the most serious official warnings, so
    // the OS permission prompt is primed for all three.
    if (selectedPref != null) {
      await FirebaseMessaging.instance.requestPermission(
        carPlay: false,
      );
    }

    if (!mounted) return;

    // Save the preference to the backend.
    final notifier = ref.read(providerOfOnboarding.notifier);
    final result = await notifier.setOnboardingNotificationPreferences();

    if (!mounted) return;

    result.when(
      (_) {
        // "Keep it quiet" is stored in two calls; if the narrowing one
        // failed the step is still recorded, so say so and move on.
        final narrowingError = notifier.quietNarrowingError;
        if (narrowingError != null) {
          context.showErrorToast(message: narrowingError.message);
        }
        context.push(_step.nextStep.route);
      },
      (error) => context.showErrorToast(message: error.message),
    );
  }
}

/// The board's radio: a 22 px circle with a 2 px #D9D6D0 ring, filled
/// #1C1C1E with a white dot when on.
class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22.spMin,
      height: 22.spMin,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.ink : AppColors.white,
        border: Border.all(
          color: selected
              ? AppColors.ink
              : _OnboardingAlertLevelScreenState._radioRing,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8.spMin,
                height: 8.spMin,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                ),
              ),
            )
          : null,
    );
  }
}
