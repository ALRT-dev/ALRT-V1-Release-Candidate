import 'package:flutter/material.dart';
import 'package:hazard_app/features/map/providers/map_display_settings_provider.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/notification/models/push_notification_settings_model.dart';
import 'package:hazard_app/features/notification/views/widgets/manage_push_notifications_list.dart';
import 'package:hazard_app/features/shared/providers/hazard_filters_provider.dart';
import 'package:hazard_app/features/map/views/screens/map_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shows the "Map details" bottom sheet (light background, owner 9 Sep 2026):
/// the map type and one row for which alerts show (owner, 14 Oct 2026).
/// Opens at about half the screen so the map stays visible above it; Done
/// stays pinned above the navigation bar.
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
const kMapDetailsSheetInitialSize = 0.48;
const kMapDetailsSheetMinSize = 0.3;
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
                    _sectionLabelBuilder('MAP TYPE').pT(16.0),
                    _mapTypesBuilder().pT(10.0),
                    // Two things only (product owner, 14 Oct 2026): the map
                    // type, and one horizontal row for which alerts show.
                    // The row writes the same shared ALRT Filters the
                    // Filters sheet and the Alerts tab use, so nothing can
                    // drift. The key lives behind the rail's info button.
                    _sectionLabelBuilder('WHICH ALERTS SHOW').pT(18.0),
                    _alertLevelRowBuilder().pT(10.0),
                    Text(
                      'Emergency warnings are always on.',
                      style: TextStyle(
                        fontSize: 12.spMin,
                        color: AppColors.black.withValues(alpha: 0.55),
                      ),
                    ).pT(8.0),
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

  /// Official / All / Community / Quiet as one row of equal buttons, each
  /// with the map shapes it puts on the map.
  Widget _alertLevelRowBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final filtersProvider = providerOfHazardFilters(MapScreen.filtersKey);
        final f = ref.watch(filtersProvider);
        final settings = PushNotificationSettings(
          awsEmergency: true,
          awsWatchAndAct: f.awsWatchAndAct,
          awsAdvice: f.awsAdvice,
          officialNonAws: f.officialNonAws,
          userReported: f.userReported,
        );
        final level = notificationLevelOf(settings);

        void pick(final NotificationLevel chosen) {
          final next = settingsForLevel(settings, chosen);
          ref.read(filtersProvider.notifier)
            ..updateAwsAdvice(next.awsAdvice)
            ..updateAwsWatchAndAct(next.awsWatchAndAct)
            ..updateOfficialNonAws(next.officialNonAws)
            ..updateUserReported(next.userReported);
          ref.read(providerOfMap.notifier).getMapHazards();
        }

        Widget tile(
          final String label,
          final NotificationLevel value,
          final List<IconData> icons,
        ) {
          final selected = level == value;
          return Expanded(
            child: Semantics(
              button: true,
              selected: selected,
              label: label,
              child: Container(
                constraints: BoxConstraints(minHeight: 64.spMin),
                padding: EdgeInsets.symmetric(
                  vertical: 10.spMin,
                  horizontal: 4.spMin,
                ),
                decoration: BoxDecoration(
                  color: _tileColor,
                  borderRadius: BorderRadius.circular(14.spMin),
                  border: Border.all(
                    color: selected
                        ? _accentColor
                        : AppColors.black.withValues(alpha: 0.08),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 6.spMin,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 1.spMin,
                      children: [
                        for (final icon in icons)
                          Icon(
                            icon,
                            size: 15.spMin,
                            color: selected
                                ? _accentColor
                                : AppColors.black.withValues(alpha: 0.65),
                          ),
                      ],
                    ),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5.spMin,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected
                            ? AppColors.black
                            : AppColors.black.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ).onPressed(() => pick(value)),
            ),
          );
        }

        return Row(
          spacing: 6.spMin,
          children: [
            tile('Official', NotificationLevel.officialOnly, const [
              LucideIcons.triangleAlert,
              LucideIcons.diamond,
            ]),
            tile('All', NotificationLevel.officialAndCommunity, const [
              LucideIcons.triangleAlert,
              LucideIcons.diamond,
              LucideIcons.circle,
            ]),
            tile('Community', NotificationLevel.communityOnly, const [
              LucideIcons.circle,
            ]),
            tile('Quiet', NotificationLevel.quiet, const [
              LucideIcons.bellOff,
            ]),
          ],
        );
      },
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

  Widget _sectionLabelBuilder(final String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10.5.spMin,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: AppColors.black.withValues(alpha: 0.5),
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
