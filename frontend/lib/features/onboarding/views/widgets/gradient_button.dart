import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/onboarding/providers/onboarding_provider.dart';
import 'package:hazard_app/features/onboarding/providers/states/onboarding_provider_state.dart';
import 'package:hazard_app/features/shared/views/widgets/spinner.dart';
import 'package:hazard_app/others/app_colors.dart';

class GradientButton extends ConsumerStatefulWidget {
  const GradientButton({
    super.key,
    required this.title,
    this.icon,
    this.onPressed,
  });

  final String title;

  final Widget? icon;

  final void Function()? onPressed;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GradientButtonState();
}

class _GradientButtonState extends ConsumerState<GradientButton> {
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      providerOfOnboarding.select(
        (value) => value.continueOnboarding.maybeWhen(
          loading: () => true,
          orElse: () => false,
        ),
      ),
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.orange500,
            AppColors.red500,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(100.spMin),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 15.spMin,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(100.spMin),
          onTap: widget.onPressed,
          child: SizedBox(
            height: 54.spMin,
            child: isLoading
                ? Spinner(
                    color: AppColors.white,
                    size: 20.spMin,
                    strokeWidth: 2.0,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 16.spMin,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                      if (widget.icon != null) ...[
                        SizedBox(width: 5.spMin),
                        widget.icon!,
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
