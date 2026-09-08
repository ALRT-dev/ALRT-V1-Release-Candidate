import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/screens/family_circle_profile_screen.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_group_avatar.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_source_types.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';

/// Circle settings: the ONE place a circle's name, rules, picture and
/// beacon colour are edited. The hub's overflow menu and its shortcuts all
/// land here; nothing else edits these fields.
///
/// The host edits; everyone else sees the same screen read-only, so a
/// member learns where the settings live rather than finding a menu item
/// that fails. "How this circle sees you" is a per-member thing and lives
/// on the circle profile screen, linked at the bottom.
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
  // Section headings in the prototype's deep purple, not the old orange.
  static const _label = FamilyColors.indigoDark;
  static const _perGroupLabel = FamilyColors.indigo;
  static const _muted = Color(0xFF8A8792);

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
  bool _isSaving = false;

  // Name and rules are held here until SAVE, like the beacon colour, so one
  // tap saves everything and Back discards everything.
  late final TextEditingController _nameController;
  bool? _anyoneCanRequest;
  bool? _sosWholeCircle;
  bool? _snapPointsOnly;
  String? _seededForCircleId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _seedFrom(final FamilyCircle circle) {
    if (_seededForCircleId == circle.id) return;
    _seededForCircleId = circle.id;
    _nameController.text = circle.name;
    _anyoneCanRequest = circle.anyoneCanRequestSnapshot;
    _sosWholeCircle = circle.sosToWholeGroup;
    _snapPointsOnly = circle.journeysSnapPointsOnly;
  }

  @override
  Widget build(BuildContext context) {
    final circle = ref.watch(providerOfFamily.select((s) => s.circle));
    final circles = ref.watch(providerOfFamily.select((s) => s.circles));
    if (circle == null) return const SizedBox.shrink();
    _seedFrom(circle);

    final isOwner = circle.me?.role == FamilyRole.owner;
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

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomSafe = MediaQuery.viewPaddingOf(context).bottom;
    return Scaffold(
      backgroundColor: _page,
      body: ListView(
        padding: EdgeInsets.only(
          bottom: 24.spMin + (bottomInset > bottomSafe ? bottomInset : bottomSafe),
        ),
        children: [
          _headerBuilder(circle, selected, isOwner: isOwner),
          _nameAndRulesCardBuilder(circle, isOwner: isOwner),
          _groupPictureCardBuilder(circle, selected),
          _beaconCardBuilder(selected, takenLabels, isOwner: isOwner),
          _myProfileLinkBuilder(circle),
        ],
      ),
    );
  }

  /// Name and the three locked rules. Editable by the host only; members
  /// see the values so the rules are never a mystery.
  Widget _nameAndRulesCardBuilder(
    final FamilyCircle circle, {
    required final bool isOwner,
  }) {
    return _cardBuilder(
      topMargin: 13,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NAME & RULES',
            style: TextStyle(
              fontSize: 10.spMin,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: _label,
            ),
          ),
          SizedBox(height: 8.spMin),
          if (isOwner)
            TextField(
              controller: _nameController,
              maxLength: 50,
              textCapitalization: TextCapitalization.words,
              enabled: !_isSaving,
              decoration: const InputDecoration(
                labelText: 'Circle name',
                counterText: '',
              ),
            )
          else
            Text(
              circle.name,
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w800,
                color: FamilyColors.v31Ink,
              ),
            ),
          SizedBox(height: 6.spMin),
          _ruleBuilder(
            title: 'Anyone can ask for a snapshot',
            subtitle: 'Off: only the host can send location requests',
            value: _anyoneCanRequest ?? circle.anyoneCanRequestSnapshot,
            isOwner: isOwner,
            onChanged: (value) => setState(() => _anyoneCanRequest = value),
          ),
          _ruleBuilder(
            title: 'SOS goes to the whole circle',
            subtitle: 'Off: members are nudged to pick an SOS list',
            value: _sosWholeCircle ?? circle.sosToWholeGroup,
            isOwner: isOwner,
            onChanged: (value) => setState(() => _sosWholeCircle = value),
          ),
          _ruleBuilder(
            title: 'Journeys are snap points only',
            subtitle: 'Never a live trail — departure, ~10 min points, arrival',
            value: _snapPointsOnly ?? circle.journeysSnapPointsOnly,
            isOwner: isOwner,
            onChanged: (value) => setState(() => _snapPointsOnly = value),
          ),
          if (!isOwner) ...[
            SizedBox(height: 6.spMin),
            Text(
              'Only the host can change these.',
              style: TextStyle(fontSize: 11.spMin, color: _muted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _ruleBuilder({
    required final String title,
    required final String subtitle,
    required final bool value,
    required final bool isOwner,
    required final ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      activeThumbColor: FamilyColors.indigo,
      value: value,
      onChanged: isOwner && !_isSaving ? onChanged : null,
      title: Text(
        title,
        style: TextStyle(fontSize: 14.spMin, color: FamilyColors.v31Ink),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 11.5.spMin)),
    );
  }

  /// Per-member identity is not a circle setting; point at where it lives
  /// instead of duplicating (or, as before, faking) an editor here.
  Widget _myProfileLinkBuilder(final FamilyCircle circle) {
    return _cardBuilder(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: () => context.push(
          FamilyCircleProfileScreen.route,
          extra: const FamilyCircleProfileArgs(),
        ),
        leading: Icon(Icons.person_outline, color: _perGroupLabel),
        title: Text(
          'How this circle sees you',
          style: TextStyle(fontSize: 14.5.spMin, fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          'Your name, picture and colour in ${circle.name} — per circle, '
          'never shared with location data.',
          style: TextStyle(fontSize: 11.5.spMin, color: _muted),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _headerBuilder(
    final FamilyCircle circle,
    final Color beacon, {
    required final bool isOwner,
  }) {
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
                        'FAMILY CIRCLES',
                        style: TextStyle(
                          fontSize: 11.spMin,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        'Circle settings',
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
                if (isOwner)
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
              isOwner
                  ? '${circle.name} · live preview above'
                  : '${circle.name} · set by the host',
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
            'CIRCLE PICTURE',
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
                            'the home-screen widget. Without one the circle '
                            'wears its initial on the beacon colour.'
                      : 'Set by the host of ${circle.name}.',
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
    final Map<int, String> takenLabels, {
    required final bool isOwner,
  }) {
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
            'This colour marks the circle everywhere: member dots, snapshot '
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
                  enabled: isOwner,
                ),
            ],
          ),
          SizedBox(height: 13.spMin),
          Text(
            isOwner
                ? 'Colours used by your other circles are labelled so every '
                      'circle stays distinct.'
                : 'Only the host can change the beacon colour.',
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
    required final bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? () => setState(() => _picked = swatch) : null,
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
        ? context.showSuccessToast(message: 'Circle picture updated.')
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
        ? context.showSuccessToast(message: 'Circle picture removed.')
        : context.showErrorToast(
            message: 'Could not remove the picture. Please try again.',
          );
  }

  Future<void> _handleSave() async {
    final circle = ref.read(providerOfFamily).circle;
    if (circle == null) return;

    final picked = _picked;
    final newName = _nameController.text.trim();
    final name = newName.isEmpty || newName == circle.name ? null : newName;
    final themeColor = picked == null ? null : _hexOf(picked);
    final anyone = _anyoneCanRequest == circle.anyoneCanRequestSnapshot
        ? null
        : _anyoneCanRequest;
    final sosWhole =
        _sosWholeCircle == circle.sosToWholeGroup ? null : _sosWholeCircle;
    final snap =
        _snapPointsOnly == circle.journeysSnapPointsOnly ? null : _snapPointsOnly;

    if (name == null &&
        themeColor == null &&
        anyone == null &&
        sosWhole == null &&
        snap == null) {
      Navigator.of(context).maybePop();
      return;
    }

    setState(() => _isSaving = true);
    final ok = await ref.read(providerOfFamily.notifier).updateGroupSettings(
          name: name,
          themeColor: themeColor,
          anyoneCanRequestSnapshot: anyone,
          sosToWholeGroup: sosWhole,
          journeysSnapPointsOnly: snap,
        );
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      context.showSuccessToast(message: 'Circle settings saved');
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

}
