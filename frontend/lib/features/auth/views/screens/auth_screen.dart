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
import 'package:hazard_app/features/shared/views/widgets/button.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/others/env.dart';
import 'package:hazard_app/others/app_theme.dart';
import 'package:hazard_app/others/app_wrapper.dart';

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

  @override
  Widget build(BuildContext context) {
    // register this provider to the lifecycle of this screen
    ref.watch(providerOfAuth.select((value) => null));

    _listenToAuthStateChanges();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        // Centred while it fits, scrollable the moment it doesn't. A bare
        // Center clips instead of scrolling, which on a short phone hid the
        // terms line under the bottom edge with no way to reach it.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 520.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBrandSection(),
                      32.hSizedBox,
                      if (_showSignIn) ...[
                        _buildAuthButtons(),
                      ] else ...[
                        _buildWelcomeActions(),
                      ],
                      28.hSizedBox,
                      _buildTermsAndPrivacySection(),
                    ],
                  ).pX(24.0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandSection() {
    return Column(
      children: [
        Hero(
          tag: 'app_logo',
          child: Image.asset(
            'assets/logos/alrt_logo_detailed.png',
            width: 300.spMin,
          ),
        ),
        Text(
          'Welcome to ALRT',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        8.hSizedBox,
        Text(
          'Fast, plain-language safety alerts.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.grey,
            fontSize: 16.spMin,
          ),
        ),
      ],
    );
  }

  /// The initial welcome view with Get Started and I already have an account.
  Widget _buildWelcomeActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50.spMin,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(vertical: 14.spMin),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 0,
            ),
            onPressed: () => setState(() => _showSignIn = true),
            child: Text(
              'Get Started',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.spMin,
              ),
            ),
          ),
        ),
        12.hSizedBox,
        TextButton(
          onPressed: () => setState(() => _showSignIn = true),
          child: Text(
            'I already have an account',
            style: TextStyle(
              color: AppColors.darkGrey,
              fontSize: 15.spMin,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Apple, Google and Microsoft sign-in buttons.
  Widget _buildAuthButtons() {
    return Column(
      children: [
        Text(
          'Sign in to continue',
          style: TextStyle(
            color: AppColors.darkGrey,
            fontSize: 16.spMin,
            fontWeight: FontWeight.w600,
          ),
        ),
        20.hSizedBox,
        if (Platform.isIOS) ...[
          _buildAppleButton(),
          12.hSizedBox,
        ],
        // Only offer Google when this build has its Google settings. Test
        // builds leave them blank on purpose, and tapping Google there
        // can crash the app on iPhone.
        if (Env.googleAuthServerClientId.isNotEmpty) ...[
          _buildGoogleButton(),
          12.hSizedBox,
        ],
        _buildMicrosoftButton(),
        16.hSizedBox,
        TextButton(
          onPressed: () => setState(() => _showSignIn = false),
          child: Text(
            'Back',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 14.spMin,
            ),
          ),
        ),
      ],
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

        // Apple's guidelines: Use black background with white text and logo
        return SizedBox(
          width: double.infinity,
          height: 50.spMin,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: 12.spMin,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            onPressed: isLoading ? null : _signInWithApple,
            child: isLoading
                ? SizedBox(
                    width: 20.spMin,
                    height: 20.spMin,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/logos/apple.svg',
                        width: 18.spMin,
                        height: 18.spMin,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      8.wSizedBox,
                      Text(
                        'Continue with Apple',
                        style: TextStyle(
                          fontSize: 15.spMin,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
        return SizedBox(
          width: double.infinity,
          height: 50.spMin,
          child: Button.bordered(
            onPressed: _signInWithGoogle,
            isLoading: isLoading,
            padding: EdgeInsets.symmetric(
              vertical: 12.spMin,
            ),
            icon: SvgPicture.asset(
              'assets/logos/google.svg',
              width: 20.spMin,
              height: 20.spMin,
            ),
            value: 'Continue with Google',
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
        return SizedBox(
          width: double.infinity,
          height: 50.spMin,
          child: Button.bordered(
            onPressed: _signInWithMicrosoft,
            isLoading: isLoading,
            padding: EdgeInsets.symmetric(
              vertical: 12.spMin,
            ),
            icon: Image.asset(
              'assets/logos/microsoft.png',
              width: 18.spMin,
              height: 18.spMin,
            ),
            value: 'Continue with Microsoft',
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
          fontSize: 14.spMin,
          color: AppColors.grey,
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
