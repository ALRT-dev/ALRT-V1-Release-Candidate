import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_board_kit.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

class FamilySosListEditScreenArgs {
  const FamilySosListEditScreenArgs({this.list});

  /// The list being edited; null creates a new one.
  final FamilySosList? list;
}

/// "New list" / "Edit list" (SOSListEdit board): the list name, "Pick
/// exactly who in one group this SOS reaches", the group's people as
/// chips, "Use as my default", and "Save list · N people".
///
/// An SOS goes to the group it is sent from, so a list names people in one
/// group only (review of cb26a8d, finding 4; the backend refuses anything
/// else with SOS_PRESET_OTHER_GROUP). With more than one group the sender
/// picks the group first; switching group clears every pick, so nothing
/// hidden is kept. An old list that mixes groups opens with a repair
/// notice and only the chosen group's people, and saving it repairs it.
class FamilySosListEditScreen extends ConsumerStatefulWidget {
  const FamilySosListEditScreen({super.key, this.args});

  static const route = '/family-sos-list-edit';

  final FamilySosListEditScreenArgs? args;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FamilySosListEditScreenState();
}

class _FamilySosListEditScreenState
    extends ConsumerState<FamilySosListEditScreen> {
  late final TextEditingController _nameController;
  final Set<String> _pickedMemberIds = {};

  List<FamilySosRecipientGroup>? _groups;
  bool _loadFailed = false;

  /// The one group this list is for.
  String? _circleId;

  /// People taken off an old list because they were in another group.
  int _removedForRepair = 0;
  bool _saving = false;
  late bool _isDefault;

  FamilySosList? get _existing => widget.args?.list;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _existing?.name ?? '');
    _pickedMemberIds.addAll(_existing?.memberIds ?? const []);
    _isDefault = _existing?.isDefault ?? false;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecipients());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadRecipients() async {
    final groups = await ref
        .read(providerOfFamily.notifier)
        .loadSosRecipients();
    if (!mounted) return;
    setState(() {
      _groups = groups;
      _loadFailed = groups == null;
      if (groups != null && groups.isNotEmpty) _chooseInitialGroup(groups);
    });
  }

  /// The list's own group; for an old mixed list, the group holding most
  /// of its people; for a new list, the group being viewed. Picks outside
  /// that group are dropped and counted, so the notice can say so.
  void _chooseInitialGroup(final List<FamilySosRecipientGroup> groups) {
    Set<String> idsOf(final FamilySosRecipientGroup g) =>
        g.members.map((m) => m.memberId).toSet();
    final existing = _existing;
    FamilySosRecipientGroup? chosen;
    if (existing?.circleId != null) {
      chosen = groups.where((g) => g.circleId == existing!.circleId).firstOrNull;
    }
    if (chosen == null && _pickedMemberIds.isNotEmpty) {
      final ranked = [...groups]
        ..sort(
          (a, b) => idsOf(b)
              .intersection(_pickedMemberIds)
              .length
              .compareTo(idsOf(a).intersection(_pickedMemberIds).length),
        );
      if (idsOf(ranked.first).intersection(_pickedMemberIds).isNotEmpty) {
        chosen = ranked.first;
      }
    }
    final viewing = ref.read(providerOfFamily).circle?.id;
    chosen ??=
        groups.where((g) => g.circleId == viewing).firstOrNull ?? groups.first;
    _circleId = chosen.circleId;
    final keep = idsOf(chosen);
    final before = _pickedMemberIds.length;
    _pickedMemberIds.retainAll(keep);
    _removedForRepair = before - _pickedMemberIds.length;
  }

  /// Switching group clears every pick: nothing from the other group is
  /// kept out of sight.
  void _switchGroup(final String circleId) {
    if (circleId == _circleId) return;
    setState(() {
      _circleId = circleId;
      _pickedMemberIds.clear();
      _removedForRepair = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groups;

    return FamilyBoardScaffold(
      title: _existing == null ? 'New list' : 'Edit list',
      gap: 10,
      children: [
        TextField(
          key: const Key('sos-list-name'),
          controller: _nameController,
          textCapitalization: TextCapitalization.sentences,
          style: familyBoardInputStyle(),
          decoration: familyBoardInputDecoration('List name'),
          onChanged: (_) => setState(() {}),
        ),
        const FamilyBoardMuted(
          'Pick exactly who in one group this SOS reaches',
        ),
        if (groups == null && !_loadFailed)
          Padding(
            padding: EdgeInsets.all(24.spMin),
            child: const Center(child: CircularProgressIndicator()),
          )
        else if (_loadFailed)
          _retryBuilder()
        else ...[
          if (_existing?.needsRepair != null || _removedForRepair > 0)
            _repairNoticeBuilder(),
          if (groups!.length > 1) _groupPickerBuilder(groups),
          for (final group in groups.where((g) => g.circleId == _circleId))
            ..._groupBuilder(group),
          FamilyBoardToggleRow(
            switchKey: const Key('sos-list-default'),
            title: 'Use as my default',
            value: _isDefault,
            onChanged: _saving
                ? null
                : (value) => setState(() => _isDefault = value),
          ),
          _saveButtonBuilder(),
          if (_existing != null)
            FamilyBoardSecondaryButton(
              key: const Key('sos-list-delete'),
              label: 'Delete this list',
              foregroundColor: AppColors.red,
              onPressed: _saving ? null : _delete,
            ),
        ],
      ],
    );
  }

  Widget _repairNoticeBuilder() {
    final removed = _removedForRepair;
    return KeyedSubtree(
      key: const Key('sos-list-repair-notice'),
      child: FamilyBoardNote(
        _existing?.needsRepair == 'empty' && removed == 0
            ? 'No one on this list is in a group with you any more. Pick '
                  'people to use it again.'
            : 'This list named people in more than one group. An SOS goes '
                  'to one group, so this list is now for the group below'
                  '${removed > 0 ? ' and $removed ${removed == 1 ? 'person' : 'people'} from other groups ${removed == 1 ? 'was' : 'were'} taken off' : ''}. '
                  'Save to repair it.',
      ),
    );
  }

  /// Which group this list is for. Changing it clears the picks.
  Widget _groupPickerBuilder(final List<FamilySosRecipientGroup> groups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FamilyBoardLabel('Group'),
        SizedBox(height: 8.spMin),
        Wrap(
          spacing: 8.spMin,
          runSpacing: 8.spMin,
          children: [
            for (final g in groups)
              FamilyBoardChip(
                key: Key('sos-list-group-${g.circleId}'),
                label: g.name,
                selected: g.circleId == _circleId,
                onTap: () => _switchGroup(g.circleId),
              ),
          ],
        ),
      ],
    );
  }

  /// The group's name as a label, then its people as chips.
  List<Widget> _groupBuilder(final FamilySosRecipientGroup group) {
    return [
      FamilyBoardLabel(group.name),
      if (group.members.isEmpty)
        const FamilyBoardMuted('Nobody else is in this group yet.')
      else
        Wrap(
          spacing: 8.spMin,
          runSpacing: 8.spMin,
          children: [
            for (final member in group.members)
              FamilyBoardChip(
                key: Key('sos-list-member-${member.memberId}'),
                label: member.name,
                selected: _pickedMemberIds.contains(member.memberId),
                onTap: () => setState(() {
                  if (!_pickedMemberIds.remove(member.memberId)) {
                    _pickedMemberIds.add(member.memberId);
                  }
                }),
              ),
          ],
        ),
    ];
  }

  Widget _retryBuilder() {
    return FamilyBoardCard(
      children: [
        const FamilyBoardMuted("Couldn't load your groups."),
        FamilyBoardSecondaryButton(
          label: 'Try again',
          onPressed: () {
            setState(() => _loadFailed = false);
            _loadRecipients();
          },
        ),
      ],
    );
  }

  Widget _saveButtonBuilder() {
    final count = _pickedMemberIds.length;
    final canSave =
        !_saving && count > 0 && _nameController.text.trim().isNotEmpty;

    return FamilyBoardPrimaryButton(
      key: const Key('sos-list-save'),
      indigo: true,
      label: _saving
          ? 'Saving...'
          : 'Save list · $count ${count == 1 ? 'person' : 'people'}',
      onPressed: canSave ? _save : null,
    );
  }

  void _save() async {
    setState(() => _saving = true);
    final saved = await ref
        .read(providerOfFamily.notifier)
        .saveSosList(
          sosListId: _existing?.id,
          name: _nameController.text.trim(),
          // Only the chosen group's people (the backend refuses more).
          memberIds: _pickedInChosenGroup().toList(),
          isDefault: _isDefault,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (saved) {
      Navigator.of(context).maybePop();
    } else {
      context.showErrorToast(message: "Couldn't save the list. Try again.");
    }
  }

  Set<String> _pickedInChosenGroup() {
    final group = _groups?.where((g) => g.circleId == _circleId).firstOrNull;
    if (group == null) return _pickedMemberIds;
    return _pickedMemberIds.intersection(
      group.members.map((m) => m.memberId).toSet(),
    );
  }

  void _delete() async {
    final removed = await ref
        .read(providerOfFamily.notifier)
        .removeSosList(sosListId: _existing!.id);
    if (!mounted) return;
    if (removed) {
      Navigator.of(context).maybePop();
    } else {
      context.showErrorToast(message: "Couldn't delete the list. Try again.");
    }
  }
}
