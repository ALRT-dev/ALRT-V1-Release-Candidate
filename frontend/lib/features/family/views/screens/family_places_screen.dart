import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/screens/family_place_edit_screen.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_header_surface.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Saved places: per-place radius and circle-wide "notify the family when
/// `member` arrives/leaves" toggles.
class FamilyPlacesScreen extends ConsumerWidget {
  const FamilyPlacesScreen({super.key});

  static const route = '/family-places';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circle = ref.watch(providerOfFamily.select((s) => s.circle));
    final places = circle?.places ?? const <FamilySavedPlace>[];

    return Scaffold(
      backgroundColor: FamilyColors.v31Page,
      appBar: const FamilyAppBar(
        title: 'Places',
        subtitle: 'Get a quiet note when family arrive or leave',
      ),
      body: ListView(
        padding: EdgeInsets.all(20.spMin),
        children: [
          Text(
            'SAVED PLACES',
            style: TextStyle(
              fontSize: 13.spMin,
              fontWeight: FontWeight.w700,
              color: FamilyColors.v31Label,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 10.spMin),
          for (final place in places)
            _PlaceCard(place: place, circle: circle!),
          SizedBox(height: 4.spMin),
          _addPlaceCardBuilder(context),
          SizedBox(height: 30.spMin),
        ],
      ),
    );
  }

  Widget _addPlaceCardBuilder(final BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(FamilyPlaceEditScreen.route),
      child: Container(
        padding: EdgeInsets.all(18.spMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.spMin),
          border: Border.all(
            color: FamilyColors.indigo.withValues(alpha: 0.4),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42.spMin,
              height: 42.spMin,
              decoration: BoxDecoration(
                color: FamilyColors.indigoLight,
                borderRadius: BorderRadius.circular(12.spMin),
              ),
              child: Icon(
                Icons.add,
                color: FamilyColors.indigo,
                size: 22.spMin,
              ),
            ),
            SizedBox(width: 14.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add a place',
                    style: TextStyle(
                      color: FamilyColors.indigo,
                      fontSize: 16.spMin,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Home, work, school — anywhere that matters',
                    style: TextStyle(fontSize: 12.spMin, color: AppColors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceCard extends ConsumerStatefulWidget {
  const _PlaceCard({required this.place, required this.circle});

  final FamilySavedPlace place;
  final FamilyCircle circle;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlaceCardState();
}

class _PlaceCardState extends ConsumerState<_PlaceCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    return Container(
      margin: EdgeInsets.only(bottom: 12.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        boxShadow: [
          BoxShadow(color: AppColors.shadowColorLight, blurRadius: 2.0),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _expanded = !_expanded),
            leading: Container(
              width: 42.spMin,
              height: 42.spMin,
              decoration: BoxDecoration(
                color: _iconBackground(place.icon),
                borderRadius: BorderRadius.circular(12.spMin),
              ),
              child: Icon(
                _iconData(place.icon),
                color: _iconColor(place.icon),
                size: 20.spMin,
              ),
            ),
            title: Text(
              place.name,
              style: TextStyle(fontSize: 16.spMin, fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${place.address ?? 'Saved location'} · ${place.radiusMeters} m radius',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.spMin, color: AppColors.grey),
            ),
            trailing: Icon(
              _expanded ? Icons.expand_less : Icons.chevron_right,
              color: AppColors.grey,
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(16.spMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NOTIFY THE FAMILY WHEN',
                    style: TextStyle(
                      fontSize: 11.spMin,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 6.spMin),
                  for (final member in widget.circle.members)
                    ..._memberToggleRowsBuilder(member),
                  SizedBox(height: 8.spMin),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => context.push(
                          FamilyPlaceEditScreen.route,
                          extra: FamilyPlaceEditScreenArgs(place: place),
                        ),
                        icon: Icon(LucideIcons.pencil, size: 14.spMin),
                        label: const Text('Edit'),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        onPressed: _confirmDelete,
                        icon: Icon(LucideIcons.trash2, size: 14.spMin),
                        label: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _memberToggleRowsBuilder(final FamilyMember member) {
    final pref = widget.place.notificationPrefs
        .where((p) => p.subjectMemberId == member.id)
        .firstOrNull;
    final notifyArrivals = pref?.notifyArrivals ?? true;
    final notifyDepartures = pref?.notifyDepartures ?? true;

    Widget row({
      required String label,
      required bool value,
      required bool isArrival,
    }) {
      return Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 14.spMin)),
          ),
          Switch(
            value: value,
            activeTrackColor: FamilyColors.indigo,
            onChanged: (next) {
              ref.read(providerOfFamily.notifier).updatePlacePref(
                placeId: widget.place.id,
                subjectMemberId: member.id,
                notifyArrivals: isArrival ? next : notifyArrivals,
                notifyDepartures: isArrival ? notifyDepartures : next,
              );
            },
          ),
        ],
      );
    }

    return [
      row(
        label: '${member.name} arrives',
        value: notifyArrivals,
        isArrival: true,
      ),
      row(
        label: '${member.name} leaves',
        value: notifyDepartures,
        isArrival: false,
      ),
    ];
  }

  void _confirmDelete() {
    showConfirmationSheet(
      context: context,
      title: 'Delete ${widget.place.name}?',
      confirmButtonText: 'Delete',
      onPressedConfirm: (_, __) => ref
          .read(providerOfFamily.notifier)
          .deletePlace(placeId: widget.place.id),
    );
  }

  IconData _iconData(final FamilyPlaceIcon icon) => switch (icon) {
    FamilyPlaceIcon.home => LucideIcons.house,
    FamilyPlaceIcon.work => LucideIcons.briefcase,
    FamilyPlaceIcon.school => LucideIcons.graduationCap,
    FamilyPlaceIcon.heart => LucideIcons.heart,
    FamilyPlaceIcon.other => LucideIcons.mapPin,
  };

  Color _iconColor(final FamilyPlaceIcon icon) => switch (icon) {
    FamilyPlaceIcon.home => AppColors.orange,
    FamilyPlaceIcon.work => AppColors.blue,
    FamilyPlaceIcon.school => const Color(0xFF16A085),
    FamilyPlaceIcon.heart => const Color(0xFF8E44AD),
    FamilyPlaceIcon.other => AppColors.grey,
  };

  Color _iconBackground(final FamilyPlaceIcon icon) =>
      _iconColor(icon).withValues(alpha: 0.12);
}
