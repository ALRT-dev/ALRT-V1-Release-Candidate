import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/auth/providers/auth_provider.dart';
import 'package:hazard_app/features/auth/providers/states/auth_provider_state.dart';
import 'package:hazard_app/features/auth/views/screens/email_auth_screen.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/utils/app_links.dart';
import 'package:hazard_app/features/shared/utils/open_link.dart';
import 'package:hazard_app/features/shared/views/widgets/button.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/others/app_theme.dart';
import 'package:hazard_app/others/app_wrapper.dart';

class AuthScreen extends ConsumerStatefulWidget {
  /// The authentication screen where users can sign in or sign up.
  const AuthScreen({super.key});

  static const route = '/auth';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  String _selectedRole = 'Community'; // default role
  late final AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // register this provider to the lifecycle of this screen
    ref.watch(providerOfAuth.select((value) => null));

    _listenToAuthStateChanges();

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          // _buildAnimatedBlobs(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF1F5F9),
            Color(0xFFFFF1E7),
            Color(0xFFFFEBEB),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildAnimatedBlobs() {
    return AnimatedBuilder(
      animation: _backgroundAnimationController,
      builder: (context, _) {
        final animationValue = _backgroundAnimationController.value;
        return Stack(
          children: [
            _BlobWidget(
              alignment: Alignment.topLeft,
              diameter: 320.spMin,
              color: const Color(0xFFFECACA).withValues(alpha: 0.35),
              offsetX: 40 * math.sin(animationValue * 2 * math.pi),
              offsetY: 24 * math.sin(animationValue * 2 * math.pi),
              scale: 1 + 0.08 * (1 + math.sin(animationValue * 2 * math.pi)),
            ),
            _BlobWidget(
              alignment: Alignment.bottomRight,
              diameter: 360.spMin,
              color: const Color(0xFFFDE68A).withValues(alpha: 0.35),
              offsetX: -36 * math.sin(animationValue * 2 * math.pi * 0.8),
              offsetY: -22 * math.sin(animationValue * 2 * math.pi * 0.8),
              scale:
                  1 + 0.12 * (1 + math.sin(animationValue * 2 * math.pi * 0.8)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent() {
    return SafeArea(
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
                    28.hSizedBox,
                    // _buildRoleSelector(),
                    // 24.hSizedBox,
                    _buildAuthButtons(),
                    // 18.hSizedBox,
                    // _buildDivider(),
                    // 12.hSizedBox,
                    // _buildGuestOption(),
                    28.hSizedBox,
                    _buildTermsAndPrivacySection(),
                  ],
                ).pX(24.0),
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

  // ignore: unused_element
  Widget _buildRoleSelector() {
    return Wrap(
      spacing: 10.spMin,
      runSpacing: 10.spMin,
      alignment: WrapAlignment.center,
      children: [
        _RoleChipWidget(
          label: 'Community',
          icon: Icons.groups_2_rounded,
          isSelected: _selectedRole == 'Community',
          onTap: () => setState(() => _selectedRole = 'Community'),
        ),
        _RoleChipWidget(
          label: 'Agency',
          icon: Icons.shield_outlined,
          isSelected: _selectedRole == 'Agency',
          onTap: () => setState(() => _selectedRole = 'Agency'),
        ),
        _RoleChipWidget(
          label: 'Partner',
          icon: Icons.handshake_outlined,
          isSelected: _selectedRole == 'Partner',
          onTap: () => setState(() => _selectedRole = 'Partner'),
        ),
      ],
    );
  }

  Widget _buildAuthButtons() {
    return Column(
      children: [
        _buildEmailButton(),
        12.hSizedBox,
        Row(
          spacing: 12.spMin,
          children: [
            Platform.isIOS
                ? Expanded(child: _buildAppleButton())
                // : Expanded(child: _buildMicrosoftButton()),
                : SizedBox.shrink(),
            Expanded(child: _buildGoogleButton()),
          ],
        ),
        // 12.hSizedBox,
        // if (Platform.isIOS) _buildMicrosoftButton(),
      ],
    );
  }

  Widget _buildEmailButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(
            vertical: 14.spMin,
            horizontal: 16.spMin,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 2,
        ),
        onPressed: () => _handleEmailAuth(),
        icon: Icon(Icons.mail_outline, size: 20.spMin),
        label: Text(
          'Continue with Email',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16.spMin,
          ),
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

        // Apple's guidelines: Use black background with white text and logo
        return SizedBox(
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
                        'Apple',
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
            value: 'Google',
          ),
        );
      },
    );
  }

  // ignore: unused_element
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
            value: 'Microsoft',
          ),
        );
      },
    );
  }

  // ignore: unused_element
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.spMin,
            color: AppColors.lightGrey,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.spMin),
          child: Text(
            'or',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 14.spMin,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1.spMin,
            color: AppColors.lightGrey,
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildGuestOption() {
    return TextButton(
      onPressed: () => _handleGuestMode(),
      child: Text(
        'Continue as Guest',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 16.spMin,
          fontWeight: FontWeight.w500,
        ),
      ),
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

  /// Handles email authentication flow.
  void _handleEmailAuth() {
    context.push(EmailAuthScreen.route);
  }

  /// Signs in the user with Apple.
  void _signInWithApple() {
    ref.read(providerOfAuth.notifier).signInWithApple();
  }

  /// Signs in the user with Microsoft.
  void _signInWithMicrosoft() {
    ref.read(providerOfAuth.notifier).signInWithMicrosoft();
  }

  /// Handles guest mode flow.
  void _handleGuestMode() {
    context.showErrorToast(message: 'Continue as guest ($_selectedRole)');
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

/// A widget representing a role selection chip.
class _RoleChipWidget extends StatelessWidget {
  const _RoleChipWidget({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999.r),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: 16.spMin,
          vertical: 10.spMin,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.white,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGrey,
            width: 1.2.spMin,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 10.spMin,
                    offset: Offset(0, 4.spMin),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18.spMin,
              color: isSelected ? AppColors.primary : AppColors.grey,
            ),
            8.wSizedBox,
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.black,
                fontSize: 16.spMin,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget representing an animated background blob.
class _BlobWidget extends StatelessWidget {
  const _BlobWidget({
    required this.alignment,
    required this.diameter,
    required this.offsetX,
    required this.offsetY,
    required this.scale,
    required this.color,
  });

  final Alignment alignment;
  final double diameter;
  final double offsetX;
  final double offsetY;
  final double scale;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: Offset(offsetX, offsetY),
        child: Transform.scale(
          scale: scale,
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
