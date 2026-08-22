import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hazard_app/features/auth/providers/auth_provider.dart';
import 'package:hazard_app/features/auth/views/widgets/google_sign_in_web/google_sign_in_web_wrapper.dart';
import 'package:hazard_app/features/shared/views/widgets/button.dart';
import 'package:hazard_app/features/shared/views/widgets/spinner.dart';
import 'package:hazard_app/others/app_colors.dart';

class GoogleSignInButton extends ConsumerStatefulWidget {
  const GoogleSignInButton({
    super.key,
    required this.isLoading,
    this.onPressed,
  });

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  ConsumerState<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends ConsumerState<GoogleSignInButton> {
  late final GoogleSignIn _googleSignIn;

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn.instance;

    if (kIsWeb) {
      _setupWebAuthListener();
    }
  }

  void _setupWebAuthListener() {
    // Listen to authentication events for web
    _googleSignIn.authenticationEvents.listen((event) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        // User signed in successfully, trigger the auth provider
        ref
            .read(providerOfAuth.notifier)
            .handleWebSignIn(googleUser: event.user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && !_googleSignIn.supportsAuthenticate()) {
      // On web, use renderButton instead of custom UI
      return renderButton();
    } else {
      // On mobile platforms, use custom button
      return Button.filled(
        value: 'Continue with Google',
        valueStyle: TextStyle(
          color: AppColors.black,
        ),
        icon: SvgPicture.asset(
          'assets/logos/google.svg',
          width: 20.spMin,
          height: 20.spMin,
        ),
        color: AppColors.extraLightGrey,
        loader: Spinner(
          size: 15.spMin,
          color: AppColors.black,
        ),
        onPressed: widget.onPressed,
        isLoading: widget.isLoading,
      );
    }
  }
}
