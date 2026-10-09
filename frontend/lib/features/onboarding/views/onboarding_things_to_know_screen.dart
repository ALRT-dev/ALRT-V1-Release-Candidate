import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/onboarding/enums/onboarding_step_types.dart';
import 'package:hazard_app/features/onboarding/providers/onboarding_provider.dart';
import 'package:hazard_app/features/onboarding/views/widgets/gradient_button.dart';
import 'package:hazard_app/features/onboarding/views/widgets/progress_bar.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/utils/app_links.dart';
import 'package:hazard_app/features/shared/utils/open_link.dart';
import 'package:hazard_app/others/app_colors.dart';

/// Merged onboarding screen combining the former Disclaimer and Legal screens.
///
/// Shows four acknowledgement items the user must tick before continuing.
/// On Continue, both [acceptOnboardingDisclaimer] and
/// [acceptOnboardingTermsOfService] API calls fire.
class OnboardingThingsToKnowScreen extends ConsumerStatefulWidget {
  const OnboardingThingsToKnowScreen({super.key});

  static const route = '/onboarding/things-to-know';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OnboardingThingsToKnowScreenState();
}

class _OnboardingThingsToKnowScreenState
    extends ConsumerState<OnboardingThingsToKnowScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  /// The four acknowledgement items the user must tick.
  final List<bool> _ticks = [false, false, false, false];

  bool get _allTicked => _ticks.every((t) => t);

  static const _step = OnboardingStep.thingsToKnow;

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
    // Keep the provider alive while this screen is mounted.
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  28.hSizedBox,
                  _buildTickItem(
                    index: 0,
                    title: 'ALRT is not an emergency service',
                    subtitle:
                        'In a life-threatening situation, call your local emergency number.',
                  ),
                  16.hSizedBox,
                  _buildTickItem(
                    index: 1,
                    title: 'Information may be delayed or incomplete',
                    subtitle:
                        'Alerts come from many sources and may not be verified.',
                  ),
                  16.hSizedBox,
                  _buildTickItem(
                    index: 2,
                    title: 'Your location stays on your phone',
                    subtitle:
                        'Location is used only to show alerts near you and is never shared unless you choose.',
                  ),
                  16.hSizedBox,
                  _buildTickItem(
                    index: 3,
                    title: 'I accept the Terms, Privacy Policy and Disclaimer',
                    subtitle: null,
                    hasLinks: true,
                  ),
                  32.hSizedBox,
                  GradientButton(
                    title: 'Continue',
                    onPressed: _allTicked ? _onContinue : null,
                  ),
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
    return GestureDetector(
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
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(
          child: Container(
            padding: EdgeInsets.all(14.spMin),
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline_rounded,
              size: 40.spMin,
              color: AppColors.orange,
            ),
          ),
        ),
        20.hSizedBox,
        Text(
          'Three things to know',
          style: TextStyle(
            fontSize: 26.spMin,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
          textAlign: TextAlign.center,
        ),
        10.hSizedBox,
        Text(
          'Please read and acknowledge each item to continue.',
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

  Widget _buildTickItem({
    required int index,
    required String title,
    required String? subtitle,
    bool hasLinks = false,
  }) {
    final isChecked = _ticks[index];

    return GestureDetector(
      onTap: () => setState(() => _ticks[index] = !_ticks[index]),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.spMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.spMin),
          border: Border.all(
            color: isChecked
                ? AppColors.orange
                : AppColors.lightGrey.withValues(alpha: 0.5),
            width: isChecked ? 2 : 1,
          ),
          color: isChecked
              ? AppColors.orange.withValues(alpha: 0.04)
              : AppColors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26.spMin,
              height: 26.spMin,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.orange : Colors.transparent,
                borderRadius: BorderRadius.circular(7.spMin),
                border: Border.all(
                  color: isChecked ? AppColors.orange : AppColors.mediumGrey,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? Icon(
                      Icons.check,
                      size: 16.spMin,
                      color: AppColors.white,
                    )
                  : null,
            ),
            12.wSizedBox,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                      height: 1.3,
                    ),
                  ),
                  if (subtitle != null) ...[
                    6.hSizedBox,
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.spMin,
                        color: AppColors.grey,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (hasLinks) ...[
                    6.hSizedBox,
                    _buildLegalLinks(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalLinks() {
    final linkStyle = TextStyle(
      fontSize: 13.spMin,
      color: AppColors.orange,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.orange,
    );
    final normalStyle = TextStyle(
      fontSize: 13.spMin,
      color: AppColors.grey,
    );

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Terms of Use',
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => openLink(
                    context: context,
                    link: AppLinks.termsOfUse,
                  ),
          ),
          TextSpan(text: ', ', style: normalStyle),
          TextSpan(
            text: 'Privacy Policy',
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => openLink(
                    context: context,
                    link: AppLinks.privacyPolicy,
                  ),
          ),
          TextSpan(text: ' and ', style: normalStyle),
          TextSpan(
            text: 'Disclaimer',
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => openLink(
                    context: context,
                    link: AppLinks.disclaimer,
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _onContinue() async {
    // Fire both accept calls as per the handoff spec.
    final disclaimerResult = await ref
        .read(providerOfOnboarding.notifier)
        .acceptOnboardingDisclaimer();

    if (!mounted) return;

    final isDisclaimerOk = disclaimerResult.when(
      (_) => true,
      (error) {
        context.showErrorToast(message: error.message);
        return false;
      },
    );

    if (!isDisclaimerOk) return;

    final tosResult = await ref
        .read(providerOfOnboarding.notifier)
        .acceptOnboardingTermsOfService();

    if (!mounted) return;

    tosResult.when(
      (_) => context.push(_step.nextStep.route),
      (error) => context.showErrorToast(message: error.message),
    );
  }
}
