import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/views/widgets/base_bottomsheet.dart';
import 'package:hazard_app/features/shared/views/widgets/button.dart';
import 'package:hazard_app/others/app_colors.dart';

class ConfirmationSheetContent extends ConsumerStatefulWidget {
  const ConfirmationSheetContent({
    super.key,
    required this.title,
    this.description,
    this.cancelButtonText,
    this.confirmButtonText,
    this.onPressedConfirm,
    this.onPressedConfirmAsync,
    this.onPressedCancel,
    this.popOnActionButtonsPressed = true,
  });

  final String title;

  final String? description;

  final String? cancelButtonText;

  final String? confirmButtonText;

  final Function(BuildContext, WidgetRef)? onPressedConfirm;

  final Future Function(BuildContext, WidgetRef)? onPressedConfirmAsync;

  final Function(BuildContext, WidgetRef)? onPressedCancel;

  final bool popOnActionButtonsPressed;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConfirmationSheetContentState();
}

class _ConfirmationSheetContentState
    extends ConsumerState<ConfirmationSheetContent> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return BaseBottomsheet(
      canPop: (p0) => !_isLoading,
      child: Column(
        spacing: 10.spMin,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10.spMin,
            children: [
              _titleBuilder(),
              if (widget.description?.isNotEmpty ?? false)
                _descriptionBuilder(),
            ],
          ).pB(5.0),
          _actionButtonsBuilder(),
        ],
      ).pad(20.0),
    );
  }

  Widget _titleBuilder() {
    return Text(
      widget.title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20.spMin,
      ),
    );
  }

  Widget _descriptionBuilder() {
    return Text(
      widget.description!,
      style: TextStyle(
        fontSize: 16.spMin,
      ),
    );
  }

  Widget _actionButtonsBuilder() {
    return Row(
      spacing: 10.spMin,
      children: [
        Expanded(
          child: Button.filled(
            value: widget.cancelButtonText ?? 'Cancel',
            padding: EdgeInsets.all(12.spMin),
            color: AppColors.extraLightGrey,
            valueStyle: TextStyle(
              color: AppColors.black,
            ),
            onPressed: _isLoading ? null : _onPressedCancel,
          ),
        ),
        Expanded(
          child: Button.filled(
            value: widget.confirmButtonText ?? 'Confirm',
            padding: EdgeInsets.all(12.spMin),
            isLoading: _isLoading,
            onPressed: _onPressedConfirm,
          ),
        ),
      ],
    );
  }

  void _onPressedCancel() {
    widget.onPressedCancel?.call(context, ref);
    if (widget.popOnActionButtonsPressed) context.pop();
  }

  void _onPressedConfirm() async {
    if (widget.onPressedConfirmAsync != null) {
      setState(() {
        _isLoading = true;
      });

      await widget.onPressedConfirmAsync!(context, ref);
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } else {
      widget.onPressedConfirm?.call(context, ref);
    }

    if (widget.popOnActionButtonsPressed) context.pop();
  }
}
