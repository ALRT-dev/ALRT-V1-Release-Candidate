import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/onboarding/enums/onboarding_step_types.dart';
import 'package:hazard_app/features/onboarding/providers/onboarding_provider.dart';
import 'package:hazard_app/features/onboarding/views/widgets/gradient_button.dart';
import 'package:hazard_app/features/onboarding/views/widgets/onboarding_page.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/utils/app_links.dart';
import 'package:hazard_app/features/shared/utils/open_link.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/others/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

  static const _tickGreen = Color(0xFF16A34A);
  static const _boxBorder = Color(0xFFD5D9DE);

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

    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideUp,
        child: OnboardingPage(
          step: _step,
          children: [
            Text(
              'Three things to know',
              style: TextStyle(
                fontSize: 30.spMin,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                height: 1.15,
                color: AppColors.ink,
              ),
            ),
            8.hSizedBox,
            Text(
              'Tap each one. We keep a record of what you agreed to and when.',
              style: TextStyle(
                fontSize: 15.spMin,
                height: 1.45,
                color: AppColors.mediumGrey,
              ),
            ),
            18.hSizedBox,
            _buildTickItem(
              index: 0,
              title: 'ALRT is not an emergency service',
              subtitle:
                  'Alerts can be late or wrong. In a life-threatening '
                  'situation, call your local emergency number first. Do not '
                  'wait.',
            ),
            10.hSizedBox,
            _buildTickItem(
              index: 1,
              title: 'Your location leaves your phone only when you send it',
              subtitle:
                  'No tracking in the background. A sent location expires '
                  'after an hour.',
            ),
            10.hSizedBox,
            _buildTickItem(
              index: 2,
              title: 'Community reports are not verified by authorities',
              subtitle:
                  'They always say Unverified. Official warnings always come '
                  'first.',
            ),
            14.hSizedBox,
            _buildTickItem(
              index: 3,
              title:
                  'I am 16 or older, or local law allows me to use this app',
              subtitle: null,
            ),
            10.hSizedBox,
            _buildFooter(),
            const Spacer(),
            24.hSizedBox,
            GradientButton(
              title: 'Agree and continue',
              onPressed: _allTicked ? _onContinue : null,
            ),
            if (!_allTicked) ...[
              6.hSizedBox,
              Text(
                'Lights up once all four are ticked',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.spMin,
                  color: AppColors.mediumGrey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// A white card on a soft shadow with a 26 px check square: tapping
  /// anywhere on the card toggles it. The three promises tick green; the
  /// age line is a smaller row that ticks ink, as on the board.
  Widget _buildTickItem({
    required int index,
    required String title,
    required String? subtitle,
  }) {
    final isChecked = _ticks[index];
    final isAge = subtitle == null;
    final tickColour = isAge ? AppColors.ink : _tickGreen;

    return GestureDetector(
      onTap: () => setState(() => _ticks[index] = !_ticks[index]),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.spMin,
          vertical: (isAge ? 12 : 14).spMin,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.spMin),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: isAge
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26.spMin,
              height: 26.spMin,
              decoration: BoxDecoration(
                color: isChecked ? tickColour : AppColors.white,
                borderRadius: BorderRadius.circular(8.spMin),
                border: isChecked
                    ? null
                    : Border.all(color: _boxBorder, width: 2),
              ),
              child: isChecked
                  ? Icon(
                      LucideIcons.check,
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
                      fontSize: (isAge ? 14 : 15).spMin,
                      fontWeight: isAge ? FontWeight.w400 : FontWeight.w700,
                      color: AppColors.ink,
                      height: isAge ? 1.4 : 1.3,
                    ),
                  ),
                  if (subtitle != null) ...[
                    3.hSizedBox,
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.spMin,
                        color: AppColors.mediumGrey,
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The legal line under the cards, with the Terms and Privacy links
  /// opening in the browser.
  Widget _buildFooter() {
    final linkStyle = TextStyle(
      fontSize: 12.spMin,
      height: 1.45,
      color: AppColors.ink,
      fontWeight: FontWeight.w700,
      fontFamily: AppTheme.defaultFontFamily,
    );
    final normalStyle = TextStyle(
      fontSize: 12.spMin,
      height: 1.45,
      color: AppColors.mediumGrey,
      fontFamily: AppTheme.defaultFontFamily,
    );

    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
        style: normalStyle,
        children: [
          const TextSpan(text: 'By continuing you accept the '),
          TextSpan(
            text: 'Terms of Use',
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => openLink(
                context: context,
                link: AppLinks.termsOfUse,
              ),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => openLink(
                context: context,
                link: AppLinks.privacyPolicy,
              ),
          ),
          const TextSpan(
            text:
                '. Under 16? Child mode can be set up by a parent or '
                'guardian.',
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
