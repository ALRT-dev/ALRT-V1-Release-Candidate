import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/screens/family_place_edit_screen.dart';
import 'package:hazard_app/features/family/views/widgets/family_board_kit.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/views/screens/select_location_on_map_screen.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/others/app_colors.dart';

/// "Family places" (FamilyPlaces board): arrive and leave notices for the
/// group, only for places added here. The note, one card per place, then
/// a card to add one: name, "Pick location" and "Add a place".
///
/// Tapping a place opens who the group is told about (arrives / leaves per
/// person); Edit opens the full editor (icon, radius).
class FamilyPlacesScreen extends ConsumerStatefulWidget {
  const FamilyPlacesScreen({super.key});

  static const route = '/family-places';

  @override
  ConsumerState<FamilyPlacesScreen> createState() => _FamilyPlacesScreenState();
}

class _FamilyPlacesScreenState extends ConsumerState<FamilyPlacesScreen> {
  /// New places start at the default radius (rules.json placeRadiusDefaultM).
  static const _defaultRadiusMeters = 300;

  final _nameController = TextEditingController();
  AlrtLocation? _location;
  bool _adding = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final circle = ref.watch(providerOfFamily.select((s) => s.circle));
    final places = circle?.places ?? const <FamilySavedPlace>[];

    return FamilyBoardScaffold(
      title: 'Family places',
      subtitle: 'Arrive and leave notices for your group',
      gap: 10,
      children: [
        const FamilyBoardNote(
          'Only for places you add here. Your group is told when you arrive '
          'or leave. Different from your own saved places for alerts.',
        ),
        if (circle != null)
          for (final place in places) _PlaceCard(place: place, circle: circle),
        _addCardBuilder(),
      ],
    );
  }

  Widget _addCardBuilder() {
    final location = _location;
    return FamilyBoardCard(
      children: [
        TextField(
          key: const Key('family-place-name'),
          controller: _nameController,
          maxLength: 40,
          textCapitalization: TextCapitalization.words,
          style: familyBoardInputStyle(),
          decoration: familyBoardInputDecoration('Place name (Home, School)'),
        ),
        if (location != null)
          FamilyBoardMuted(
            location.address ?? 'Location picked on the map',
            size: 12,
          ),
        Row(
          children: [
            Expanded(
              child: FamilyBoardSecondaryButton(
                key: const Key('family-place-pick'),
                label: location == null ? 'Pick location' : 'Change location',
                onPressed: _adding ? null : _pickLocation,
              ),
            ),
            SizedBox(width: 8.spMin),
            Expanded(
              child: FamilyBoardPrimaryButton(
                key: const Key('family-place-add'),
                label: 'Add a place',
                busy: _adding,
                onPressed: _addPlace,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickLocation() async {
    final result = await context.push<AlrtLocation>(
      SelectLocationOnMapScreen.route,
      extra: SelectLocationOnMapScreenArgs(initialLocation: _location),
    );
    if (result != null && mounted) setState(() => _location = result);
  }

  Future<void> _addPlace() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      context.showErrorToast(message: 'Give the place a name first');
      return;
    }
    final location = _location;
    if (location == null) {
      context.showErrorToast(message: 'Pick the place on the map first');
      return;
    }

    setState(() => _adding = true);
    final added = await ref
        .read(providerOfFamily.notifier)
        .createPlace(
          name: name,
          latitude: location.latitude,
          longitude: location.longitude,
          radiusMeters: _defaultRadiusMeters,
          address: location.address,
        );
    if (!mounted) return;
    setState(() {
      _adding = false;
      if (added) {
        _nameController.clear();
        _location = null;
      }
    });
    if (!added) {
      context.showErrorToast(message: 'Could not add the place. Try again.');
    }
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
    final address = place.address;
    return FamilyBoardCard(
      key: Key('family-place-${place.id}'),
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _expanded = !_expanded),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: TextStyle(
                        fontSize: 16.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 2.spMin),
                    FamilyBoardMuted(
                      address == null || address.isEmpty
                          ? '${place.radiusMeters} m'
                          : '${place.radiusMeters} m · $address',
                      size: 12,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.spMin),
            FamilyBoardSmallButton(
              label: 'Edit',
              onPressed: () => context.push(
                FamilyPlaceEditScreen.route,
                extra: FamilyPlaceEditScreenArgs(place: place),
              ),
            ),
            SizedBox(width: 8.spMin),
            FamilyBoardSmallButton(label: 'Delete', onPressed: _confirmDelete),
          ],
        ),
        if (_expanded) ...[
          const FamilyBoardLabel('Tell the group when'),
          for (final member in widget.circle.members)
            ..._memberToggleRowsBuilder(member),
        ],
      ],
    );
  }

  List<Widget> _memberToggleRowsBuilder(final FamilyMember member) {
    final pref = widget.place.notificationPrefs
        .where((p) => p.subjectMemberId == member.id)
        .firstOrNull;
    final notifyArrivals = pref?.notifyArrivals ?? true;
    final notifyDepartures = pref?.notifyDepartures ?? true;

    void update({required final bool isArrival, required final bool next}) {
      ref
          .read(providerOfFamily.notifier)
          .updatePlacePref(
            placeId: widget.place.id,
            subjectMemberId: member.id,
            notifyArrivals: isArrival ? next : notifyArrivals,
            notifyDepartures: isArrival ? notifyDepartures : next,
          );
    }

    return [
      FamilyBoardToggleRow(
        title: '${member.name} arrives',
        value: notifyArrivals,
        onChanged: (next) => update(isArrival: true, next: next),
      ),
      FamilyBoardToggleRow(
        title: '${member.name} leaves',
        value: notifyDepartures,
        onChanged: (next) => update(isArrival: false, next: next),
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
}
