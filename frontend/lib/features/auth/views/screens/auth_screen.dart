import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/auth/providers/auth_provider.dart';
import 'package:hazard_app/features/auth/providers/states/auth_provider_state.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/app_links.dart';
import 'package:hazard_app/features/shared/utils/open_link.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/others/env.dart';
import 'package:hazard_app/others/app_theme.dart';
import 'package:hazard_app/others/app_wrapper.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AuthScreen extends ConsumerStatefulWidget {
  /// The authentication screen where users can sign in or sign up.
  const AuthScreen({super.key});

  static const route = '/auth';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  /// Whether the sign-in buttons are visible (after tapping Get Started or
  /// I already have an account).
  bool _showSignIn = false;

  static const _ink = Color(0xFF1C1C1E);
  static const _body = Color(0xFF3A3A42);
  static const _muted = Color(0xFF5C5C66);
  static const _line = Color(0xFFE3E6EA);
  static const _label = Color(0xFFB84500);
  static const _brand = LinearGradient(
    colors: [Color(0xFFFF6B00), Color(0xFFFF0004)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    // register this provider to the lifecycle of this screen
    ref.watch(providerOfAuth.select((value) => null));

    _listenToAuthStateChanges();

    // Settled ruling: the front page and the sign-in page are plain white
    // with the writing and the logo only. No coloured circles, no glow.
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        // Fills the screen while it fits, scrolls the moment it doesn't,
        // so the buttons and the small print are always reachable.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 520.w),
                    child: _showSignIn
                        ? _buildSignInView()
                        : _buildWelcomeView(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Board Splash: the logo and the promise in the middle, Get started and
  /// I already have an account at the foot, and the one-line disclaimer.
  Widget _buildWelcomeView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Hero(
          tag: 'app_logo',
          child: Image.asset(
            'assets/logos/alrt_logo_detailed.png',
            width: 280.spMin,
            filterQuality: FilterQuality.high,
          ),
        ),
        Text(
          'Official warnings, in plain words, for the people and places '
          'you care about.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _body,
            fontSize: 17.spMin,
            height: 1.5,
          ),
        ).pX(28.0),
        const Spacer(),
        24.hSizedBox,
        _brandButton('Get started', () => setState(() => _showSignIn = true)),
        10.hSizedBox,
        SizedBox(
          height: 50.spMin,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: _ink,
              side: const BorderSide(color: _line, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            onPressed: () => setState(() => _showSignIn = true),
            child: Text(
              'I already have an account',
              style: TextStyle(fontSize: 15.spMin, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        14.hSizedBox,
        Text(
          'Not an emergency service. In danger? Call your local emergency '
          'number.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11.spMin, height: 1.4, color: _muted),
        ),
        24.hSizedBox,
      ],
    ).pX(20.0);
  }

  /// Boards Onb5 and SignInReturning: "Last step", why an account helps,
  /// then Apple, Google and Microsoft. No email, no password.
  Widget _buildSignInView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            tooltip: 'Back',
            padding: EdgeInsets.zero,
            onPressed: () => setState(() => _showSignIn = false),
            icon: Icon(LucideIcons.chevronLeft, color: _ink, size: 24.spMin),
          ),
        ),
        20.hSizedBox,
        Text(
          'LAST STEP',
          style: TextStyle(
            color: _label,
            fontSize: 12.spMin,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        8.hSizedBox,
        Text(
          'Keep your places and points',
          style: TextStyle(
            color: _ink,
            fontSize: 30.spMin,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            height: 1.15,
          ),
        ),
        8.hSizedBox,
        Text(
          'An account keeps your places, settings and points across '
          'phones. ALRT never creates or stores a password: you sign in '
          'with Apple, Google or Microsoft.',
          style: TextStyle(color: _muted, fontSize: 15.spMin, height: 1.5),
        ),
        18.hSizedBox,
        _buildAuthButtons(),
        const Spacer(),
        24.hSizedBox,
        _buildTermsAndPrivacySection(),
        24.hSizedBox,
      ],
    ).pX(20.0);
  }

  /// The boards' primary button: 54 px, radius 14, the brand gradient.
  Widget _brandButton(final String label, final VoidCallback onTap) {
    return Container(
      height: 54.spMin,
      decoration: BoxDecoration(
        gradient: _brand,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF0004).withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Apple, Google and Microsoft sign-in buttons.
  Widget _buildAuthButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (Platform.isIOS) ...[
          _buildAppleButton(),
          10.hSizedBox,
        ],
        // Only offer Google when this build has its Google settings. Test
        // builds leave them blank on purpose, and tapping Google there
        // can crash the app on iPhone.
        if (Env.googleAuthServerClientId.isNotEmpty) ...[
          _buildGoogleButton(),
          10.hSizedBox,
        ],
        _buildMicrosoftButton(),
      ],
    );
  }

  /// One provider button from the boards: 52 px, radius 14, dark for
  /// Apple and white with a hairline for the others.
  Widget _providerButton({
    required final String label,
    required final Widget icon,
    required final bool isLoading,
    required final VoidCallback onPressed,
    final bool dark = false,
  }) {
    final foreground = dark ? Colors.white : _ink;
    return SizedBox(
      height: 52.spMin,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: dark ? _ink : Colors.white,
          foregroundColor: foreground,
          side: dark ? BorderSide.none : const BorderSide(color: _line, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 20.spMin,
                height: 20.spMin,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foreground),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  10.wSizedBox,
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAppleButton() {
    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref.watch(
          providerOfAuth.select(
            (state) =>
                state.signInWithAppleState is SignInWithAppleStateLoading,
          ),
        );
        // Apple's guidelines: a dark button with white text and logo.
        return _providerButton(
          label: 'Continue with Apple',
          dark: true,
          isLoading: isLoading,
          onPressed: _signInWithApple,
          icon: SvgPicture.asset(
            'assets/logos/apple.svg',
            width: 18.spMin,
            height: 18.spMin,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoogleButton() {
    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref.watch(
          providerOfAuth.select(
            (state) =>
                state.signInWithGoogleState is SignInWithGoogleStateLoading,
          ),
        );
        return _providerButton(
          label: 'Continue with Google',
          isLoading: isLoading,
          onPressed: _signInWithGoogle,
          icon: SvgPicture.asset(
            'assets/logos/google.svg',
            width: 18.spMin,
            height: 18.spMin,
          ),
        );
      },
    );
  }

  Widget _buildMicrosoftButton() {
    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref.watch(
          providerOfAuth.select(
            (state) =>
                state.signInWithMicrosoftState
                    is SignInWithMicrosoftStateLoading,
          ),
        );
        return _providerButton(
          label: 'Continue with Microsoft',
          isLoading: isLoading,
          onPressed: _signInWithMicrosoft,
          icon: Image.asset(
            'assets/logos/microsoft.png',
            width: 16.spMin,
            height: 16.spMin,
          ),
        );
      },
    );
  }

  Widget _buildTermsAndPrivacySection() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 12.spMin,
          color: _muted,
          fontWeight: FontWeight.w500,
          fontFamily: AppTheme.defaultFontFamily,
        ),
        children: [
          TextSpan(
            text: '${'agree_to_tos_and_privacy_policy'.tr()}\n',
          ),
          WidgetSpan(
            child: GestureDetector(
              onTap: () => _gotoTermsOfService(),
              child: Text(
                'terms_of_service'.tr(),
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          TextSpan(
            text: ' ${'and'.tr()} ',
          ),
          WidgetSpan(
            child: GestureDetector(
              onTap: () => _gotoPrivacyPolicy(),
              child: Text(
                'privacy_policy'.tr(),
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Listens to the auth state changes and navigates to the appropriate screen.
  void _listenToAuthStateChanges() {
    ref.listen<SignInWithGoogleState>(
      providerOfAuth.select(
        (value) => value.signInWithGoogleState,
      ),
      (previous, next) {
        next.maybeWhen(
          success: _gotoWrapper,
          error: _handleError,
          orElse: () {},
        );
      },
    );

    ref.listen<SignInWithAppleState>(
      providerOfAuth.select(
        (value) => value.signInWithAppleState,
      ),
      (previous, next) {
        next.maybeWhen(
          success: _gotoWrapper,
          error: _handleError,
          orElse: () {},
        );
      },
    );

    ref.listen<SignInWithMicrosoftState>(
      providerOfAuth.select(
        (value) => value.signInWithMicrosoftState,
      ),
      (previous, next) {
        next.maybeWhen(
          success: _gotoWrapper,
          error: _handleError,
          orElse: () {},
        );
      },
    );
  }

  /// Handles errors by showing an error toast.
  void _handleError(final AppError error) {
    context.showErrorToast(message: error.message);
  }

  /// Signs in the user with Google.
  void _signInWithGoogle() {
    ref.read(providerOfAuth.notifier).signInWithGoogle();
  }

  /// Signs in the user with Apple.
  void _signInWithApple() {
    ref.read(providerOfAuth.notifier).signInWithApple();
  }

  /// Signs in the user with Microsoft.
  void _signInWithMicrosoft() {
    ref.read(providerOfAuth.notifier).signInWithMicrosoft();
  }

  /// Navigates to the app wrapper screen.
  void _gotoWrapper() {
    context.go(AppWrapper.route);
  }

  /// Navigates to the terms of service page.
  void _gotoTermsOfService() {
    openLink(
      context: context,
      link: AppLinks.termsOfUse,
    );
  }

  /// Navigates to the privacy policy page.
  void _gotoPrivacyPolicy() {
    openLink(
      context: context,
      link: AppLinks.privacyPolicy,
    );
  }
}
