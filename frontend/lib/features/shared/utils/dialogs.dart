import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/notification/views/widgets/change_my_location_subscription_bottomsheet_content.dart';
import 'package:hazard_app/features/shared/models/alrt_media_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/models/location_subscription_model.dart';
import 'package:hazard_app/features/shared/views/widgets/change_location_bottomsheet_content.dart';
import 'package:hazard_app/features/shared/views/widgets/change_radius_bottomsheet_content.dart';
import 'package:hazard_app/features/shared/views/widgets/confirmation_sheet_content.dart';
import 'package:hazard_app/features/shared/views/widgets/filter_widgets/hazard_filters_bottomsheet_content.dart';
import 'package:hazard_app/features/shared/views/widgets/hazards_bottomsheet_content.dart';
import 'package:hazard_app/features/shared/views/widgets/image_picker_bottomsheet.dart';
import 'package:hazard_app/others/app_colors.dart';

/// Displays a custom implementation of [showCupertinoModalPopup].
Future<T?> showCustomCupertinoModalPopup<T>({
  required final BuildContext context,
  required final Widget Function(BuildContext) builder,
  final bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dismiss',
    barrierColor: AppColors.black.withValues(alpha: 0.5),
    transitionDuration: Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutCubic,
      );

      return SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 1),
          end: Offset(0, 0),
        ).animate(curvedAnimation),
        child: child,
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
  );
}

/// Displays a confirmation sheet.
Future<void> showConfirmationSheet({
  required final BuildContext context,
  required final String title,
  final String? description,
  final String? cancelButtonText,
  final String? confirmButtonText,
  final Function(BuildContext, WidgetRef)? onPressedConfirm,
  final Future Function(BuildContext, WidgetRef)? onPressedConfirmAsync,
  final Function(BuildContext, WidgetRef)? onPressedCancel,
  final bool popOnActionButtonsPressed = true,
}) {
  return showCustomCupertinoModalPopup(
    context: context,
    builder: (_) => ConfirmationSheetContent(
      title: title,
      description: description,
      cancelButtonText: cancelButtonText,
      confirmButtonText: confirmButtonText,
      onPressedConfirm: onPressedConfirm,
      onPressedConfirmAsync: onPressedConfirmAsync,
      onPressedCancel: onPressedCancel,
      popOnActionButtonsPressed: popOnActionButtonsPressed,
    ),
  );
}

/// Displays the hazard filters bottom sheet.
Future<void> showHazardFiltersBottomSheet({
  required final BuildContext context,
  required final String filtersKey,
  final void Function()? onFiltersUpdated,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (_) => HazardFiltersBottomsheetContent(
      filtersKey: filtersKey,
      onFiltersUpdated: onFiltersUpdated,
    ),
  );
}

/// Displays the image picker bottom sheet.
Future<List<AlrtMedia>?> showImagePickerBottomSheet({
  required final BuildContext context,
}) {
  return showCustomCupertinoModalPopup<List<AlrtMedia>?>(
    context: context,
    builder: (_) => ImagePickerBottomsheet(),
  );
}

/// Displays the my location options bottom sheet.
Future<void> showChangeMyLocationSubscriptionBottomsheet({
  required final BuildContext context,
  required final LocationSubscription locationSubscription,
}) {
  return showCustomCupertinoModalPopup(
    context: context,
    builder: (_) => ChangeMyLocationSubscriptionBottomsheetContent(
      locationSubscription: locationSubscription,
    ),
  );
}

/// Displays the change location bottom sheet.
Future<void> showChangeLocationBottomsheet({
  required final BuildContext context,
}) {
  return showCustomCupertinoModalPopup(
    context: context,
    builder: (_) => ChangeLocationBottomsheetContent(),
  );
}

/// Displays change radius bottom sheet.
Future<void> showChangeRadiusBottomsheet({
  required final BuildContext context,
  required final int initialRadius,
}) {
  return showCustomCupertinoModalPopup(
    context: context,
    builder: (_) => ChangeRadiusBottomsheetContent(
      initialRadius: initialRadius,
    ),
  );
}

/// Shows a full-screen bottom sheet displaying the list of hazards.
Future<void> showHazardsBottomsheet({
  required final BuildContext context,
  required final List<Hazard> hazards,
}) {
  return showCupertinoModalPopup(
    context: context,
    builder: (context) => HazardsBottomsheetContent(
      hazards: hazards,
    ),
  );
}
