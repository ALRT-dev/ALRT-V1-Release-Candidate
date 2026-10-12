import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_app_bar.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_avatar.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_source_types.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Which part of the screen to land on. Arriving from "Daily check-in"
/// on the hub and landing on a nickname field is how people concluded the
/// feature did not exist. [sosLists] is kept for callers that still name
/// it; SOS lists now live on their own screen, so it lands at the top.
enum FamilyProfileSection { top, dailyCheckIn, sosLists }

class FamilyCircleProfileArgs {
  const FamilyCircleProfileArgs({this.section = FamilyProfileSection.top});

  final FamilyProfileSection section;
}

/// "How this group sees you" (12 Oct 2026 mockup): everything a member
/// sets for themselves in one group. Their picture, their name and colour
/// here, how much location this group may ever see, and their daily
/// check-in reminder.
///
/// Name and colour save with the one Save at the bottom; the sharing
/// level and reminders save on change, as they did on the screens this one
/// replaces (family_sharing_level_screen.dart stays routed).
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
    final groupName = ref.watch(
      providerOfFamily.select((s) => s.circle?.name ?? 'this group'),
    );
    if (me == null) return const SizedBox.shrink();

    final preview = me.copyWith(
      colorHex: _selectedColorHex ?? me.colorHex,
      name: _nicknameController.text.isEmpty
          ? me.name
          : _nicknameController.text,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FamilyWhiteAppBar(title: 'How $groupName sees you'),
      // Not a ListView: lazy lists only build what is on screen, so the
      // section keys below the fold had no context and the deep links from
      // the hub silently landed at the top. This screen is small; building
      // it all makes Scrollable.ensureVisible reliable.
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16.spMin,
          4.spMin,
          16.spMin,
          24.spMin + MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _photoCardBuilder(preview),
            _nameAndColourCardBuilder(),
            _sharingLevelCardBuilder(me.sharingLevel),
            _dailyReminderCardBuilder(me.id),
            SizedBox(height: 6.spMin),
            _saveButtonBuilder(),
          ],
        ),
      ),
    );
  }

  // ── Photo ────────────────────────────────────────────────────────────

  Widget _photoCardBuilder(final FamilyMember preview) {
    return _cardBuilder(
      child: Column(
        children: [
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                FamilyMemberAvatar(
                  member: preview,
                  size: 64,
                  showStatusDot: false,
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Semantics(
                    button: true,
                    label: 'Change photo',
                    child: InkWell(
                      key: const Key('profile-photo-edit'),
                      customBorder: const CircleBorder(),
                      onTap: _isSaving ? null : _changePhoto,
                      child: Container(
                        width: 26.spMin,
                        height: 26.spMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: FamilyColors.indigo,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          LucideIcons.pencil,
                          size: 12.spMin,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.spMin),
          Text(
            'Members only. Never on the map.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.spMin, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  // ── Name and colour ──────────────────────────────────────────────────

  Widget _nameAndColourCardBuilder() {
    return _cardBuilder(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabelBuilder('Your name in this group'),
          SizedBox(height: 6.spMin),
          TextField(
            key: const Key('profile-nickname'),
            controller: _nicknameController,
            maxLength: 30,
            enabled: !_isSaving,
            onChanged: (_) => setState(() {}),
            style: TextStyle(
              fontSize: 15.spMin,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
            decoration: InputDecoration(
              counterText: '',
              isDense: true,
              hintText: 'How this group sees you',
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
          _fieldLabelBuilder('Your colour'),
          SizedBox(height: 10.spMin),
          Wrap(
            spacing: 10.spMin,
            runSpacing: 10.spMin,
            children: [
              for (final color in FamilyColors.memberPalette)
                _swatchBuilder(color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _swatchBuilder(final Color color) {
    final hex = _toHex(color);
    final isSelected = _selectedColorHex?.toUpperCase() == hex;

    return GestureDetector(
      key: Key('profile-colour-$hex'),
      onTap: _isSaving
          ? null
          : () => setState(() => _selectedColorHex = hex),
      child: Container(
        width: 28.spMin,
        height: 28.spMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: isSelected
              ? const [BoxShadow(color: AppColors.ink, spreadRadius: 2)]
              : null,
        ),
        child: isSelected
            ? Icon(LucideIcons.check, color: Colors.white, size: 12.spMin)
            : null,
      ),
    );
  }

  // ── Sharing level ────────────────────────────────────────────────────

  /// Four radio cards onto the existing sharing level enum, saved on tap
  /// through the same call the sharing level screen uses.
  Widget _sharingLevelCardBuilder(final FamilySharingLevel current) {
    final isBusy = ref.watch(
      providerOfFamily.select((s) => s.memberUpdateState.isLoading),
    );
    return _cardBuilder(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelBuilder('MY SHARING LEVEL'),
          SizedBox(height: 10.spMin),
          for (final level in FamilySharingLevel.values)
            _levelCardBuilder(
              level,
              isSelected: current == level,
              enabled: !isBusy && !_isSaving,
            ),
        ],
      ),
    );
  }

  Widget _levelCardBuilder(
    final FamilySharingLevel level, {
    required final bool isSelected,
    required final bool enabled,
  }) {
    final (title, description) = switch (level) {
      FamilySharingLevel.precise => (
        'Exact',
        'A precise point when you choose to send one',
      ),
      FamilySharingLevel.approximate => (
        'Suburb only',
        'Never a precise pin, even in a check-in',
      ),
      FamilySharingLevel.alertsOnly => (
        'Alerts only',
        'Check in and SOS without any location',
      ),
      FamilySharingLevel.off => (
        'Off',
        'No location is ever shared with this group',
      ),
    };

    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: isSelected,
      child: GestureDetector(
        key: Key('sharing-${level.name}'),
        behavior: HitTestBehavior.opaque,
        onTap: enabled && !isSelected
            ? () =>
                  ref.read(providerOfFamily.notifier).updateSharingLevel(level)
            : null,
        child: Container(
          margin: EdgeInsets.only(bottom: 8.spMin),
          padding: EdgeInsets.symmetric(
            horizontal: 14.spMin,
            vertical: 12.spMin,
          ),
          decoration: BoxDecoration(
            color: isSelected ? FamilyColors.indigoLight : Colors.white,
            borderRadius: BorderRadius.circular(14.spMin),
            border: Border.all(
              color: isSelected ? FamilyColors.indigo : FamilyColors.v31Border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20.spMin,
                height: 20.spMin,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? FamilyColors.indigo
                        : FamilyColors.v31Border,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Container(
                        width: 10.spMin,
                        height: 10.spMin,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: FamilyColors.indigo,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 12.spMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 2.spMin),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12.5.spMin,
                        height: 1.35,
                        color: FamilyColors.v31Ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Daily check-in reminder ──────────────────────────────────────────

  Widget _dailyReminderCardBuilder(final String myMemberId) {
    final mySchedules = ref
        .watch(providerOfFamily.select((s) => s.scheduledCheckIns))
        .where((s) => s.memberId == myMemberId)
        .toList();

    return _cardBuilder(
      key: _dailyCheckInKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelBuilder('DAILY CHECK-IN REMINDER'),
          SizedBox(height: 10.spMin),
          for (final schedule in mySchedules)
            Container(
              key: Key('reminder-${schedule.id}'),
              margin: EdgeInsets.only(bottom: 8.spMin),
              padding: EdgeInsets.only(left: 14.spMin, right: 4.spMin),
              decoration: BoxDecoration(
                color: AppColors.extraLightGrey,
                borderRadius: BorderRadius.circular(12.spMin),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.alarmClock,
                    size: 18.spMin,
                    color: FamilyColors.indigo,
                  ),
                  SizedBox(width: 10.spMin),
                  Expanded(
                    child: Text(
                      schedule.timeOfDay,
                      style: TextStyle(
                        fontSize: 15.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove this reminder',
                    icon: Icon(
                      LucideIcons.trash2,
                      size: 18.spMin,
                      color: AppColors.grey,
                    ),
                    onPressed: () => _removeScheduledCheckIn(schedule),
                  ),
                ],
              ),
            ),
          if (mySchedules.length < _maxReminders)
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                key: const Key('reminder-add'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  side: const BorderSide(color: FamilyColors.v31Border),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.spMin,
                    vertical: 8.spMin,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.spMin),
                  ),
                ),
                onPressed: _isSaving ? null : _addScheduledCheckIn,
                icon: Icon(LucideIcons.plus, size: 15.spMin),
                label: Text(
                  'Add a time',
                  style: TextStyle(
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          SizedBox(height: 10.spMin),
          Text(
            'A reminder only, never a check-in on your behalf.',
            style: TextStyle(fontSize: 12.spMin, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _addScheduledCheckIn() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null || !mounted) return;

    final timeOfDay =
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
    // Prompted is the only mode: a scheduled job never posts a check-in
    // for anyone (master spec §11, R07). The device's IANA timezone is
    // not sent here: addScheduledCheckIn / the REST client take none yet
    // (see the report accompanying this change).
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

  // ── Save ─────────────────────────────────────────────────────────────

  Widget _saveButtonBuilder() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [FamilyColors.v31Indigo, FamilyColors.v31HeaderMid],
        ),
        borderRadius: BorderRadius.circular(16.spMin),
      ),
      child: SizedBox(
        height: 54.spMin,
        child: TextButton(
          key: const Key('profile-save'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.spMin),
            ),
          ),
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? SizedBox(
                  width: 20.spMin,
                  height: 20.spMin,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }

  // ── Shared pieces ────────────────────────────────────────────────────

  Widget _cardBuilder({final Key? key, required final Widget child}) {
    return Container(
      key: key,
      margin: EdgeInsets.only(bottom: 14.spMin),
      padding: EdgeInsets.all(16.spMin),
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
      child: child,
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

    if (saved) {
      context.showSuccessToast(message: 'Saved.');
      Navigator.of(context).pop();
    }
  }
}
