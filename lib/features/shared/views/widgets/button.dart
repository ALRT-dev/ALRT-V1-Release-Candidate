import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/views/widgets/spinner.dart';
import 'package:hazard_app/others/app_colors.dart';

enum _Type {
  filled,
  bordered,
  gradient,
}

class Button extends StatelessWidget {
  /// A customizable button widget that is filled.
  const Button.filled({
    super.key,
    this.value,
    this.valueStyle,
    this.color,
    this.splashColor,
    this.icon,
    this.isIconLeft = true,
    this.iconAndTextSpacing = 10.0,
    this.width,
    this.borderRadius,
    this.padding,
    this.elevation = 0.0,
    this.isLoading = false,
    this.loader,
    this.onPressed,
  }) : _type = _Type.filled,
       borderSide = null,
       gradient = null;

  /// A customizable button widget that is bordered.
  const Button.bordered({
    super.key,
    this.value,
    this.valueStyle,
    this.borderSide,
    this.splashColor,
    this.icon,
    this.isIconLeft = true,
    this.iconAndTextSpacing = 10.0,
    this.width,
    this.borderRadius,
    this.padding,
    this.elevation = 0.0,
    this.isLoading = false,
    this.loader,
    this.onPressed,
  }) : _type = _Type.bordered,
       color = null,
       gradient = null;

  /// A customizable button widget with a gradient background.
  const Button.gradient({
    super.key,
    this.value,
    this.valueStyle,
    this.gradient,
    this.splashColor,
    this.icon,
    this.isIconLeft = true,
    this.iconAndTextSpacing = 10.0,
    this.width,
    this.borderRadius,
    this.padding,
    this.elevation = 0.0,
    this.isLoading = false,
    this.loader,
    this.onPressed,
  }) : _type = _Type.gradient,
       color = null,
       borderSide = null;

  /// The type of the button.
  final _Type _type;

  /// The text to display on the button.
  final String? value;

  /// The style of the text to display on the button.
  final TextStyle? valueStyle;

  /// The color of the button.
  final Color? color;

  /// The color of the splash effect when the button is pressed.
  final Color? splashColor;

  /// The border side of the button.
  final BorderSide? borderSide;

  /// The gradient of the button.
  ///
  /// Only used when the button type is [Button.gradient].
  /// Defaults to orange to red200 when null.
  final Gradient? gradient;

  /// The icon to display on the button alongside the text.
  final Widget? icon;

  /// Whether the icon should be displayed on the left side of the text.
  ///
  /// This is only applicable when [icon] is not null.
  final bool isIconLeft;

  /// The spacing between the icon and the text.
  final double iconAndTextSpacing;

  /// The width of the button.
  final double? width;

  /// The border radius of the button.
  final double? borderRadius;

  /// The padding of the button content.
  final EdgeInsets? padding;

  /// The elevation of the button.
  final double elevation;

  /// Whether the button is in a loading state.
  ///
  /// When true, the button will display a loader.
  final bool isLoading;

  /// The loader to display when the button is in a loading state.
  ///
  /// This is only applicable when [isLoading] is true.
  final Widget? loader;

  /// The function to call when the button is pressed.
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    switch (_type) {
      case _Type.filled:
        return _filledBuilder(context);
      case _Type.bordered:
        return _borderedBuilder(context);
      case _Type.gradient:
        return _gradientBuilder(context);
    }
  }

  /// Resolves border radius: explicit [borderRadius] or theme's ElevatedButton default.
  BorderRadius _effectiveBorderRadius(BuildContext context) {
    if (borderRadius != null) {
      return BorderRadius.circular(borderRadius!.r);
    }
    final themeStyle = Theme.of(context).elevatedButtonTheme.style;
    final resolvedShape = themeStyle?.shape?.resolve(
      const <WidgetState>{WidgetState.pressed},
    );
    if (resolvedShape is RoundedRectangleBorder) {
      final r = resolvedShape.borderRadius;
      return r is BorderRadius ? r : BorderRadius.zero;
    }
    if (resolvedShape is StadiumBorder) {
      return BorderRadius.circular(24);
    }
    return BorderRadius.zero;
  }

  Widget _filledBuilder(final BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: _effectiveBorderRadius(context),
    );
    final elevatedButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: color,
      shape: shape,
      elevation: elevation,
      padding: padding,
    );

    return SizedBox(
      width: width?.spMin,
      child: ElevatedButton(
        onPressed: onPressed,
        style: elevatedButtonStyle,
        child: _buttonChild(),
      ),
    );
  }

  Widget _gradientBuilder(final BuildContext context) {
    final effectiveGradient =
        gradient ??
        LinearGradient(
          colors: [
            AppColors.orange300,
            AppColors.red200,
          ],
        );

    // Use same border radius as ElevatedButton: explicit borderRadius or theme default.
    final effectiveBorderRadius = _effectiveBorderRadius(context);
    final shape = RoundedRectangleBorder(borderRadius: effectiveBorderRadius);

    // ElevatedButton style: transparent background so gradient shows through,
    // inherit theme splash/overlay/focus; same shape & padding as filled.
    final elevatedButtonStyle =
        ElevatedButton.styleFrom(
          backgroundColor: AppColors.transparent,
          shadowColor: AppColors.transparent,
          surfaceTintColor: AppColors.transparent,
          elevation: 0,
          foregroundColor: valueStyle?.color ?? AppColors.white,
          shape: shape,
          padding: padding,
        ).copyWith(
          overlayColor: splashColor != null
              ? WidgetStateProperty.all(splashColor)
              : null,
        );

    return SizedBox(
      width: width?.spMin,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: effectiveBorderRadius,
              child: Container(
                decoration: BoxDecoration(
                  gradient: effectiveGradient,
                  borderRadius: effectiveBorderRadius,
                  boxShadow: elevation > 0
                      ? [
                          BoxShadow(
                            color: AppColors.shadowColor,
                            blurRadius: elevation,
                            offset: Offset(0, elevation / 2),
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: elevatedButtonStyle,
            child: _buttonChild(),
          ),
        ],
      ),
    );
  }

  /// Shared child row for filled and gradient buttons.
  Widget _buttonChild() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isIconLeft)
          if (icon != null) icon ?? Container(),
        if (isIconLeft)
          if (icon != null && value != null)
            SizedBox(
              width: iconAndTextSpacing.spMin,
            ),
        if (value != null)
          Text(
            '$value',
            style: valueStyle,
          ),
        if (!isIconLeft)
          if (value != null)
            SizedBox(
              width: iconAndTextSpacing.spMin,
            ),
        if (!isIconLeft)
          if (icon != null) icon ?? Container(),
        if (isLoading && value != null && isIconLeft)
          SizedBox(
            width: 20.spMin,
          ),
        if (isLoading && !isIconLeft)
          SizedBox(
            width: 20.spMin,
          ),
        if (isLoading)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              loader ??
                  Spinner(
                    size: 15.spMin,
                    color: AppColors.white,
                  ),
            ],
          ),
      ],
    );
  }

  Widget _borderedBuilder(final BuildContext context) {
    final outlinedButtonStyle = OutlinedButton.styleFrom(
      side: borderSide,
      shape: borderRadius == null
          ? null
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius!.r),
            ),
      elevation: elevation,
      padding: padding,
    );

    return SizedBox(
      width: width?.spMin,
      child: OutlinedButton(
        onPressed: onPressed,
        style: outlinedButtonStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isIconLeft)
              if (icon != null) icon ?? Container(),
            if (isIconLeft)
              if (icon != null && value != null)
                SizedBox(
                  width: 10.spMin,
                ),
            if (value != null)
              Text(
                '$value',
                style: valueStyle,
              ),
            if (!isIconLeft)
              if (value != null)
                SizedBox(
                  width: 10.spMin,
                ),
            if (!isIconLeft)
              if (icon != null) icon ?? Container(),
            if (isLoading && value != null && isIconLeft)
              SizedBox(
                width: 20.spMin,
              ),
            if (isLoading && !isIconLeft)
              SizedBox(
                width: 20.spMin,
              ),
            if (isLoading)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  loader ??
                      Spinner(
                        size: 15.spMin,
                        color: outlinedButtonStyle.side?.resolve(
                          const <WidgetState>{
                            WidgetState.pressed,
                            WidgetState.hovered,
                            WidgetState.focused,
                          },
                        )?.color,
                      ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
