import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_header_surface.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_avatar.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_source_types.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Which part of the screen to land on. Arriving from "Daily check-in"
/// on the hub and landing on a nickname field is how people concluded the
/// feature did not exist.
enum FamilyProfileSection { top, dailyCheckIn, sosLists }

class FamilyCircleProfileArgs {
  const FamilyCircleProfileArgs({this.section = FamilyProfileSection.top});

  final FamilyProfileSection section;
}

/// Everything a member sets for themselves in one circle: their picture and
/// nickname here, their accent colour, their daily check-in, and who their
/// SOS reaches.
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
  late final TextEditingController _nicknameController;
  String? _selectedColorHex;
  bool _isSaving = false;

  final _dailyCheckInKey = GlobalKey();
  final _sosListsKey = GlobalKey();

  static String _toHex(final Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  @override
  void initState() {
    super.initState();
    final me = ref.read(providerOfFamily).circle?.me;
    _nicknameController = TextEditingController(text: me?.name ?? '');
    _selectedColorHex = me?.colorHex;
    Future.microtask(() {
      ref.read(providerOfFamily.notifier)
        ..loadScheduledCheckIns()
        ..loadSosLists();
    });
    _scrollToRequestedSection();
  }

  /// Lands on the section the caller asked for, once there is a frame to
  /// measure. Anything missing just leaves the screen at the top.
  void _scrollToRequestedSection() {
    final section = widget.args?.section ?? FamilyProfileSection.top;
    if (section == FamilyProfileSection.top) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = section == FamilyProfileSection.dailyCheckIn
          ? _dailyCheckInKey
          : _sosListsKey;
      final context = key.currentContext;
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

    return Scaffold(
      backgroundColor: FamilyColors.v31Page,
      appBar: const FamilyAppBar(title: 'My profile in this circle'),
      // Not a ListView: lazy lists only build what is on screen, so the
      // section keys below the fold had no context and the deep links from
      // the hub silently landed at the top. This screen is small; building
      // it all makes Scrollable.ensureVisible reliable.
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.spMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          _identityHeroBuilder(preview),
          SizedBox(height: 16.spMin),
          Text(
            'NICKNAME',
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: 8.spMin),
          TextField(
            controller: _nicknameController,
            maxLength: 30,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              counterText: '',
              hintText: 'How your family sees you',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.spMin),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 20.spMin),
          Text(
            'YOUR COLOUR',
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: 4.spMin),
          Text(
            'Shown as your avatar ring and your pin on the family map.',
            style: TextStyle(fontSize: 12.spMin, color: AppColors.grey),
          ),
          SizedBox(height: 12.spMin),
          Wrap(
            spacing: 12.spMin,
            runSpacing: 12.spMin,
            children: [
              for (final color in FamilyColors.memberPalette)
                _swatchBuilder(color),
            ],
          ),
          SizedBox(height: 20.spMin),
          Text(
            'DAILY CHECK-IN',
            key: _dailyCheckInKey,
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: 4.spMin),
          Text(
            'A daily reminder to let your family know you are safe.',
            style: TextStyle(fontSize: 12.spMin, color: AppColors.grey),
          ),
          SizedBox(height: 8.spMin),
          _scheduledCheckInsBuilder(),
          SizedBox(height: 20.spMin),
          Text(
            'SOS LISTS',
            key: _sosListsKey,
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: 4.spMin),
          Text(
            'Who your SOS reaches. Set up in advance — never during an '
            'emergency.',
            style: TextStyle(fontSize: 12.spMin, color: AppColors.grey),
          ),
          SizedBox(height: 8.spMin),
          _sosListsBuilder(),
          SizedBox(height: 28.spMin),
          SizedBox(
            height: 52.spMin,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: FamilyColors.indigo,
                foregroundColor: Colors.white,
                elevation: 0,
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
          ],
        ),
      ),
    );
  }

  Widget _scheduledCheckInsBuilder() {
    final me = ref.read(providerOfFamily).circle?.me;
    final mySchedules = ref
        .watch(providerOfFamily.select((s) => s.scheduledCheckIns))
        .where((s) => s.memberId == me?.id)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final schedule in mySchedules)
          Container(
            margin: EdgeInsets.only(bottom: 8.spMin),
            padding: EdgeInsets.symmetric(horizontal: 14.spMin),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.spMin),
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
                    '${schedule.timeOfDay} — '
                    '${schedule.mode == FamilyScheduledCheckInMode.automatic ? 'checks in for you' : 'reminds you'}',
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.trash2,
                    size: 18.spMin,
                    color: AppColors.grey,
                  ),
                  onPressed: () => ref
                      .read(providerOfFamily.notifier)
                      .removeScheduledCheckIn(scheduledCheckInId: schedule.id),
                ),
              ],
            ),
          ),
        TextButton.icon(
          onPressed: _addScheduledCheckIn,
          icon: Icon(LucideIcons.plus, size: 16.spMin),
          label: Text(
            'Add check-in time',
            style: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w700),
          ),
          style: TextButton.styleFrom(foregroundColor: FamilyColors.indigo),
        ),
      ],
    );
  }

  Future<void> _addScheduledCheckIn() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null || !mounted) return;

    final mode = await showModalBottomSheet<FamilyScheduledCheckInMode>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.spMin)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.spMin),
            ListTile(
              leading: const Icon(LucideIcons.bellRing),
              title: const Text('Remind me to check in'),
              subtitle: const Text('You get a one-tap "I\'m safe" prompt'),
              onTap: () => Navigator.of(
                sheetContext,
              ).pop(FamilyScheduledCheckInMode.prompted),
            ),
            ListTile(
              leading: const Icon(LucideIcons.checkCheck),
              title: const Text('Check in for me automatically'),
              subtitle: const Text('Your family sees you as safe at this time'),
              onTap: () => Navigator.of(
                sheetContext,
              ).pop(FamilyScheduledCheckInMode.automatic),
            ),
            SizedBox(height: 8.spMin),
          ],
        ),
      ),
    );
    if (mode == null || !mounted) return;

    final timeOfDay =
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
    final added = await ref
        .read(providerOfFamily.notifier)
        .addScheduledCheckIn(timeOfDay: timeOfDay, mode: mode);
    if (!mounted) return;

    added
        ? context.showSuccessToast(message: 'Daily check-in set for $timeOfDay.')
        : context.showErrorToast(
            message: 'Could not save the check-in time. Please try again.',
          );
  }

  Widget _sosListsBuilder() {
    final sosLists = ref.watch(providerOfFamily.select((s) => s.sosLists));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final list in sosLists)
          Container(
            margin: EdgeInsets.only(bottom: 8.spMin),
            padding: EdgeInsets.symmetric(horizontal: 14.spMin),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.spMin),
            ),
            child: Row(
              children: [
                Icon(
                  list.isDefault
                      ? LucideIcons.star
                      : LucideIcons.users,
                  size: 18.spMin,
                  color: FamilyColors.indigo,
                ),
                SizedBox(width: 10.spMin),
                Expanded(
                  child: Text(
                    '${list.name} — ${list.memberIds.length} '
                    '${list.memberIds.length == 1 ? 'person' : 'people'}'
                    '${list.isDefault ? ' · default' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.pencil,
                    size: 17.spMin,
                    color: AppColors.grey,
                  ),
                  onPressed: () => _editSosList(existing: list),
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.trash2,
                    size: 17.spMin,
                    color: AppColors.grey,
                  ),
                  onPressed: () => ref
                      .read(providerOfFamily.notifier)
                      .removeSosList(sosListId: list.id),
                ),
              ],
            ),
          ),
        if (sosLists.length < 4)
          TextButton.icon(
            onPressed: () => _editSosList(),
            icon: Icon(LucideIcons.plus, size: 16.spMin),
            label: Text(
              'Add SOS list',
              style:
                  TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w700),
            ),
            style: TextButton.styleFrom(foregroundColor: FamilyColors.indigo),
          ),
      ],
    );
  }

  /// Multi-select checkbox editor (§28: the ONLY place checkboxes exist).
  Future<void> _editSosList({final FamilySosList? existing}) async {
    final members = ref.read(providerOfFamily).circle?.others ?? [];
    if (members.isEmpty) {
      context.showWarningToast(
        message: 'Invite family members first — an SOS list needs people.',
      );
      return;
    }

    final nameController = TextEditingController(text: existing?.name ?? '');
    final selected = {...?existing?.memberIds};
    var isDefault = existing?.isDefault ?? false;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.spMin)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20.spMin,
            20.spMin,
            20.spMin,
            MediaQuery.of(sheetContext).viewInsets.bottom + 20.spMin,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                existing == null ? 'New SOS list' : 'Edit ${existing.name}',
                style: TextStyle(
                  fontSize: 17.spMin,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.spMin),
              TextField(
                controller: nameController,
                maxLength: 40,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'List name, e.g. Family only',
                  counterText: '',
                ),
              ),
              SizedBox(height: 8.spMin),
              for (final member in members)
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: FamilyColors.indigo,
                  value: selected.contains(member.id),
                  onChanged: (checked) => setSheetState(() {
                    checked == true
                        ? selected.add(member.id)
                        : selected.remove(member.id);
                  }),
                  title: Text(
                    member.name,
                    style: TextStyle(fontSize: 14.spMin),
                  ),
                ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                activeThumbColor: FamilyColors.indigo,
                value: isDefault,
                onChanged: (value) =>
                    setSheetState(() => isDefault = value),
                title: Text(
                  'Preselect this list on the SOS screen',
                  style: TextStyle(fontSize: 14.spMin),
                ),
              ),
              SizedBox(height: 10.spMin),
              SizedBox(
                height: 48.spMin,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FamilyColors.indigo,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.spMin),
                    ),
                  ),
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: Text(
                    'Save list',
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final name = nameController.text.trim();
    if (saved != true || !mounted) return;
    if (name.isEmpty || selected.isEmpty) {
      context.showErrorToast(
        message: 'Give the list a name and at least one person.',
      );
      return;
    }

    final ok = await ref.read(providerOfFamily.notifier).saveSosList(
          sosListId: existing?.id,
          name: name,
          memberIds: selected.toList(),
          isDefault: isDefault,
        );
    if (!mounted) return;
    ok
        ? context.showSuccessToast(message: 'SOS list saved.')
        : context.showErrorToast(
            message: 'Could not save the list. Please try again.',
          );
  }

  /// The identity surface: the same dark indigo-to-purple gradient as the
  /// Family header and the ALRT+ premium treatment, so this profile reads
  /// as Family identity rather than a plain settings row.
  Widget _identityHeroBuilder(final FamilyMember preview) {
    return FamilyHeaderSurface(
      borderRadius: BorderRadius.circular(20.spMin),
      padding: EdgeInsets.symmetric(vertical: 24.spMin),
      child: Center(
        child: Column(
          children: [
            FamilyMemberAvatar(
              member: preview,
              size: 96,
              showStatusDot: false,
            ),
            SizedBox(height: 12.spMin),
            TextButton.icon(
              onPressed: _changePhoto,
              icon: Icon(
                LucideIcons.camera,
                size: 16.spMin,
                color: Colors.white,
              ),
              label: Text(
                'Change photo',
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.spMin),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _swatchBuilder(final Color color) {
    final hex = _toHex(color);
    final isSelected = _selectedColorHex?.toUpperCase() == hex;

    return GestureDetector(
      onTap: () => setState(() => _selectedColorHex = hex),
      child: Container(
        width: 44.spMin,
        height: 44.spMin,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.black : Colors.transparent,
            width: 3,
          ),
        ),
        child: isSelected
            ? Icon(Icons.check, color: Colors.white, size: 20.spMin)
            : null,
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
    final saved = await ref.read(providerOfFamily.notifier).updateMyProfile(
      nickname: _nicknameController.text.trim().isEmpty
          ? null
          : _nicknameController.text.trim(),
      colorHex: _selectedColorHex,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (saved) {
      context.showSuccessToast(message: 'Circle profile updated.');
      Navigator.of(context).pop();
    }
  }
}
