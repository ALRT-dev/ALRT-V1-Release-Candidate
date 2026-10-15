import 'package:flutter/material.dart';
import 'package:hazard_app/features/map/providers/map_display_settings_provider.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/shared/providers/hazard_filters_provider.dart';
import 'package:hazard_app/features/shared/views/widgets/filter_widgets/show_choice.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shows the map type bottom sheet (owner, 12 Oct 2026): the layers button
/// on the map's right-hand stack picks the Google map type only (Default,
/// Satellite, Terrain). Filters live behind the Alerts list's filter button
/// and the key has its own button.
/// Opens at about three-quarters of the screen so the map stays visible
/// above it (product decision 2026-09-09); the content scrolls inside the
/// sheet and Done stays pinned above the navigation bar.
Future<void> showMapDetailsSheet({
  required final BuildContext context,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.transparent,
    barrierColor: AppColors.black.withValues(alpha: 0.35),
    builder: (context) => const MapDetailsSheet(),
  );
}

/// How much of the screen the sheet takes when it opens, and its bounds.
const kMapDetailsSheetInitialSize = 0.52;
const kMapDetailsSheetMinSize = 0.4;
const kMapDetailsSheetMaxSize = 0.7;

class MapDetailsSheet extends ConsumerStatefulWidget {
  const MapDetailsSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MapDetailsSheetState();
}

class _MapDetailsSheetState extends ConsumerState<MapDetailsSheet> {
  static const _sheetColor = Color(0xFFF7F5FA);
  static const _tileColor = Color(0xFFFFFFFF);
  static const _accentColor = Color(0xFFFF6B01);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: kMapDetailsSheetInitialSize,
      minChildSize: kMapDetailsSheetMinSize,
      maxChildSize: kMapDetailsSheetMaxSize,
      expand: false,
      builder: (context, scrollController) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _sheetColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.spMin),
            topRight: Radius.circular(24.spMin),
          ),
        ),
        padding: EdgeInsets.fromLTRB(20.spMin, 10.spMin, 20.spMin, 16.spMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _dragHandleBuilder()),
            12.hSizedBox,
            Text(
              'Map details',
              style: TextStyle(
                fontSize: 17.spMin,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _labelBuilder('MAP TYPE').pT(14.0),
                    _mapTypesBuilder().pT(8.0),
                    _labelBuilder('WHICH ALERTS SHOW').pT(18.0),
                    _showChoicesBuilder().pT(8.0),
                    Text(
                      'Emergency warnings are always on.',
                      style: TextStyle(
                        fontSize: 12.spMin,
                        color: AppColors.mediumGrey,
                      ),
                    ).pT(10.0),
                    12.hSizedBox,
                  ],
                ),
              ),
            ),
            _doneButtonBuilder().pT(12.0),
          ],
        ),
      ),
    );
  }

  Widget _dragHandleBuilder() {
    return Container(
      width: 40.spMin,
      height: 4.spMin,
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _labelBuilder(final String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11.spMin,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
        color: AppColors.black.withValues(alpha: 0.5),
      ),
    );
  }

  /// The same four choices as the Filters sheet, one tap each.
  Widget _showChoicesBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final f = ref.watch(providerOfHazardFiltersForMap);
        final switches = HazardFilterSwitches(
          awsWatchAndAct: f.awsWatchAndAct,
          awsAdvice: f.awsAdvice,
          officialNonAws: f.officialNonAws,
          userReported: f.userReported,
        );
        final current = ShowChoice.of(switches);
        return Row(
          spacing: 8.spMin,
          children: [
            for (final choice in ShowChoice.values)
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.spMin),
                  decoration: BoxDecoration(
                    color: _tileColor,
                    borderRadius: BorderRadius.circular(14.spMin),
                    border: Border.all(
                      color: current == choice
                          ? _accentColor
                          : AppColors.black.withValues(alpha: 0.08),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    spacing: 6.spMin,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final icon in choice.shapes)
                            Icon(
                              icon,
                              size: 16.spMin,
                              color: current == choice
                                  ? _accentColor
                                  : AppColors.black.withValues(alpha: 0.65),
                            ),
                        ],
                      ),
                      Text(
                        choice.shortTitle,
                        style: TextStyle(
                          fontSize: 11.5.spMin,
                          fontWeight: current == choice
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: current == choice
                              ? AppColors.black
                              : AppColors.black.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ).onPressed(() {
                  choice.apply(
                    ref.read(providerOfHazardFiltersForMap.notifier),
                    switches,
                  );
                  ref.read(providerOfMap.notifier).getMapHazards();
                  ref.read(providerOfMap.notifier).getRoutePlanHazardsToAvoid();
                }),
              ),
          ],
        );
      },
    );
  }

  Widget _mapTypesBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final selectedMapType = ref.watch(providerOfMapType);

        return Row(
          spacing: 8.spMin,
          children: [
            _mapTypeTileBuilder(
              label: 'Default',
              icon: LucideIcons.map,
              mapType: MapType.normal,
              isSelected: selectedMapType == MapType.normal,
            ),
            _mapTypeTileBuilder(
              label: 'Satellite',
              icon: LucideIcons.satellite,
              mapType: MapType.satellite,
              isSelected: selectedMapType == MapType.satellite,
            ),
            _mapTypeTileBuilder(
              label: 'Terrain',
              icon: LucideIcons.mountain,
              mapType: MapType.terrain,
              isSelected: selectedMapType == MapType.terrain,
            ),
          ],
        );
      },
    );
  }

  Widget _mapTypeTileBuilder({
    required final String label,
    required final IconData icon,
    required final MapType mapType,
    required final bool isSelected,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.spMin),
        decoration: BoxDecoration(
          color: _tileColor,
          borderRadius: BorderRadius.circular(14.spMin),
          border: Border.all(
            color: isSelected ? _accentColor : AppColors.black.withValues(alpha: 0.08),
            width: 1.5,
          ),
        ),
        child: Column(
          spacing: 6.spMin,
          children: [
            Icon(
              icon,
              size: 18.spMin,
              color: isSelected
                  ? _accentColor
                  : AppColors.black.withValues(alpha: 0.65),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5.spMin,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.black
                    : AppColors.black.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ).onPressed(
        () => ref.read(providerOfMapType.notifier).update(mapType),
      ),
    );
  }

  Widget _doneButtonBuilder() {
    return Container(
      width: double.infinity,
      height: 50.spMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.spMin),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF8C00),
            Color(0xFFFF2020),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        'Done',
        style: TextStyle(
          fontSize: 15.spMin,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    ).onPressed(() => Navigator.of(context).pop());
  }
}
