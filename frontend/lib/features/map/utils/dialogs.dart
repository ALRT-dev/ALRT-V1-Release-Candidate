import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hazard_app/features/map/views/widgets/map_hazards_list_bottomsheet_content.dart';
import 'package:hazard_app/features/map/views/widgets/alrt_keys_bottomsheet_content.dart';
import 'package:hazard_app/others/app_colors.dart';

/// Shows a full-screen bottom sheet displaying the list of map hazards.
Future<void> showMapHazardsListBottomSheet({
  required final BuildContext context,
  bool showOnlyRouteHazards = false,
}) {
  return showCupertinoModalPopup(
    context: context,
    builder: (context) => MapHazardsListBottomsheetContent(
      showOnlyRouteHazards: showOnlyRouteHazards,
    ),
  );
}

/// Shows a bottom sheet displaying the alrt keys.
Future<void> showAlrtKeysBottomSheet({
  required final BuildContext context,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (context) => AlrtKeysBottomsheetContent(),
  );
}
