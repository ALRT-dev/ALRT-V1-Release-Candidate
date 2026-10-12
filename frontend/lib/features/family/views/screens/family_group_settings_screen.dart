import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_app_bar.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_group_avatar.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_source_types.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Group settings (12 Oct 2026 mockup): the ONE place a group's name,
/// rules, picture and colour are edited, plus the host's own actions on
/// the group (hand it over, close it, leave it).
///
/// The host edits; everyone else sees the same card read-only, so a member
/// learns where the settings live rather than finding a menu item that
/// fails. "How this group sees you" is a per-member thing and lives on the
/// circle profile screen, reached from the Family hub.
class FamilyGroupSettingsScreen extends ConsumerStatefulWidget {
  const FamilyGroupSettingsScreen({super.key});

  static const route = '/family-group-settings';

  @override
  ConsumerState<FamilyGroupSettingsScreen> createState() =>
      _FamilyGroupSettingsScreenState();
}

class _FamilyGroupSettingsScreenState
    extends ConsumerState<FamilyGroupSettingsScreen> {
  /// The ten colours a group can wear. Colours another group already uses
  /// are labelled rather than hidden, so every group stays distinct.
  static const _swatches = <Color>[
    FamilyColors.v31Indigo,
    Color(0xFFFF6B01),
    Color(0xFF16A46B),
    Color(0xFFE0362B),
    Color(0xFFF5A623),
    Color(0xFF4DA8FF),
    FamilyColors.v31HeaderGlow,
    Color(0xFFEC1C7D),
    Color(0xFF1D1D21),
    Color(0xFF8A8792),
  ];

  Color? _picked;
  bool _isSaving = false;

  // Name and rules are held here until Save, like the colour, so one tap
  // saves everything and Back discards everything.
  late final TextEditingController _nameController;
  bool? _anyoneCanRequest;
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
    _snapPointsOnly = circle.journeysSnapPointsOnly;
  }

  @override
  Widget build(BuildContext context) {
    // Closing or leaving the group from this screen drops the group out of
    // scope; this screen has nothing left to show, so it leaves too.
    ref.listen(providerOfFamily.select((s) => s.leaveDeleteState), (
      prev,
      next,
    ) {
      if (prev != next && next.isSuccess) Navigator.of(context).maybePop();
    });

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
      takenLabels[color.toARGB32()] = other.name
          .split(RegExp(r'\s+'))
          .first
          .toUpperCase();
    }

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomSafe = MediaQuery.viewPaddingOf(context).bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const FamilyWhiteAppBar(title: 'Group settings'),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16.spMin,
          4.spMin,
          16.spMin,
          24.spMin + (bottomInset > bottomSafe ? bottomInset : bottomSafe),
        ),
        children: [
          _nameAndRulesCardBuilder(
            circle,
            selected,
            takenLabels,
            isOwner: isOwner,
          ),
          if (isOwner) _hostingCardBuilder(circle),
        ],
      ),
    );
  }

  /// Picture, name, colour and the two rules, with Save at the bottom.
  /// Editable by the host only; members see the values so the rules are
  /// never a mystery.
  Widget _nameAndRulesCardBuilder(
    final FamilyCircle circle,
    final Color selected,
    final Map<int, String> takenLabels, {
    required final bool isOwner,
  }) {
    final hasPhoto = (circle.photoUrl ?? '').isNotEmpty;
    return _cardBuilder(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelBuilder('NAME AND RULES'),
          SizedBox(height: 12.spMin),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.spMin),
                child: FamilyGroupAvatar(
                  name: circle.name,
                  photoUrl: circle.photoUrl,
                  themeColorHex: _hexOf(selected),
                  size: 44.spMin,
                ),
              ),
              SizedBox(width: 12.spMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isOwner)
                      Row(
                        children: [
                          _outlinedBuilder(
                            key: 'group-photo',
                            label: 'Group photo',
                            icon: LucideIcons.camera,
                            onTap: _isSaving ? null : _changeGroupPhoto,
                          ),
                          if (hasPhoto) ...[
                            SizedBox(width: 8.spMin),
                            TextButton(
                              onPressed: _isSaving ? null : _removeGroupPhoto,
                              child: Text(
                                'Remove',
                                style: TextStyle(
                                  fontSize: 13.spMin,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.red,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    SizedBox(height: 4.spMin),
                    Text(
                      'Members only. Never on the map.',
                      style: TextStyle(
                        fontSize: 12.spMin,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.spMin),
          _fieldLabelBuilder('Group name'),
          SizedBox(height: 6.spMin),
          TextField(
            key: const Key('group-name'),
            controller: _nameController,
            maxLength: 50,
            textCapitalization: TextCapitalization.words,
            enabled: isOwner && !_isSaving,
            style: TextStyle(
              fontSize: 15.spMin,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
            decoration: InputDecoration(
              counterText: '',
              isDense: true,
              filled: true,
              fillColor: AppColors.extraLightGrey,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.spMin,
                vertical: 14.spMin,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.spMin),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 16.spMin),
          _fieldLabelBuilder('Group colour'),
          SizedBox(height: 10.spMin),
          Wrap(
            spacing: 10.spMin,
            runSpacing: 10.spMin,
            children: [
              for (final swatch in _swatches)
                _swatchBuilder(
                  swatch: swatch,
                  isSelected: swatch.toARGB32() == selected.toARGB32(),
                  takenBy: takenLabels[swatch.toARGB32()],
                  enabled: isOwner && !_isSaving,
                ),
            ],
          ),
          SizedBox(height: 10.spMin),
          _ruleBuilder(
            key: 'rule-anyone-can-ask',
            title: 'Anyone can ask for a snapshot',
            value: _anyoneCanRequest ?? circle.anyoneCanRequestSnapshot,
            isOwner: isOwner,
            onChanged: (value) => setState(() => _anyoneCanRequest = value),
          ),
          // No "SOS to whole group" rule (product owner, 8 Oct 2026): who
          // an SOS reaches is the sender's choice on the SOS screen.
          _ruleBuilder(
            key: 'rule-periodic-only',
            title: 'Journeys use periodic updates only',
            value: _snapPointsOnly ?? circle.journeysSnapPointsOnly,
            isOwner: isOwner,
            onChanged: (value) => setState(() => _snapPointsOnly = value),
          ),
          if (isOwner) ...[
            SizedBox(height: 14.spMin),
            SizedBox(
              height: 54.spMin,
              child: ElevatedButton(
                key: const Key('group-save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.orange.withValues(
                    alpha: 0.5,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.spMin),
                  ),
                ),
                onPressed: _isSaving ? null : _handleSave,
                child: Text(
                  _isSaving ? 'Saving...' : 'Save',
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ] else ...[
            SizedBox(height: 8.spMin),
            Text(
              'Only the host can change these.',
              style: TextStyle(fontSize: 12.spMin, color: AppColors.grey),
            ),
          ],
        ],
      ),
    );
  }

  /// The host's own moves: hand the group to someone, close it for
  /// everyone, or step back and leave it running for the others.
  Widget _hostingCardBuilder(final FamilyCircle circle) {
    return _cardBuilder(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _labelBuilder('HOSTING'),
          SizedBox(height: 12.spMin),
          _wideOutlinedBuilder(
            key: 'host-transfer',
            label: 'Hand the group to someone',
            onTap: _isSaving ? null : _showTransferHostingSheet,
          ),
          SizedBox(height: 10.spMin),
          _wideOutlinedBuilder(
            key: 'host-close',
            label: 'Close the group',
            onTap: _isSaving ? null : _confirmClose,
          ),
          // Leaving without naming a successor starts a 7-day host-transition
          // window instead of closing the group: a real, separate choice,
          // only offered when there is someone left to keep it running for.
          if (circle.members.length > 1) ...[
            SizedBox(height: 6.spMin),
            TextButton(
              key: const Key('host-leave'),
              onPressed: _isSaving ? null : () => _confirmStepBack(circle),
              child: Text(
                'Leave ${circle.name}',
                style: TextStyle(
                  fontSize: 15.spMin,
                  fontWeight: FontWeight.w700,
                  color: AppColors.red,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _labelBuilder(final String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11.spMin,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: AppColors.sectionLabel,
      ),
    );
  }

  Widget _fieldLabelBuilder(final String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.spMin,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
    );
  }

  Widget _ruleBuilder({
    required final String key,
    required final String title,
    required final bool value,
    required final bool isOwner,
    required final ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.spMin),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.spMin,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
          Switch(
            key: Key(key),
            value: value,
            activeTrackColor: FamilyColors.v31ToggleOn,
            inactiveTrackColor: FamilyColors.v31ToggleOff,
            inactiveThumbColor: Colors.white,
            onChanged: isOwner && !_isSaving ? onChanged : null,
          ),
        ],
      ),
    );
  }

  Widget _outlinedBuilder({
    required final String key,
    required final String label,
    required final IconData icon,
    required final VoidCallback? onTap,
  }) {
    return OutlinedButton.icon(
      key: Key(key),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: FamilyColors.v31Border),
        padding: EdgeInsets.symmetric(horizontal: 12.spMin, vertical: 8.spMin),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.spMin),
        ),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 15.spMin),
      label: Text(
        label,
        style: TextStyle(fontSize: 13.spMin, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _wideOutlinedBuilder({
    required final String key,
    required final String label,
    required final VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 50.spMin,
      child: OutlinedButton(
        key: Key(key),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: FamilyColors.v31Border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.spMin),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(fontSize: 15.spMin, fontWeight: FontWeight.w700),
        ),
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
        width: 28.spMin,
        height: 28.spMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: swatch,
          shape: BoxShape.circle,
          // The selected ring: a white gap then an ink ring, so it reads on
          // every swatch colour including the near-black one.
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: isSelected
              ? const [
                  BoxShadow(color: AppColors.ink, spreadRadius: 2),
                ]
              : null,
        ),
        child: isSelected
            ? Icon(LucideIcons.check, size: 12.spMin, color: Colors.white)
            : takenBy == null
            ? null
            : Text(
                takenBy.substring(0, 1),
                style: TextStyle(
                  fontSize: 9.spMin,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _cardBuilder({required final Widget child}) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
        border: Border.all(color: FamilyColors.v31Divider),
        boxShadow: const [
          BoxShadow(
            color: FamilyColors.v31CardShadow,
            blurRadius: 10.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.spMin),
      child: child,
    );
  }

  /// Picks and uploads a group picture. Applies immediately rather than
  /// waiting for Save: an image upload is its own action, and the group's
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
        ? context.showSuccessToast(message: 'Group photo updated.')
        : context.showErrorToast(
            message: 'Could not upload the photo. Please try again.',
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
        ? context.showSuccessToast(message: 'Group photo removed.')
        : context.showErrorToast(
            message: 'Could not remove the photo. Please try again.',
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
    final snap = _snapPointsOnly == circle.journeysSnapPointsOnly
        ? null
        : _snapPointsOnly;

    if (name == null &&
        themeColor == null &&
        anyone == null &&
        snap == null) {
      Navigator.of(context).maybePop();
      return;
    }

    setState(() => _isSaving = true);
    final ok = await ref
        .read(providerOfFamily.notifier)
        .updateGroupSettings(
          name: name,
          themeColor: themeColor,
          anyoneCanRequestSnapshot: anyone,
          journeysSnapPointsOnly: snap,
        );
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      context.showSuccessToast(message: 'Group settings saved');
      Navigator.of(context).maybePop();
    } else {
      context.showErrorToast(message: 'Could not save. Please try again.');
    }
  }

  /// Host-only (§29 TRANSFER): hand the group to an eligible member.
  /// Ineligible members are shown greyed with the reason, never hidden.
  /// The same provider calls as the hub's "Transfer hosting".
  Future<void> _showTransferHostingSheet() async {
    final candidates = await ref
        .read(providerOfFamily.notifier)
        .loadTransferCandidates();
    if (!mounted) return;
    if (candidates == null) {
      context.showErrorToast(
        message: 'Could not load members. Please try again.',
      );
      return;
    }
    if (candidates.candidates.isEmpty) {
      context.showErrorToast(
        message:
            'Invite someone first. There is no one to hand the group to yet.',
      );
      return;
    }

    final picked = await showModalBottomSheet<FamilyTransferCandidate>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.spMin)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.spMin, 20.spMin, 20.spMin, 12.spMin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hand the group to someone',
                style: TextStyle(
                  fontSize: 17.spMin,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.spMin),
              Text(
                'The new host runs invites and group settings. How the group '
                'is paid for does not change, and you stay on as a member.',
                style: TextStyle(
                  fontSize: 12.5.spMin,
                  color: AppColors.mediumGrey,
                ),
              ),
              SizedBox(height: 8.spMin),
              ...candidates.candidates.map(
                (candidate) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  enabled: candidate.eligible,
                  onTap: candidate.eligible
                      ? () => Navigator.of(sheetContext).pop(candidate)
                      : null,
                  leading: CircleAvatar(
                    radius: 18.spMin,
                    backgroundColor: FamilyColors.indigo.withValues(
                      alpha: candidate.eligible ? 0.15 : 0.06,
                    ),
                    foregroundImage: candidate.profilePictureUrl != null
                        ? NetworkImage(candidate.profilePictureUrl!)
                        : null,
                    child: Text(
                      candidate.name.isEmpty
                          ? '?'
                          : candidate.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 14.spMin,
                        fontWeight: FontWeight.w700,
                        color: candidate.eligible
                            ? FamilyColors.indigo
                            : AppColors.grey,
                      ),
                    ),
                  ),
                  title: Text(
                    candidate.name,
                    style: TextStyle(
                      fontSize: 14.5.spMin,
                      fontWeight: FontWeight.w600,
                      color: candidate.eligible
                          ? Colors.black87
                          : AppColors.grey,
                    ),
                  ),
                  subtitle: candidate.eligible
                      ? null
                      : Text(
                          candidate.reason ?? 'Not eligible right now',
                          style: TextStyle(
                            fontSize: 11.5.spMin,
                            color: AppColors.grey,
                          ),
                        ),
                  trailing: candidate.eligible
                      ? Icon(
                          LucideIcons.chevronRight,
                          size: 18.spMin,
                          color: AppColors.grey,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || !mounted) return;

    var confirmed = false;
    await showConfirmationSheet(
      context: context,
      title: 'Hand the group to ${picked.name}?',
      description:
          '${picked.name} will run invites and group settings. Everything '
          'keeps working, how the group is paid for does not change, and '
          'you stay on as a member. Only ${picked.name} can hand hosting '
          'back.',
      confirmButtonText: 'Transfer hosting',
      onPressedConfirm: (_, __) => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    final ok = await ref
        .read(providerOfFamily.notifier)
        .transferOwnership(newOwnerMemberId: picked.memberId);
    if (!mounted) return;
    ok
        ? context.showSuccessToast(
            message: '${picked.name} is now hosting this group.',
          )
        : context.showErrorToast(
            message: 'Could not transfer hosting. Please try again.',
          );
  }

  /// Closing a group for everyone is a different decision from leaving
  /// one, so it keeps the plain destructive confirmation (the hub's).
  Future<void> _confirmClose() {
    return showConfirmationSheet(
      context: context,
      title: 'Close this group for everyone?',
      description:
          'Everyone is removed and the group is deleted. Snapshots and '
          'journeys in it are gone; SOS history keeps time and duration '
          'only.',
      confirmButtonText: 'Close group',
      onPressedConfirm: (_, __) =>
          ref.read(providerOfFamily.notifier).deleteCircle(),
    );
  }

  /// The host leaving without naming a successor first: the group stays
  /// active for everyone else, with a 7-day window for an eligible member
  /// to take over before invites and settings lock (the hub's "Step back
  /// as host", word for word).
  Future<void> _confirmStepBack(final FamilyCircle circle) {
    return showConfirmationSheet(
      context: context,
      title: 'Leave ${circle.name} as host?',
      description:
          "You'll leave the group. Everyone else keeps SOS, check-ins, "
          'journeys and the member list. An eligible member has 7 days '
          'to take over hosting; if nobody does, invites and group '
          'settings lock, but nothing else changes and nobody is removed.',
      confirmButtonText: 'Leave group',
      onPressedConfirm: (_, __) => ref.read(providerOfFamily.notifier).leave(),
    );
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
