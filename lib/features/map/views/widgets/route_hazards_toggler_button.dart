import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/others/app_colors.dart';

class RouteHazardsTogglerButton extends ConsumerStatefulWidget {
  const RouteHazardsTogglerButton({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RouteHazardsTogglerButtonState();
}

class _RouteHazardsTogglerButtonState
    extends ConsumerState<RouteHazardsTogglerButton> {
  @override
  Widget build(BuildContext context) {
    final showRouteHazards = ref.watch(
      providerOfMap.select((state) => state.showRouteHazards),
    );

    return Material(
      elevation: 3.0,
      shape: CircleBorder(),
      child: Container(
        width: 50.spMin,
        height: 50.spMin,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            showRouteHazards ? Icons.route_rounded : Icons.route_outlined,
            color: showRouteHazards ? AppColors.blue : AppColors.black,
          ),
          onPressed: _handleTap,
        ),
      ),
    );
  }

  /// Handles tap on the route hazards toggler button.
  void _handleTap() {
    ref.read(providerOfMap.notifier)
      ..toggleShowRouteHazards()
      ..generateMarkers();
  }
}
