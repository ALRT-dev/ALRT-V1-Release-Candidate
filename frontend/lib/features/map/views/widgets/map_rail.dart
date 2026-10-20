import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/views/screens/check_route_screen.dart';
import 'package:hazard_app/features/map/views/widgets/map_details_sheet.dart';
import 'package:hazard_app/features/map/views/widgets/map_key_sheet.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The white floating rail on the map's right edge (prototype board "Main",
/// approved 9 Oct 2026).
///
/// Exactly five 48 x 48 buttons. Top: one stacked block of three, in the
/// owner's order (12 Oct 2026): Map layers (the Google map type only: Default,
/// Satellite, Terrain), the alerts list (its filter button sits in the top
/// right corner of the list), and the map key. Below it, standalone: locate me, then
/// check a route. Ask ALRT and the voice mic moved into the search bar; the journey
/// share button and the hidden-filters badge were removed.
class MapRail extends ConsumerStatefulWidget {
  const MapRail({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MapRailState();
}

class _MapRailState extends ConsumerState<MapRail> {
  static const _inkColor = Color(0xFF1C1C1E);
  static const _locateColor = Color(0xFF2563EB);
  static const _dividerColor = Color(0xFFECEEF1);

  static double get _buttonSize => 48.spMin;
  static double get _iconSize => 22.spMin;
  static BorderRadius get _radius => BorderRadius.circular(14.spMin);

  static List<BoxShadow> get _shadow => [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.10),
          blurRadius: 16.0,
          offset: const Offset(0, 4),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 10.spMin,
      children: [
        _stackedBlockBuilder(),
        _standaloneButtonBuilder(
          icon: LucideIcons.navigation,
          iconColor: _locateColor,
          semanticLabel: 'Go to my location',
          onPressed: _handleLocateTap,
        ),
        _standaloneButtonBuilder(
          icon: LucideIcons.route,
          iconColor: _inkColor,
          semanticLabel: 'Check a route',
          onPressed: _handleCheckRouteTap,
        ),
      ],
    );
  }

  /// Map layers (map type only), alerts list and map key in one white block with hairline
  /// dividers inset 10 px from each side.
  Widget _stackedBlockBuilder() {
    return Container(
      width: _buttonSize,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: _radius,
        boxShadow: _shadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _railButtonBuilder(
            icon: LucideIcons.layers,
            iconColor: _inkColor,
            semanticLabel: 'Map layers',
            onPressed: () => showMapDetailsSheet(context: context),
          ),
          _dividerBuilder(),
          _railButtonBuilder(
            icon: LucideIcons.list,
            iconColor: _inkColor,
            semanticLabel: 'Alerts',
            onPressed: _handleAlertsTap,
          ),
          _dividerBuilder(),
          _railButtonBuilder(
            icon: LucideIcons.info,
            iconColor: _inkColor,
            semanticLabel: 'Map key',
            onPressed: () => showMapKeySheet(context: context),
          ),
        ],
      ),
    );
  }

  Widget _dividerBuilder() {
    return Container(
      height: 1.0,
      margin: EdgeInsets.symmetric(horizontal: 10.spMin),
      color: _dividerColor,
    );
  }

  Widget _standaloneButtonBuilder({
    required final IconData icon,
    required final Color iconColor,
    required final String semanticLabel,
    required final VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: _radius,
        boxShadow: _shadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: _railButtonBuilder(
        icon: icon,
        iconColor: iconColor,
        semanticLabel: semanticLabel,
        onPressed: onPressed,
      ),
    );
  }

  Widget _railButtonBuilder({
    required final IconData icon,
    required final Color iconColor,
    required final String semanticLabel,
    required final VoidCallback onPressed,
  }) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox(
        width: _buttonSize,
        height: _buttonSize,
        child: Center(
          child: Icon(
            icon,
            size: _iconSize,
            color: iconColor,
          ),
        ),
      ).onPressed(onPressed),
    );
  }

  /// Switches the home shell to the Alerts tab.
  void _handleAlertsTap() {
    ref.read(providerOfHomeTab.notifier).state = HomeTab.notifications;
  }

  /// Check a route: the full Check a route screen (prototype board
  /// "Route"); pick where you are going there, then check the routes.
  Future<void> _handleCheckRouteTap() async {
    await CheckRouteScreen.open(context);
  }

  /// Animates the map to the user's current location (same behaviour as the
  /// old my-location button).
  void _handleLocateTap() {
    final location = ref.read(providerOfLocation).location;
    ref
        .read(providerOfMap.notifier)
        .animateTo(position: location.latLng, zoom: 14.0);
  }
}
