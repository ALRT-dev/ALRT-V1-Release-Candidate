import 'package:flutter/cupertino.dart';
import 'package:hazard_app/features/map/views/widgets/map_hazards_list_bottomsheet_content.dart';

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
