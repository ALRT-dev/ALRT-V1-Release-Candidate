import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/others/app_colors.dart';

class BaseBottomsheetV2 extends ConsumerStatefulWidget {
  const BaseBottomsheetV2({
    super.key,
    this.initialChildSize = 0.5,
    this.minChildSize = 0.3,
    this.maxChildSize = 0.9,
    required this.builder,
    this.safeAreaBottom = true,
    this.borderRadius,
    this.backgroundColor = AppColors.white,
    this.canPop,
    this.onPopInvokedWithResult,
    this.onPressedOutside,
    this.useViewInsetsPadding = true,
  });

  final double initialChildSize;

  final double minChildSize;

  final double maxChildSize;

  final Widget Function(BuildContext context, ScrollController scrollController)
  builder;

  final bool safeAreaBottom;

  final BorderRadius? borderRadius;

  final Color backgroundColor;

  final bool useViewInsetsPadding;

  final bool Function(WidgetRef)? canPop;

  final void Function(bool, dynamic)? onPopInvokedWithResult;

  final void Function()? onPressedOutside;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BaseBottomsheetV2State();
}

class _BaseBottomsheetV2State extends ConsumerState<BaseBottomsheetV2> {
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
      child: DraggableScrollableSheet(
        initialChildSize: widget.initialChildSize,
        minChildSize: widget.minChildSize,
        maxChildSize: widget.maxChildSize,
        builder: (context, scrollController) {
          return GestureDetector(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28.spMin),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      widget.borderRadius ??
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
                          child: widget.builder(context, scrollController),
                        )
                      : widget.builder(context, scrollController),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
