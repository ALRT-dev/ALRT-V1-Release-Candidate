import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/shared/views/widgets/common_hazards_list_item.dart';

class MapHazardPreview extends ConsumerStatefulWidget {
  const MapHazardPreview({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MapHazardPreviewState();
}

class _MapHazardPreviewState extends ConsumerState<MapHazardPreview> {
  @override
  Widget build(BuildContext context) {
    final selectedHazard = ref.watch(
      providerOfMap.select(
        (value) => value.selectedHazard,
      ),
    );

    if (selectedHazard == null) {
      return const SizedBox.shrink();
    }

    return CommonHazardsListItem(
      key: ValueKey(selectedHazard.id),
      hazard: selectedHazard,
      horizontalPadding: 0.0,
      showCloseButton: true,
      onClosePressed: _handleClosePressed,
      isInfoWindow: true,
    );
  }

  /// Handles the close button press event.
  void _handleClosePressed() {
    ref.read(providerOfMap.notifier).updateSelectedHazard(null);
  }
}
