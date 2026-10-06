import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/auth/providers/forgot_password_provider.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

/// "Forgot password?" - enter an email, backend sends a reset link if an
/// account exists. Setting the new password itself happens on a web page
/// linked from that email, not in the app - so this screen's job ends the
/// moment the request is sent.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const route = '/forgot-password';

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref
        .read(providerOfForgotPassword.notifier)
        .submit(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ForgotPasswordState>(providerOfForgotPassword, (
      previous,
      next,
    ) {
      if (next.error != null && previous?.error != next.error) {
        context.showErrorToast(message: next.error!.message);
      }
    });

    final state = ref.watch(providerOfForgotPassword);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.spMin),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 480.w),
              child: state.submitted
                  ? _submittedBuilder()
                  : _formBuilder(state.isLoading),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formBuilder(final bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reset your password',
            style: TextStyle(fontSize: 24.spMin, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6.spMin),
          Text(
            "Enter your account's email and we'll send you a link to reset your password.",
            style: TextStyle(fontSize: 14.spMin, color: AppColors.grey),
          ),
          SizedBox(height: 24.spMin),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline, size: 20.spMin),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.spMin,
                vertical: 16.spMin,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: AppColors.lightGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: AppColors.lightGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Enter your email';
              if (!v.contains('@') || !v.contains('.')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 24.spMin),
          SizedBox(
            height: 52.spMin,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 22.spMin,
                      height: 22.spMin,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Send reset link',
                      style: TextStyle(
                        fontSize: 16.spMin,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submittedBuilder() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.mark_email_read_outlined, size: 48.spMin, color: AppColors.primary),
        SizedBox(height: 16.spMin),
        Text(
          'Check your email',
          style: TextStyle(fontSize: 22.spMin, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 8.spMin),
        Text(
          "If an account exists for that email, we've sent a link to reset "
          "your password. It expires in an hour.",
          style: TextStyle(fontSize: 14.spMin, color: AppColors.grey, height: 1.5),
        ),
        SizedBox(height: 24.spMin),
        SizedBox(
          height: 52.spMin,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            child: Text(
              'Back to sign in',
              style: TextStyle(fontSize: 15.spMin, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
