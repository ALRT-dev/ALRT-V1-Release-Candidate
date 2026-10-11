import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/onboarding/providers/onboarding_provider.dart';
import 'package:hazard_app/features/onboarding/providers/states/onboarding_provider_state.dart';
import 'package:hazard_app/features/shared/views/widgets/spinner.dart';
import 'package:hazard_app/others/app_colors.dart';

/// The brand gradient the onboarding boards use for their primary CTA.
const kOnboardingBrandGradient = LinearGradient(
  colors: [Color(0xFFFF6B00), Color(0xFFFF0004)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

/// The onboarding CTA: 54 px, radius 16, brand gradient (or solid ink when
/// [dark] is set). A null [onPressed] renders it flat grey and inert.
/// Shows a spinner while the onboarding provider is mid-request.
class GradientButton extends ConsumerStatefulWidget {
  const GradientButton({
    super.key,
    required this.title,
    this.icon,
    this.onPressed,
    this.dark = false,
  });

  final String title;

  final Widget? icon;

  final void Function()? onPressed;

  /// Solid #1C1C1E instead of the gradient (the "Continue with ALRT Free"
  /// button on the ALRT + step).
  final bool dark;

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
    // Inert (nothing to do yet) is flat grey; a request in flight keeps
    // the live colour and shows the spinner instead.
    final inert = widget.onPressed == null;
    final radius = BorderRadius.circular(16.spMin);
    final foreground = inert ? AppColors.mediumGrey : AppColors.white;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: !inert && !widget.dark ? kOnboardingBrandGradient : null,
        color: inert
            ? AppColors.lightGrey
            : widget.dark
            ? AppColors.ink
            : null,
        borderRadius: radius,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: inert || isLoading ? null : widget.onPressed,
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
                      Flexible(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 16.spMin,
                            fontWeight: FontWeight.w600,
                            color: foreground,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.icon != null) ...[
                        SizedBox(width: 6.spMin),
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
