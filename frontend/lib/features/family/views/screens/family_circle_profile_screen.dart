import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/screens/family_sharing_level_screen.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_lists_screen.dart';
import 'package:hazard_app/features/family/views/widgets/family_board_kit.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_avatar.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_source_types.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Which part of the screen to land on. Arriving from "Daily" on the hub
/// lands on the DAILY CHECK-IN card. [sosLists] is kept for callers that
/// still name it; SOS lists live on their own screen, reached from the SOS
/// row here, so it lands at the top.
enum FamilyProfileSection { top, dailyCheckIn, sosLists }

class FamilyCircleProfileArgs {
  const FamilyCircleProfileArgs({this.section = FamilyProfileSection.top});

  final FamilyProfileSection section;
}

/// "My profile in this circle" (CircleProfile board): everything a member
/// sets for themselves in one group.
///
/// 1. A card with the photo ("Your photo", group members only), the
///    nickname, five colour dots and Save.
/// 2. SHARING LEVEL: one row into "Your sharing level".
/// 3. DAILY CHECK-IN: the reminder times, a time and "Add check-in time"
///    (up to 3, reminders only).
/// 4. SOS: "Who your SOS reaches", into the SOS lists.
class FamilyCircleProfileScreen extends ConsumerStatefulWidget {
  const FamilyCircleProfileScreen({super.key, this.args});

  static const route = '/family-circle-profile';

  final FamilyCircleProfileArgs? args;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FamilyCircleProfileScreenState();
}

class _FamilyCircleProfileScreenState
    extends ConsumerState<FamilyCircleProfileScreen> {
  /// At most this many daily reminders per person per group.
  static const _maxReminders = 3;

  late final TextEditingController _nicknameController;
  String? _selectedColorHex;
  bool _isSaving = false;

  /// The time the "Add check-in time" button will add.
  TimeOfDay _pendingTime = const TimeOfDay(hour: 9, minute: 0);

  final _dailyCheckInKey = GlobalKey();

  static String _toHex(final Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  @override
  void initState() {
    super.initState();
    final me = ref.read(providerOfFamily).circle?.me;
    _nicknameController = TextEditingController(text: me?.name ?? '');
    _selectedColorHex = me?.colorHex;
    Future.microtask(() {
      ref.read(providerOfFamily.notifier).loadScheduledCheckIns();
    });
    _scrollToRequestedSection();
  }

  /// Lands on the section the caller asked for, once there is a frame to
  /// measure. Anything missing just leaves the screen at the top.
  void _scrollToRequestedSection() {
    final section = widget.args?.section ?? FamilyProfileSection.top;
    if (section != FamilyProfileSection.dailyCheckIn) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _dailyCheckInKey.currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(providerOfFamily.select((s) => s.circle?.me));
    if (me == null) return const SizedBox.shrink();

    final preview = me.copyWith(
      colorHex: _selectedColorHex ?? me.colorHex,
      name: _nicknameController.text.isEmpty
          ? me.name
          : _nicknameController.text,
    );

    return FamilyBoardScaffold(
      title: 'My profile in this circle',
      children: [
        _profileCardBuilder(preview),
        FamilyBoardGroup(
          title: 'Sharing level',
          rows: [
            FamilyBoardRow(
              key: const Key('sharing-open'),
              title: FamilySharingLevelScreen.labelsOf(me.sharingLevel).$1,
              subtitle: 'What this circle can see when you share',
              onTap: () => context.push(FamilySharingLevelScreen.route),
            ),
          ],
        ),
        KeyedSubtree(
          key: _dailyCheckInKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FamilyBoardLabel('Daily check-in'),
              SizedBox(height: 8.spMin),
              _dailyCheckInCardBuilder(me.id),
            ],
          ),
        ),
        FamilyBoardGroup(
          title: 'SOS',
          rows: [
            FamilyBoardRow(
              key: const Key('soslists-open'),
              title: 'Who your SOS reaches',
              subtitle: 'Set lists so you never choose in an emergency',
              onTap: () => context.push(FamilySosListsScreen.route),
            ),
          ],
        ),
      ],
    );
  }

  // ── Photo, nickname, colour ──────────────────────────────────────────

  Widget _profileCardBuilder(final FamilyMember preview) {
    return FamilyBoardCard(
      children: [
        Row(
          children: [
            FamilyMemberAvatar(
              member: preview,
              size: 52,
              showStatusDot: false,
            ),
            SizedBox(width: 12.spMin),
            FamilyBoardSmallButton(
              key: const Key('profile-photo-edit'),
              label: 'Your photo',
              onPressed: _isSaving ? null : _changePhoto,
            ),
            SizedBox(width: 12.spMin),
            Expanded(
              child: Text(
                'Group members only.',
                style: TextStyle(
                  fontSize: 12.spMin,
                  color: AppColors.mediumGrey,
                ),
              ),
            ),
          ],
        ),
        TextField(
          key: const Key('profile-nickname'),
          controller: _nicknameController,
          maxLength: 30,
          enabled: !_isSaving,
          onChanged: (_) => setState(() {}),
          style: familyBoardInputStyle(),
          decoration: familyBoardInputDecoration('Nickname'),
        ),
        Padding(
          padding: EdgeInsets.all(5.spMin),
          child: Wrap(
            spacing: 14.spMin,
            runSpacing: 14.spMin,
            children: [
              for (final color in FamilyColors.boardMemberSwatches)
                _swatchBuilder(color),
            ],
          ),
        ),
        FamilyBoardSmallButton(
          key: const Key('profile-save'),
          label: _isSaving ? 'Saving...' : 'Save',
          onPressed: _isSaving ? null : _save,
        ),
      ],
    );
  }

  Widget _swatchBuilder(final Color color) {
    final hex = _toHex(color);
    final isSelected = _selectedColorHex?.toUpperCase() == hex;

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Colour $hex',
      child: GestureDetector(
        key: Key('profile-colour-$hex'),
        onTap: _isSaving
            ? null
            : () => setState(() => _selectedColorHex = hex),
        child: Container(
          width: 32.spMin,
          height: 32.spMin,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            // White gap, then a ring in the dot's own colour.
            boxShadow: isSelected
                ? [
                    BoxShadow(color: color, spreadRadius: 5),
                    const BoxShadow(color: Colors.white, spreadRadius: 3),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  // ── Daily check-in ───────────────────────────────────────────────────

  Widget _dailyCheckInCardBuilder(final String myMemberId) {
    final mySchedules = ref
        .watch(providerOfFamily.select((s) => s.scheduledCheckIns))
        .where((s) => s.memberId == myMemberId)
        .toList();

    return FamilyBoardCard(
      children: [
        for (final schedule in mySchedules)
          Row(
            key: Key('reminder-${schedule.id}'),
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.timeOfDay,
                      style: TextStyle(
                        fontSize: 16.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const FamilyBoardMuted(
                      'Reminds you to check in',
                      size: 12,
                    ),
                  ],
                ),
              ),
              FamilyBoardSmallButton(
                label: 'Remove',
                onPressed: () => _removeScheduledCheckIn(schedule),
              ),
            ],
          ),
        if (mySchedules.length < _maxReminders)
          Row(
            children: [
              _timeFieldBuilder(),
              SizedBox(width: 8.spMin),
              FamilyBoardSmallButton(
                key: const Key('reminder-add'),
                label: 'Add check-in time',
                onPressed: _isSaving ? null : _addScheduledCheckIn,
              ),
            ],
          ),
        const FamilyBoardMuted(
          'Up to 3. Reminders only: ALRT never checks in for you. Times are '
          'in your local time.',
          size: 12,
        ),
      ],
    );
  }

  /// The time box the board shows ("09:00 AM" and a clock): tapping it
  /// opens the time picker; "Add check-in time" then adds it.
  Widget _timeFieldBuilder() {
    return Semantics(
      button: true,
      label: 'Reminder time',
      child: InkWell(
        key: const Key('reminder-time'),
        borderRadius: BorderRadius.circular(10.spMin),
        onTap: _pickTime,
        child: Container(
          height: 40.spMin,
          padding: EdgeInsets.symmetric(horizontal: 10.spMin),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.spMin),
            border: Border.all(color: AppColors.lightGrey, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _pendingTime.format(context),
                style: TextStyle(
                  fontSize: 15.spMin,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink,
                ),
              ),
              SizedBox(width: 10.spMin),
              Icon(LucideIcons.clock, size: 16.spMin, color: AppColors.ink),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _pendingTime,
    );
    if (time == null || !mounted) return;
    setState(() => _pendingTime = time);
  }

  Future<void> _addScheduledCheckIn() async {
    final time = _pendingTime;
    final timeOfDay =
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
    // Prompted is the only mode: a scheduled job never posts a check-in
    // for anyone (master spec §11, R07). The device's IANA timezone is
    // not sent here: addScheduledCheckIn / the REST client take none yet.
    final added = await ref
        .read(providerOfFamily.notifier)
        .addScheduledCheckIn(
          timeOfDay: timeOfDay,
          mode: FamilyScheduledCheckInMode.prompted,
        );
    if (!mounted) return;

    added
        ? context.showSuccessToast(message: 'Daily reminder set for $timeOfDay.')
        : context.showErrorToast(
            message: 'Could not save the reminder time. Please try again.',
          );
  }

  Future<void> _removeScheduledCheckIn(
    final FamilyScheduledCheckIn schedule,
  ) async {
    final removed = await ref
        .read(providerOfFamily.notifier)
        .removeScheduledCheckIn(scheduledCheckInId: schedule.id);
    if (!mounted || removed) return;
    context.showErrorToast(
      message: 'Could not remove the reminder. Please try again.',
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────

  Future<void> _changePhoto() async {
    final medias = await showImagePickerBottomSheet(context: context);
    final media = medias?.firstOrNull;
    if (media == null || media.source != AlrtMediaSource.file) return;
    if (!mounted) return;

    setState(() => _isSaving = true);
    final uploaded = await ref
        .read(providerOfFamily.notifier)
        .updateMyPhoto(File(media.value));
    if (!mounted) return;
    setState(() => _isSaving = false);

    uploaded
        ? context.showSuccessToast(message: 'Photo updated.')
        : context.showErrorToast(
            message: 'Could not upload the photo. Please try again.',
          );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final saved = await ref
        .read(providerOfFamily.notifier)
        .updateMyProfile(
          nickname: _nicknameController.text.trim().isEmpty
              ? null
              : _nicknameController.text.trim(),
          colorHex: _selectedColorHex,
        );
    if (!mounted) return;
    setState(() => _isSaving = false);

    // A failure is reported by the hub's memberUpdateState listener.
    if (saved) context.showSuccessToast(message: 'Saved.');
  }
}
