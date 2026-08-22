import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

class RoundButton extends ConsumerStatefulWidget {
  // Displays a reusable button that has a rounded style.
  const RoundButton({
    super.key,
    required this.icon,
    this.size = 35.0,
    this.backgroundColor,
    this.splashColor,
    this.borderSide,
    this.elevation,
    this.useLiquidGlassEffect = false,
    this.onPressed,
  });

  /// The icon to be shown on the button.
  final Widget icon;

  /// The size of the button.
  final double size;

  /// The border side of the button.
  final BorderSide? borderSide;

  /// The background color of the button.
  final Color? backgroundColor;

  /// The splash color of the button.
  final Color? splashColor;

  /// The elevation of the button.
  final double? elevation;

  /// Whether to use the liquid glass effect or not.
  final bool useLiquidGlassEffect;

  /// The function to be called when the button is pressed.
  final void Function()? onPressed;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RoundButtonState();
}

class _RoundButtonState extends ConsumerState<RoundButton> {
  @override
  Widget build(BuildContext context) {
    if (widget.useLiquidGlassEffect) {
      return Container(
        width: widget.size.spMin,
        height: widget.size.spMin,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.backgroundColor,
          border: widget.borderSide == null
              ? Border.all(
                  color: AppColors.white,
                  width: 0.2,
                )
              : Border.all(
                  width: widget.borderSide!.width,
                  color: widget.borderSide!.color,
                ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100.0),
          child: BackdropFilter(
            enabled: false,
            filter: ImageFilter.blur(
              sigmaX: 3.0,
              sigmaY: 3.0,
            ),
            child: Center(
              child: widget.icon,
            ),
          ),
        ),
      ).onPressed(widget.onPressed);
    }
    return SizedBox(
      width: widget.size.spMin,
      height: widget.size.spMin,
      child: FloatingActionButton(
        heroTag: null,
        elevation: widget.elevation,
        backgroundColor: widget.backgroundColor,
        splashColor: AppColors.transparent,
        shape: CircleBorder(
          side: widget.borderSide ?? BorderSide.none,
        ),
        onPressed: widget.onPressed,
        child: Center(
          child: widget.icon,
        ),
      ),
    );
  }
}
