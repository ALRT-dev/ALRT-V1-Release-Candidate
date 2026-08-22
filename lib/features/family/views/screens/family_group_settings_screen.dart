import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_group_avatar.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_source_types.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';

/// Group settings: the beacon colour, and how this group sees you.
///
/// The header previews the beacon colour live, so the choice is visible in
/// the place it will actually be felt rather than only as a swatch.
class FamilyGroupSettingsScreen extends ConsumerStatefulWidget {
  const FamilyGroupSettingsScreen({super.key});

  static const route = '/family-group-settings';

  @override
  ConsumerState<FamilyGroupSettingsScreen> createState() =>
      _FamilyGroupSettingsScreenState();
}

class _FamilyGroupSettingsScreenState
    extends ConsumerState<FamilyGroupSettingsScreen> {
  static const _page = Color(0xFFF5F2F7);
  static const _label = Color(0xFFB84500);
  static const _perGroupLabel = Color(0xFF8E24AA);
  static const _muted = Color(0xFF8A8792);
  static const _perGroupPillBackground = Color(0xFFE4F7EE);
  static const _perGroupPillInk = Color(0xFF0A8A58);

  /// The ten beacons a group can wear. Colours another group already uses
  /// are labelled rather than hidden, so every group stays distinct.
  static const _swatches = <Color>[
    FamilyColors.v31Indigo,
    Color(0xFFFF6B01),
    Color(0xFF16A46B),
    Color(0xFFE0362B),
    Color(0xFFF5A623),
    Color(0xFF4DA8FF),
    Color(0xFF9C27B0),
    Color(0xFFEC1C7D),
    Color(0xFF1D1D21),
    Color(0xFF8A8792),
  ];

  Color? _picked;
  bool _usePhoto = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final circle = ref.watch(providerOfFamily.select((s) => s.circle));
    final circles = ref.watch(providerOfFamily.select((s) => s.circles));
    if (circle == null) return const SizedBox.shrink();

    final selected = _picked ?? _colorOf(circle.themeColor) ?? _swatches.first;

    // Which colours the user's other groups already wear, so they can be
    // labelled instead of quietly clashing.
    final takenLabels = <int, String>{};
    for (final other in circles) {
      if (other.circleId == circle.id) continue;
      final color = _colorOf(other.themeColor);
      if (color == null) continue;
      takenLabels[color.toARGB32()] =
          other.name.split(RegExp(r'\s+')).first.toUpperCase();
    }

    return Scaffold(
      backgroundColor: _page,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _headerBuilder(circle, selected),
          _groupPictureCardBuilder(circle, selected),
          _beaconCardBuilder(selected, takenLabels),
          _seesYouCardBuilder(circle),
          SizedBox(height: 24.spMin),
        ],
      ),
    );
  }

  Widget _headerBuilder(final FamilyCircle circle, final Color beacon) {
    return Container(
      width: double.infinity,
      // The header IS the preview: it wears the colour being chosen.
      color: beacon,
      padding: EdgeInsets.fromLTRB(16.spMin, 12.spMin, 16.spMin, 18.spMin),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 30.spMin,
                    height: 30.spMin,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 14.spMin,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 11.spMin),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GROUPS',
                        style: TextStyle(
                          fontSize: 11.spMin,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        'Group settings',
                        style: TextStyle(
                          fontSize: 21.spMin,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _isSaving ? null : _handleSave,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.spMin,
                      vertical: 8.spMin,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16.spMin),
                    ),
                    child: Text(
                      _isSaving ? 'SAVING' : 'SAVE',
                      style: TextStyle(
                        fontSize: 11.spMin,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: const Color(0xFF1D1D21),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.spMin),
            Text(
              '${circle.name} · live preview above',
              style: TextStyle(
                fontSize: 12.spMin,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The group picture: how the circle is recognised on the hub, in the
  /// switcher and on the home-screen widget.
  ///
  /// Owner-only, like the beacon colour. Members see the picture without
  /// the controls rather than a card that fails when they tap it.
  Widget _groupPictureCardBuilder(
    final FamilyCircle circle,
    final Color beacon,
  ) {
    final isOwner = circle.me?.role == FamilyRole.owner;
    final hasPhoto = (circle.photoUrl ?? '').isNotEmpty;

    return _cardBuilder(
      topMargin: 13,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GROUP PICTURE',
            style: TextStyle(
              fontSize: 10.spMin,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: _label,
            ),
          ),
          SizedBox(height: 11.spMin),
          Row(
            children: [
              FamilyGroupAvatar(
                name: circle.name,
                photoUrl: circle.photoUrl,
                themeColorHex: _hexOf(beacon),
                size: 60.spMin,
              ),
              SizedBox(width: 13.spMin),
              Expanded(
                child: Text(
                  isOwner
                      ? 'Shown wherever ${circle.name} is listed, including '
                            'the home-screen widget. Without one the group '
                            'wears its initial on the beacon colour.'
                      : 'Set by the person who owns ${circle.name}.',
                  style: TextStyle(
                    fontSize: 11.5.spMin,
                    height: 1.5,
                    color: FamilyColors.v31Ink,
                  ),
                ),
              ),
            ],
          ),
          if (isOwner) ...[
            SizedBox(height: 13.spMin),
            Row(
              children: [
                Expanded(
                  child: _photoActionBuilder(
                    label: hasPhoto ? 'Change picture' : 'Add a picture',
                    isPrimary: true,
                    onTap: _isSaving ? null : _changeGroupPhoto,
                  ),
                ),
                if (hasPhoto) ...[
                  SizedBox(width: 8.spMin),
                  Expanded(
                    child: _photoActionBuilder(
                      label: 'Remove',
                      isPrimary: false,
                      onTap: _isSaving ? null : _removeGroupPhoto,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _photoActionBuilder({
    required final String label,
    required final bool isPrimary,
    required final VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 11.spMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFFFF4EC) : Colors.white,
          borderRadius: BorderRadius.circular(11.spMin),
          border: Border.all(
            color: isPrimary ? _label : FamilyColors.v31Border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.spMin,
            fontWeight: FontWeight.w800,
            color: isPrimary ? _label : FamilyColors.v31Ink,
          ),
        ),
      ),
    );
  }

  Widget _beaconCardBuilder(
    final Color selected,
    final Map<int, String> takenLabels,
  ) {
    return _cardBuilder(
      topMargin: 13,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BEACON COLOUR',
            style: TextStyle(
              fontSize: 10.spMin,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: _label,
            ),
          ),
          SizedBox(height: 6.spMin),
          Text(
            'This colour marks the group everywhere: member dots, snapshot '
            'pins, journey points and the widget.',
            style: TextStyle(
              fontSize: 12.spMin,
              height: 1.6,
              color: FamilyColors.v31Ink,
            ),
          ),
          SizedBox(height: 14.spMin),
          GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 11.spMin,
            crossAxisSpacing: 11.spMin,
            children: [
              for (final swatch in _swatches)
                _swatchBuilder(
                  swatch: swatch,
                  isSelected: swatch.toARGB32() == selected.toARGB32(),
                  takenBy: takenLabels[swatch.toARGB32()],
                ),
            ],
          ),
          SizedBox(height: 13.spMin),
          Text(
            'Colours used by your other groups are labelled so every group '
            'stays distinct.',
            style: TextStyle(
              fontSize: 11.spMin,
              height: 1.6,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _swatchBuilder({
    required final Color swatch,
    required final bool isSelected,
    final String? takenBy,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _picked = swatch),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: swatch,
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: swatch.withValues(alpha: 0.5),
                    blurRadius: 12.0,
                    spreadRadius: 1.0,
                  ),
                ]
              : null,
          border: isSelected
              ? Border.all(color: Colors.white, width: 2.5)
              : null,
        ),
        child: isSelected
            ? Icon(Icons.check_rounded, size: 16.spMin, color: Colors.white)
            : takenBy == null
            ? null
            : Text(
                takenBy,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontSize: 7.5.spMin,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _seesYouCardBuilder(final FamilyCircle circle) {
    final me = circle.me;
    return _cardBuilder(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  'HOW THIS GROUP SEES YOU',
                  style: TextStyle(
                    fontSize: 10.spMin,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: _perGroupLabel,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 9.spMin,
                  vertical: 3.spMin,
                ),
                decoration: BoxDecoration(
                  color: _perGroupPillBackground,
                  borderRadius: BorderRadius.circular(11.spMin),
                ),
                child: Text(
                  'Per group',
                  style: TextStyle(
                    fontSize: 9.5.spMin,
                    fontWeight: FontWeight.w800,
                    color: _perGroupPillInk,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 11.spMin),
          Row(
            children: [
              Container(
                width: 42.spMin,
                height: 42.spMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: FamilyColors.memberColor(me?.id ?? circle.id),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _initialsOf(me?.name ?? 'You'),
                  style: TextStyle(
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 12.spMin),
              Expanded(
                child: Text(
                  'This photo is only visible inside ${circle.name} — no '
                  'location history, snapshots or SOS data ever attach to it.',
                  style: TextStyle(
                    fontSize: 11.spMin,
                    height: 1.4,
                    color: FamilyColors.v31Ink,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.spMin),
          Row(
            children: [
              Expanded(child: _avatarModeBuilder('Initials', !_usePhoto)),
              SizedBox(width: 8.spMin),
              Expanded(child: _avatarModeBuilder('Photo', _usePhoto)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatarModeBuilder(final String label, final bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _usePhoto = label == 'Photo'),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 9.spMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF4EC) : Colors.white,
          borderRadius: BorderRadius.circular(11.spMin),
          border: Border.all(
            color: isSelected ? _label : FamilyColors.v31Border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.spMin,
            fontWeight: FontWeight.w800,
            color: isSelected ? _label : FamilyColors.v31Ink,
          ),
        ),
      ),
    );
  }

  Widget _cardBuilder({
    required final Widget child,
    final double topMargin = 11,
  }) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.spMin, topMargin.spMin, 16.spMin, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
        boxShadow: const [
          BoxShadow(
            color: FamilyColors.v31CardShadow,
            blurRadius: 10.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16.spMin,
        vertical: 15.spMin,
      ),
      child: child,
    );
  }

  /// Picks and uploads a group picture. Applies immediately rather than
  /// waiting for SAVE: an image upload is its own action, and the group's
  /// members see it the moment it lands.
  Future<void> _changeGroupPhoto() async {
    final medias = await showImagePickerBottomSheet(context: context);
    final media = medias?.firstOrNull;
    if (media == null || media.source != AlrtMediaSource.file) return;
    if (!mounted) return;

    setState(() => _isSaving = true);
    final uploaded = await ref
        .read(providerOfFamily.notifier)
        .updateGroupPhoto(File(media.value));
    if (!mounted) return;
    setState(() => _isSaving = false);

    uploaded
        ? context.showSuccessToast(message: 'Group picture updated.')
        : context.showErrorToast(
            message: 'Could not upload the picture. Please try again.',
          );
  }

  Future<void> _removeGroupPhoto() async {
    setState(() => _isSaving = true);
    final removed = await ref
        .read(providerOfFamily.notifier)
        .removeGroupPhoto();
    if (!mounted) return;
    setState(() => _isSaving = false);

    removed
        ? context.showSuccessToast(message: 'Group picture removed.')
        : context.showErrorToast(
            message: 'Could not remove the picture. Please try again.',
          );
  }

  Future<void> _handleSave() async {
    final picked = _picked;
    if (picked == null) {
      Navigator.of(context).maybePop();
      return;
    }

    setState(() => _isSaving = true);
    final ok = await ref
        .read(providerOfFamily.notifier)
        .updateGroupSettings(themeColor: _hexOf(picked));
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      context.showSuccessToast(message: 'Group settings saved');
      Navigator.of(context).maybePop();
    } else {
      context.showErrorToast(message: 'Could not save. Please try again.');
    }
  }

  static Color? _colorOf(final String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return null;
    return Color(cleaned.length <= 6 ? value | 0xFF000000 : value);
  }

  static String _hexOf(final Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  static String _initialsOf(final String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
