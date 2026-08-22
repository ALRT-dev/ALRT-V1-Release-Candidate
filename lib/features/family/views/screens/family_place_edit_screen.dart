import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_header_surface.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/views/screens/select_location_on_map_screen.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FamilyPlaceEditScreenArgs {
  const FamilyPlaceEditScreenArgs({this.place});

  /// The place being edited; null when creating a new one.
  final FamilySavedPlace? place;
}

/// Create or edit a saved place: name, icon, location and radius.
class FamilyPlaceEditScreen extends ConsumerStatefulWidget {
  const FamilyPlaceEditScreen({super.key, this.args});

  static const route = '/family-place-edit';

  final FamilyPlaceEditScreenArgs? args;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FamilyPlaceEditScreenState();
}

class _FamilyPlaceEditScreenState
    extends ConsumerState<FamilyPlaceEditScreen> {
  late final _nameController = TextEditingController(
    text: widget.args?.place?.name ?? '',
  );
  late FamilyPlaceIcon _icon = widget.args?.place?.icon ?? FamilyPlaceIcon.home;
  late double _radiusMeters =
      (widget.args?.place?.radiusMeters ?? 300).toDouble();
  late AlrtLocation? _location = widget.args?.place != null
      ? AlrtLocation(
          latitude: widget.args!.place!.latitude,
          longitude: widget.args!.place!.longitude,
          address: widget.args!.place!.address,
        )
      : null;

  FamilySavedPlace? get _editingPlace => widget.args?.place;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saveState = ref.watch(
      providerOfFamily.select((s) => s.placeSaveState),
    );

    return Scaffold(
      backgroundColor: FamilyColors.v31Page,
      appBar: FamilyAppBar(
        title: _editingPlace == null ? 'Add a place' : 'Edit place',
      ),
      body: ListView(
        padding: EdgeInsets.all(20.spMin),
        children: [
          _labelBuilder('NAME'),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            maxLength: 40,
            decoration: const InputDecoration(
              hintText: 'e.g. Home, School, Grandma\'s',
              counterText: '',
            ),
          ),
          SizedBox(height: 18.spMin),
          _labelBuilder('ICON'),
          _iconPickerBuilder(),
          SizedBox(height: 18.spMin),
          _labelBuilder('LOCATION'),
          _locationCardBuilder(),
          SizedBox(height: 18.spMin),
          _labelBuilder('RADIUS · ${_radiusMeters.round()} m'),
          Slider(
            value: _radiusMeters,
            min: 50,
            max: 2000,
            divisions: 39,
            activeColor: FamilyColors.indigo,
            label: '${_radiusMeters.round()} m',
            onChanged: (value) => setState(() => _radiusMeters = value),
          ),
          Text(
            'The family is notified when a member crosses this boundary.',
            style: TextStyle(fontSize: 12.spMin, color: AppColors.grey),
          ),
          SizedBox(height: 26.spMin),
          SizedBox(
            height: 52.spMin,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: FamilyColors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.spMin),
                ),
              ),
              onPressed: saveState.isLoading ? null : _onSave,
              child: saveState.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _editingPlace == null ? 'Save place' : 'Save changes',
                      style: TextStyle(
                        fontSize: 16.spMin,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 30.spMin),
        ],
      ),
    );
  }

  Widget _labelBuilder(final String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.spMin),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.spMin,
          fontWeight: FontWeight.w700,
          color: FamilyColors.v31Label,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _iconPickerBuilder() {
    return Wrap(
      spacing: 10.spMin,
      children: [
        for (final icon in FamilyPlaceIcon.values)
          GestureDetector(
            onTap: () => setState(() => _icon = icon),
            child: Container(
              width: 54.spMin,
              height: 54.spMin,
              decoration: BoxDecoration(
                color: _icon == icon ? FamilyColors.indigo : Colors.white,
                borderRadius: BorderRadius.circular(16.spMin),
                border: Border.all(
                  color: _icon == icon
                      ? FamilyColors.indigo
                      : Colors.grey.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                switch (icon) {
                  FamilyPlaceIcon.home => LucideIcons.house,
                  FamilyPlaceIcon.work => LucideIcons.briefcase,
                  FamilyPlaceIcon.school => LucideIcons.graduationCap,
                  FamilyPlaceIcon.heart => LucideIcons.heart,
                  FamilyPlaceIcon.other => LucideIcons.mapPin,
                },
                color: _icon == icon ? Colors.white : AppColors.grey,
                size: 22.spMin,
              ),
            ),
          ),
      ],
    );
  }

  Widget _locationCardBuilder() {
    return GestureDetector(
      onTap: _pickLocation,
      child: Container(
        padding: EdgeInsets.all(16.spMin),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.spMin),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.mapPin,
              size: 20.spMin,
              color: _location == null ? AppColors.grey : FamilyColors.indigo,
            ),
            SizedBox(width: 10.spMin),
            Expanded(
              child: Text(
                _location == null
                    ? 'Tap to choose on the map'
                    : _location!.address ??
                          '${_location!.latitude.toStringAsFixed(5)}, '
                              '${_location!.longitude.toStringAsFixed(5)}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w600,
                  color: _location == null ? AppColors.grey : AppColors.black,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.grey, size: 20.spMin),
          ],
        ),
      ),
    );
  }

  void _pickLocation() async {
    final result = await context.push<AlrtLocation>(
      SelectLocationOnMapScreen.route,
      extra: SelectLocationOnMapScreenArgs(initialLocation: _location),
    );
    if (result != null && mounted) {
      setState(() => _location = result);
    }
  }

  void _onSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      context.showErrorToast(message: 'Give the place a name first');
      return;
    }
    final location = _location;
    if (location == null) {
      context.showErrorToast(message: 'Choose the place on the map first');
      return;
    }

    final notifier = ref.read(providerOfFamily.notifier);
    final editing = _editingPlace;
    final success = editing == null
        ? await notifier.createPlace(
            name: name,
            latitude: location.latitude,
            longitude: location.longitude,
            icon: _icon,
            radiusMeters: _radiusMeters.round(),
            address: location.address,
          )
        : await notifier.updatePlace(
            placeId: editing.id,
            name: name,
            latitude: location.latitude,
            longitude: location.longitude,
            icon: _icon,
            radiusMeters: _radiusMeters.round(),
            address: location.address,
          );

    if (!mounted) return;
    if (success) {
      context.pop();
    } else {
      context.showErrorToast(
        message: 'Could not save the place. Please try again.',
      );
    }
  }
}
