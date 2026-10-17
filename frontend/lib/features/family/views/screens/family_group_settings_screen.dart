import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_board_kit.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_leave_confirm_sheet.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_source_types.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/others/app_colors.dart';

/// Group settings (GroupSettings board).
///
/// NAME AND RULES: the group photo (host only, "Members only. Never on the
/// map."), the name, the two rules as switches, and Save (host only).
/// HOSTING: the host hands the circle to someone or closes it; a member
/// sees who hosts it. Everyone can leave. Members see the values
/// read-only under "Only the host can change these."
class FamilyGroupSettingsScreen extends ConsumerStatefulWidget {
  const FamilyGroupSettingsScreen({super.key});

  static const route = '/family-group-settings';

  @override
  ConsumerState<FamilyGroupSettingsScreen> createState() =>
      _FamilyGroupSettingsScreenState();
}

class _FamilyGroupSettingsScreenState
    extends ConsumerState<FamilyGroupSettingsScreen> {
  bool _isSaving = false;

  // Name and rules are held here until Save, so one tap saves everything
  // and Back discards everything.
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
    if (circle == null) return const SizedBox.shrink();
    _seedFrom(circle);

    final isOwner = circle.me?.role == FamilyRole.owner;

    return FamilyBoardScaffold(
      title: 'Group settings',
      children: [
        if (!isOwner) const FamilyBoardNote('Only the host can change these.'),
        _section('Name and rules', _nameAndRulesCardBuilder(circle, isOwner)),
        _section('Hosting', _hostingCardBuilder(circle, isOwner)),
      ],
    );
  }

  Widget _section(final String label, final Widget card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FamilyBoardLabel(label),
        SizedBox(height: 8.spMin),
        card,
      ],
    );
  }

  Widget _nameAndRulesCardBuilder(
    final FamilyCircle circle,
    final bool isOwner,
  ) {
    return FamilyBoardCard(
      children: [
        if (isOwner)
          Row(
            children: [
              _photoTileBuilder(circle.photoUrl, size: 44, radius: 14),
              SizedBox(width: 12.spMin),
              FamilyBoardSmallButton(
                key: const Key('group-photo'),
                label: 'Group photo',
                onPressed: _isSaving ? null : () => _openGroupPhotoSheet(circle),
              ),
              SizedBox(width: 12.spMin),
              Expanded(
                child: Text(
                  'Members only. Never on the map.',
                  style: TextStyle(
                    fontSize: 12.spMin,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ),
            ],
          ),
        TextField(
          key: const Key('group-name'),
          controller: _nameController,
          maxLength: 50,
          textCapitalization: TextCapitalization.words,
          enabled: isOwner && !_isSaving,
          style: familyBoardInputStyle(),
          decoration: familyBoardInputDecoration('Group name'),
        ),
        FamilyBoardToggleRow(
          switchKey: const Key('rule-anyone-can-ask'),
          title: 'Anyone can ask for a snapshot',
          value: _anyoneCanRequest ?? circle.anyoneCanRequestSnapshot,
          onChanged: isOwner && !_isSaving
              ? (value) => setState(() => _anyoneCanRequest = value)
              : null,
        ),
        // No "SOS to whole group" rule (product owner, 8 Oct 2026): who
        // an SOS reaches is the sender's choice on the SOS screen.
        FamilyBoardToggleRow(
          switchKey: const Key('rule-periodic-only'),
          title: 'Journeys use periodic updates only',
          value: _snapPointsOnly ?? circle.journeysSnapPointsOnly,
          onChanged: isOwner && !_isSaving
              ? (value) => setState(() => _snapPointsOnly = value)
              : null,
        ),
        if (isOwner)
          FamilyBoardPrimaryButton(
            key: const Key('group-save'),
            label: 'Save',
            busy: _isSaving,
            onPressed: _handleSave,
          ),
      ],
    );
  }

  /// The host hands the circle on or closes it; everyone can leave.
  Widget _hostingCardBuilder(final FamilyCircle circle, final bool isOwner) {
    final hostName = circle.members
        .where((m) => m.role == FamilyRole.owner)
        .firstOrNull
        ?.name;
    // A host alone in the circle closes it rather than leaving it empty.
    final canLeave = !isOwner || circle.members.length > 1;

    return FamilyBoardCard(
      children: [
        if (isOwner) ...[
          FamilyBoardSecondaryButton(
            key: const Key('host-transfer'),
            label: 'Hand the circle to someone',
            onPressed: _isSaving ? null : _showTransferHostingSheet,
          ),
          FamilyBoardSecondaryButton(
            key: const Key('host-close'),
            label: 'Close the circle',
            onPressed: _isSaving ? null : _confirmClose,
          ),
        ] else
          FamilyBoardMuted(
            hostName == null ? 'Hosted by someone else.' : 'Hosted by $hostName.',
          ),
        if (canLeave)
          FamilyBoardSecondaryButton(
            key: const Key('host-leave'),
            label: 'Leave ${circle.name}',
            onPressed: _isSaving ? null : () => _confirmLeave(circle, isOwner),
          ),
      ],
    );
  }

  Widget _photoTileBuilder(
    final String? photoUrl, {
    required final double size,
    required final double radius,
  }) {
    final hasPhoto = (photoUrl ?? '').isNotEmpty;
    return Container(
      width: size.spMin,
      height: size.spMin,
      decoration: BoxDecoration(
        color: FamilyColors.boardIndigoWash,
        borderRadius: BorderRadius.circular(radius.spMin),
        image: hasPhoto
            ? DecorationImage(
                image: NetworkImage(photoUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
    );
  }

  // ── Group photo sheet (GroupPhoto board) ────────────────────────────

  Future<void> _openGroupPhotoSheet(final FamilyCircle circle) async {
    final outcome = await showFamilyBoardSheet<String>(
      context: context,
      builder: (sheetContext) => [
        const FamilyBoardSheetTitle(
          'Group photo',
          subtitle: 'Shown to members of this group only.',
        ),
        _GroupPhotoSheetBody(photoUrl: circle.photoUrl),
      ],
    );
    if (!mounted || outcome == null) return;
    switch (outcome) {
      case _GroupPhotoSheetBody.saved:
        context.showSuccessToast(message: 'Group photo updated.');
      case _GroupPhotoSheetBody.removed:
        context.showSuccessToast(message: 'Group photo removed.');
      case _GroupPhotoSheetBody.failed:
        context.showErrorToast(
          message: 'Could not update the photo. Please try again.',
        );
    }
  }

  // ── Save ─────────────────────────────────────────────────────────────

  Future<void> _handleSave() async {
    final circle = ref.read(providerOfFamily).circle;
    if (circle == null) return;

    final newName = _nameController.text.trim();
    final name = newName.isEmpty || newName == circle.name ? null : newName;
    final anyone = _anyoneCanRequest == circle.anyoneCanRequestSnapshot
        ? null
        : _anyoneCanRequest;
    final snap = _snapPointsOnly == circle.journeysSnapPointsOnly
        ? null
        : _snapPointsOnly;

    if (name == null && anyone == null && snap == null) {
      Navigator.of(context).maybePop();
      return;
    }

    setState(() => _isSaving = true);
    final ok = await ref
        .read(providerOfFamily.notifier)
        .updateGroupSettings(
          name: name,
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

  // ── Hosting ──────────────────────────────────────────────────────────

  /// Host only (§29 TRANSFER): "Hand the circle to", one row per member.
  /// Members who cannot take over are shown with the reason, never hidden.
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

    final picked = await showFamilyBoardSheet<FamilyTransferCandidate>(
      context: context,
      builder: (sheetContext) => [
        const FamilyBoardSheetTitle('Hand the circle to'),
        if (candidates.candidates.isEmpty)
          const FamilyBoardCard(
            children: [FamilyBoardMuted('Nobody else is in this circle yet.')],
          )
        else
          FamilyBoardGroup(
            rows: [
              for (final candidate in candidates.candidates)
                FamilyBoardRow(
                  key: Key('cand-${candidate.memberId}'),
                  title: candidate.name,
                  subtitle: candidate.eligible
                      ? null
                      : candidate.reason ?? 'Not eligible right now',
                  trailing: candidate.eligible ? null : const SizedBox.shrink(),
                  onTap: candidate.eligible
                      ? () => Navigator.of(sheetContext).pop(candidate)
                      : null,
                ),
            ],
          ),
        FamilyBoardGhostButton(
          label: 'Cancel',
          onPressed: () => Navigator.of(sheetContext).pop(),
        ),
      ],
    );
    if (picked == null || !mounted) return;

    var confirmed = false;
    await showConfirmationSheet(
      context: context,
      title: 'Hand the circle to ${picked.name}?',
      description:
          '${picked.name} will run invites and group settings. Everything '
          'keeps working, how the group is paid for does not change, and '
          'you stay on as a member. Only ${picked.name} can hand hosting '
          'back.',
      confirmButtonText: 'Hand it over',
      onPressedConfirm: (_, __) => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    final ok = await ref
        .read(providerOfFamily.notifier)
        .transferOwnership(newOwnerMemberId: picked.memberId);
    if (!mounted) return;
    ok
        ? context.showSuccessToast(
            message: '${picked.name} is now hosting this circle.',
          )
        : context.showErrorToast(
            message: 'Could not hand over hosting. Please try again.',
          );
  }

  /// Closing a circle for everyone is a different decision from leaving
  /// one, so it keeps the plain destructive confirmation.
  Future<void> _confirmClose() {
    return showConfirmationSheet(
      context: context,
      title: 'Close this circle for everyone?',
      description:
          'Everyone is removed and the circle is deleted. Snapshots and '
          'journeys in it are gone. SOS history keeps time and duration '
          'only.',
      confirmButtonText: 'Close the circle',
      onPressedConfirm: (_, __) =>
          ref.read(providerOfFamily.notifier).deleteCircle(),
    );
  }

  /// The Leave sheet (LeaveSheet board). A host leaving without naming a
  /// successor starts the 7 day host hand-over; the sheet says so.
  Future<void> _confirmLeave(final FamilyCircle circle, final bool isOwner) async {
    final myMemberId = circle.myMemberId;
    final sosListCount = ref
        .read(providerOfFamily)
        .sosLists
        .where((list) => list.memberIds.contains(myMemberId))
        .length;
    final shouldLeave = await showFamilyLeaveConfirmSheet(
      context: context,
      circleName: circle.name,
      sosListCount: sosListCount,
      isHost: isOwner,
    );
    if (!shouldLeave || !mounted) return;
    await ref.read(providerOfFamily.notifier).leave();
  }
}

/// The GroupPhoto sheet's body: the preview tile, "Choose a photo", Save,
/// "Remove photo" when there is one, and Close. Pops with [saved],
/// [removed] or [failed]; Close pops with nothing.
class _GroupPhotoSheetBody extends ConsumerStatefulWidget {
  const _GroupPhotoSheetBody({required this.photoUrl});

  static const saved = 'saved';
  static const removed = 'removed';
  static const failed = 'failed';

  final String? photoUrl;

  @override
  ConsumerState<_GroupPhotoSheetBody> createState() =>
      _GroupPhotoSheetBodyState();
}

class _GroupPhotoSheetBodyState extends ConsumerState<_GroupPhotoSheetBody> {
  File? _picked;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final picked = _picked;
    final url = widget.photoUrl;
    final hasPhoto = (url ?? '').isNotEmpty;
    final ImageProvider? image = picked != null
        ? FileImage(picked)
        : hasPhoto
        ? NetworkImage(url!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              key: const Key('gphoto-preview'),
              width: 72.spMin,
              height: 72.spMin,
              decoration: BoxDecoration(
                color: FamilyColors.boardIndigoWash,
                borderRadius: BorderRadius.circular(20.spMin),
                image: image == null
                    ? null
                    : DecorationImage(image: image, fit: BoxFit.cover),
              ),
            ),
            SizedBox(width: 14.spMin),
            Expanded(
              child: FamilyBoardSecondaryButton(
                key: const Key('gphoto-choose'),
                label: 'Choose a photo',
                onPressed: _busy ? null : _choose,
              ),
            ),
          ],
        ),
        SizedBox(height: 14.spMin),
        FamilyBoardPrimaryButton(
          key: const Key('gphoto-save'),
          label: 'Save',
          busy: _busy,
          onPressed: _save,
        ),
        if (hasPhoto && picked == null)
          FamilyBoardGhostButton(
            label: 'Remove photo',
            onPressed: _busy ? null : _remove,
          ),
        FamilyBoardGhostButton(
          label: 'Close',
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Future<void> _choose() async {
    final medias = await showImagePickerBottomSheet(context: context);
    final media = medias?.firstOrNull;
    if (media == null || media.source != AlrtMediaSource.file) return;
    if (!mounted) return;
    setState(() => _picked = File(media.value));
  }

  Future<void> _save() async {
    final picked = _picked;
    if (picked == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _busy = true);
    final ok = await ref
        .read(providerOfFamily.notifier)
        .updateGroupPhoto(picked);
    if (!mounted) return;
    Navigator.of(
      context,
    ).pop(ok ? _GroupPhotoSheetBody.saved : _GroupPhotoSheetBody.failed);
  }

  Future<void> _remove() async {
    setState(() => _busy = true);
    final ok = await ref.read(providerOfFamily.notifier).removeGroupPhoto();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pop(ok ? _GroupPhotoSheetBody.removed : _GroupPhotoSheetBody.failed);
  }
}
