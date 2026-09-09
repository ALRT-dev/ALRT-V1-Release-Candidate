import 'package:flutter/material.dart';
import 'package:hazard_app/features/map/providers/map_display_settings_provider.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/features/map/views/screens/map_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/views/widgets/alert_key_content.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shows the dark "Map details" bottom sheet (V3 map UI): map type picker
/// and per-source-system alert visibility toggles.
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
const kMapDetailsSheetInitialSize = 0.75;
const kMapDetailsSheetMinSize = 0.4;
const kMapDetailsSheetMaxSize = 0.9;

class MapDetailsSheet extends ConsumerStatefulWidget {
  const MapDetailsSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MapDetailsSheetState();
}

class _MapDetailsSheetState extends ConsumerState<MapDetailsSheet> {
  static const _sheetColor = Color(0xFF141416);
  static const _tileColor = Color(0xFF23252B);
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
                color: AppColors.white,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabelBuilder('MAP TYPE').pT(16.0),
                    _mapTypesBuilder().pT(10.0),
                    // Which alerts show is decided in ONE place, the ALRT
                    // Filters sheet the map and the feed share. This sheet
                    // used to carry a second, unsynced set of source
                    // toggles (phone QA 2026-09-09); now it points there.
                    _sectionLabelBuilder('WHICH ALERTS SHOW').pT(18.0),
                    _alertFiltersLinkBuilder().pT(10.0),
                    // THE key, shared with the feed's filter sheet and
                    // the ALRT Key sheet, so it cannot drift again.
                    const AlertKeyContent(isDark: true).pT(18.0),
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

  /// Closes this sheet and opens the shared ALRT Filters sheet for the map.
  Widget _alertFiltersLinkBuilder() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).pop();
        showHazardFiltersBottomSheet(
          context: context,
          filtersKey: MapScreen.filtersKey,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 12.spMin),
        decoration: BoxDecoration(
          color: _tileColor,
          borderRadius: BorderRadius.circular(14.spMin),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.slidersHorizontal, size: 20.spMin, color: _accentColor),
            SizedBox(width: 12.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ALRT Filters',
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    'Warning levels, sources and categories · the same for the map and the feed',
                    style: TextStyle(
                      fontSize: 12.spMin,
                      color: AppColors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 18.spMin, color: AppColors.white.withValues(alpha: 0.6)),
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
        color: AppColors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _sectionLabelBuilder(final String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10.5.spMin,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: AppColors.white.withValues(alpha: 0.45),
      ),
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
            color: isSelected ? _accentColor : AppColors.transparent,
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
                  : AppColors.white.withValues(alpha: 0.7),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5.spMin,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.white
                    : AppColors.white.withValues(alpha: 0.7),
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
