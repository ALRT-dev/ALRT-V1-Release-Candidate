import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/others/app_colors.dart';

class BaseBottomsheet extends ConsumerStatefulWidget {
  const BaseBottomsheet({
    super.key,
    required this.child,
    this.safeAreaBottom = true,
    this.borderRadius,
    this.backgroundColor = AppColors.white,
    this.canPop,
    this.onPopInvokedWithResult,
    this.onPressedOutside,
    this.useViewInsetsPadding = true,
  });

  final Widget child;

  final bool safeAreaBottom;

  final BorderRadius? borderRadius;

  final Color backgroundColor;

  final bool useViewInsetsPadding;

  final bool Function(WidgetRef)? canPop;

  final void Function(bool, dynamic)? onPopInvokedWithResult;

  final void Function()? onPressedOutside;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BaseBottomsheetState();
}

class _BaseBottomsheetState extends ConsumerState<BaseBottomsheet> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final canPop = widget.canPop?.call(ref) ?? true;
        return PopScope(
          canPop: canPop,
          onPopInvokedWithResult: widget.onPopInvokedWithResult,
          child: GestureDetector(
            onTap: canPop ? (widget.onPressedOutside ?? context.pop) : null,
            behavior: HitTestBehavior.opaque,
            child: child!,
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {},
            child: Material(
              shape: RoundedRectangleBorder(
                borderRadius: widget.borderRadius ??
                    BorderRadiusGeometry.only(
                      topLeft: Radius.circular(20.spMin),
                      topRight: Radius.circular(20.spMin),
                    ),
              ),
              color: widget.backgroundColor,
              child: SafeArea(
                top: false,
                bottom: widget.safeAreaBottom,
                child: widget.useViewInsetsPadding
                    ? Padding(
                        padding: MediaQuery.viewInsetsOf(context),
                        child: widget.child,
                      )
                    : widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
