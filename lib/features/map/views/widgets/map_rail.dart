import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/ask_alrt/views/ask_alrt_sheet.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_journey_share_sheet.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/map/providers/map_display_settings_provider.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/views/widgets/around_you_sheet.dart';
import 'package:hazard_app/features/map/views/widgets/map_details_sheet.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The dark floating vertical rail on the map's right edge (V3 map UI).
///
/// Top to bottom: layers (Map details sheet), Ask ALRT, locate (go to my
/// location) and list (Around You sheet).
class MapRail extends ConsumerStatefulWidget {
  const MapRail({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MapRailState();
}

class _MapRailState extends ConsumerState<MapRail> {
  static const _railColor = Color(0xFF23252B);
  static const _layersColor = Color(0xFFFF6B01);
  static const _locateColor = Color(0xFF4A90D9);
  static const _journeyLitColor = FamilyColors.v31Indigo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Translucent so the map still reads behind the rail, with the same
        // purply-blue halo the footer carries.
        color: _railColor.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.footerGlow.withValues(alpha: 0.34),
            blurRadius: 22.0,
            spreadRadius: 1.0,
            offset: const Offset(0, 4),
          ),
          const BoxShadow(
            color: AppColors.shadowColorDark,
            blurRadius: 14.0,
            offset: Offset(0, 4.0),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 6.spMin,
        vertical: 8.spMin,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10.spMin,
        children: [
          _layersButtonBuilder(),
          _askAlrtButtonBuilder(),
          _journeyButtonBuilder(),
          _locateButtonBuilder(),
          _listButtonBuilder(),
        ],
      ),
    );
  }

  Widget _layersButtonBuilder() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _circleButtonBuilder(
          color: _layersColor,
          icon: LucideIcons.layers,
          onPressed: () => showMapDetailsSheet(context: context),
        ),
        Positioned(
          top: -2.spMin,
          right: -2.spMin,
          child: _hiddenSystemsCountBadgeBuilder(),
        ),
      ],
    );
  }

  /// A white-on-red badge with the count of source systems currently
  /// toggled off in the Map details sheet.
  Widget _hiddenSystemsCountBadgeBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final hiddenCount = ref.watch(
          providerOfVisibleAlertSystems.select(
            (value) => AlertSourceSystem.values.length - value.length,
          ),
        );
        if (hiddenCount == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          width: 16.spMin,
          height: 16.spMin,
          decoration: BoxDecoration(
            color: AppColors.red,
            shape: BoxShape.circle,
            border: Border.all(
              color: _railColor,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            hiddenCount.toString(),
            style: TextStyle(
              fontSize: 9.spMin,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              height: 1.0,
            ),
          ),
        );
      },
    );
  }

  Widget _askAlrtButtonBuilder() {
    return _circleButtonBuilder(
      color: AppColors.transparent,
      icon: LucideIcons.sparkles,
      onPressed: () => showAskAlrtSheet(context),
    );
  }

  /// Share a journey from the map, which is where people are when they set
  /// off. Lit while a journey of theirs is running.
  Widget _journeyButtonBuilder() {
    final isSharing = ref.watch(
      providerOfFamily.select((s) {
        final journey = s.activeJourney;
        return journey != null && journey.isActive;
      }),
    );
    return _circleButtonBuilder(
      color: isSharing ? _journeyLitColor : AppColors.transparent,
      icon: isSharing ? LucideIcons.route : LucideIcons.share2,
      onPressed: () => showFamilyJourneyShareSheet(context),
    );
  }

  Widget _locateButtonBuilder() {
    return _circleButtonBuilder(
      color: _locateColor,
      icon: LucideIcons.navigation,
      onPressed: _handleLocateTap,
    );
  }

  Widget _listButtonBuilder() {
    return _circleButtonBuilder(
      color: _layersColor,
      icon: LucideIcons.list,
      onPressed: () => showAroundYouSheet(context: context),
    );
  }

  Widget _circleButtonBuilder({
    required final Color color,
    required final IconData icon,
    required final VoidCallback onPressed,
  }) {
    return Container(
      width: 40.spMin,
      height: 40.spMin,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 10.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 19.spMin,
        color: AppColors.white,
      ),
    ).onPressed(onPressed);
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
