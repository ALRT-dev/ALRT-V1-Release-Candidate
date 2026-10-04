import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_header_surface.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';

class FamilySosListEditScreenArgs {
  const FamilySosListEditScreenArgs({this.list});

  /// The list being edited; null creates a new one.
  final FamilySosList? list;
}

/// Pick exactly who, in ONE group, this SOS list reaches.
///
/// An SOS goes to the group it is sent from, so a list names people in one
/// group only (review of cb26a8d, finding 4; the backend refuses anything
/// else with SOS_PRESET_OTHER_GROUP). The sender picks the group first;
/// switching group clears every pick, so nothing hidden is kept. An old
/// list that mixes groups opens with a repair notice and only the chosen
/// group's people, and saving it repairs it. Several groups in one SOS is a
/// separate future proposal, not this screen.
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
  static const _page = Color(0xFFF5F2F7);
  static const _red = Color(0xFFE03A2F);
  static const _boxBorderOff = Color(0xFFDDD9E2);
  static const _noteBackground = Color(0xFFF6ECFA);
  static const _noteBorder = Color(0xFFECD9F4);
  static const _noteInk = Color(0xFF8E4AA6);

  late final TextEditingController _nameController;
  final Set<String> _pickedMemberIds = {};

  List<FamilySosRecipientGroup>? _groups;
  bool _loadFailed = false;

  /// The one group this list is for.
  String? _circleId;

  /// People taken off an old list because they were in another group.
  int _removedForRepair = 0;
  bool _saving = false;

  FamilySosList? get _existing => widget.args?.list;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _existing?.name ?? '');
    _pickedMemberIds.addAll(_existing?.memberIds ?? const []);
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

    return Scaffold(
      backgroundColor: _page,
      bottomNavigationBar: _saveBarBuilder(),
      body: ListView(
        padding: EdgeInsets.only(bottom: 20.spMin),
        children: [
          _headerBuilder(),
          if (groups == null && !_loadFailed)
            Padding(
              padding: EdgeInsets.all(40.spMin),
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (_loadFailed)
            _retryBuilder()
          else ...[
            if (_existing?.needsRepair != null || _removedForRepair > 0)
              _repairNoticeBuilder(),
            if (groups!.length > 1) _groupPickerBuilder(groups),
            for (final group in groups.where((g) => g.circleId == _circleId)) ...[
              _groupHeaderBuilder(group),
              _groupCardBuilder(group),
            ],
            Container(
              margin: EdgeInsets.fromLTRB(16.spMin, 12.spMin, 16.spMin, 0),
              padding: EdgeInsets.symmetric(
                horizontal: 14.spMin,
                vertical: 11.spMin,
              ),
              decoration: BoxDecoration(
                color: _noteBackground,
                borderRadius: BorderRadius.circular(14.spMin),
                border: Border.all(color: _noteBorder),
              ),
              child: Text(
                'A list names people in one group: an SOS reaches only the '
                'group it is sent from. If someone leaves the group, they '
                'drop off this list automatically.',
                style: TextStyle(
                  fontSize: 12.spMin,
                  height: 1.65,
                  color: _noteInk,
                ),
              ),
            ),
            if (_existing != null) _deleteButtonBuilder(),
          ],
        ],
      ),
    );
  }

  Widget _headerBuilder() {
    // The shared family header band (FamilyHeaderSurface), so this editor
    // stops being the one white-topped screen in the section.
    return FamilyHeaderSurface(
      padding: EdgeInsets.fromLTRB(16.spMin, 52.spMin, 16.spMin, 16.spMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 30.spMin,
                  height: 30.spMin,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
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
                      _existing == null ? 'New list' : _existing!.name,
                      style: TextStyle(
                        fontSize: 20.spMin,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Pick exactly who in one group this SOS reaches',
                      style: TextStyle(
                        fontSize: 11.5.spMin,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.spMin),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 13.spMin,
              vertical: 4.spMin,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.spMin),
            ),
            child: Row(
              children: [
                Text(
                  'List name',
                  style: TextStyle(
                    fontSize: 12.spMin,
                    fontWeight: FontWeight.w700,
                    color: FamilyColors.v31Ink,
                  ),
                ),
                SizedBox(width: 12.spMin),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    textAlign: TextAlign.end,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'e.g. Family only',
                      isDense: true,
                    ),
                    style: TextStyle(
                      fontSize: 13.spMin,
                      fontWeight: FontWeight.w800,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _repairNoticeBuilder() {
    final removed = _removedForRepair;
    return Container(
      key: const Key('sos-list-repair-notice'),
      margin: EdgeInsets.fromLTRB(16.spMin, 14.spMin, 16.spMin, 0),
      padding: EdgeInsets.all(12.spMin),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(color: const Color(0xFFF5C77E)),
      ),
      child: Text(
        _existing?.needsRepair == 'empty' && removed == 0
            ? 'No one on this list is in a group with you any more. Pick '
                  'people to use it again.'
            : 'This list named people in more than one group. An SOS goes '
                  'to one group, so this list is now for the group below'
                  '${removed > 0 ? ' and $removed ${removed == 1 ? 'person' : 'people'} from other groups ${removed == 1 ? 'was' : 'were'} taken off' : ''}. '
                  'Save to repair it.',
        style: TextStyle(fontSize: 12.5.spMin, height: 1.45),
      ),
    );
  }

  /// Which group this list is for. Changing it clears the picks.
  Widget _groupPickerBuilder(final List<FamilySosRecipientGroup> groups) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.spMin, 14.spMin, 16.spMin, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GROUP',
            style: TextStyle(
              fontSize: 11.spMin,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: const Color(0xFFFF6B01),
            ),
          ),
          SizedBox(height: 6.spMin),
          Wrap(
            spacing: 8.spMin,
            runSpacing: 8.spMin,
            children: [
              for (final g in groups)
                ChoiceChip(
                  key: Key('sos-list-group-${g.circleId}'),
                  label: Text(g.name),
                  selected: g.circleId == _circleId,
                  onSelected: (_) => _switchGroup(g.circleId),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _groupHeaderBuilder(final FamilySosRecipientGroup group) {
    final memberIds = group.members.map((m) => m.memberId).toSet();
    final allOn =
        memberIds.isNotEmpty && _pickedMemberIds.containsAll(memberIds);

    return Padding(
      padding: EdgeInsets.fromLTRB(18.spMin, 16.spMin, 18.spMin, 8.spMin),
      child: Row(
        children: [
          Container(
            width: 10.spMin,
            height: 10.spMin,
            decoration: BoxDecoration(
              color: _beaconOf(group),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.spMin),
          Expanded(
            child: Text(
              group.name,
              style: TextStyle(
                fontSize: 12.spMin,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              if (allOn) {
                _pickedMemberIds.removeAll(memberIds);
              } else {
                _pickedMemberIds.addAll(memberIds);
              }
            }),
            child: Text(
              allOn ? 'NONE' : 'ALL',
              style: TextStyle(
                fontSize: 10.5.spMin,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: _red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupCardBuilder(final FamilySosRecipientGroup group) {
    if (group.members.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.spMin),
        padding: EdgeInsets.all(14.spMin),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.spMin),
        ),
        child: Text(
          "You're the only member of this circle.",
          style: TextStyle(fontSize: 12.spMin, color: FamilyColors.v31Ink),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
        boxShadow: [
          BoxShadow(
            color: FamilyColors.v31CardShadow,
            blurRadius: 10.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (index, member) in group.members.indexed) ...[
            if (index > 0)
              const Divider(height: 1, color: FamilyColors.v31Divider),
            _memberRowBuilder(member),
          ],
        ],
      ),
    );
  }

  Widget _memberRowBuilder(final FamilySosRecipient member) {
    final isOn = _pickedMemberIds.contains(member.memberId);

    return InkWell(
      onTap: () => setState(() {
        if (isOn) {
          _pickedMemberIds.remove(member.memberId);
        } else {
          _pickedMemberIds.add(member.memberId);
        }
      }),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 14.spMin,
          vertical: 12.spMin,
        ),
        child: Row(
          children: [
            Container(
              width: 34.spMin,
              height: 34.spMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: FamilyColors.memberColor(member.memberId),
                shape: BoxShape.circle,
              ),
              child: Text(
                _initialsOf(member.name),
                style: TextStyle(
                  fontSize: 11.spMin,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 11.spMin),
            Expanded(
              child: Text(
                member.name,
                style: TextStyle(
                  fontSize: 13.5.spMin,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 26.spMin,
              height: 26.spMin,
              decoration: BoxDecoration(
                color: isOn ? _red : Colors.white,
                borderRadius: BorderRadius.circular(8.spMin),
                border: Border.all(
                  color: isOn ? _red : _boxBorderOff,
                  width: 2,
                ),
              ),
              child: isOn
                  ? Icon(
                      Icons.check_rounded,
                      size: 16.spMin,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _retryBuilder() {
    return Padding(
      padding: EdgeInsets.all(24.spMin),
      child: Column(
        children: [
          Text(
            "Couldn't load your circles.",
            style: TextStyle(fontSize: 13.spMin, color: FamilyColors.v31Ink),
          ),
          SizedBox(height: 10.spMin),
          TextButton(
            onPressed: () {
              setState(() => _loadFailed = false);
              _loadRecipients();
            },
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  Widget _saveBarBuilder() {
    final count = _pickedMemberIds.length;
    final canSave =
        !_saving && count > 0 && _nameController.text.trim().isNotEmpty;

    return Container(
      color: _page,
      padding: EdgeInsets.fromLTRB(16.spMin, 8.spMin, 16.spMin, 12.spMin),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 48.spMin,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF5B47), Color(0xFFD01D0C)],
              ),
              borderRadius: BorderRadius.circular(15.spMin),
              boxShadow: canSave
                  ? [
                      BoxShadow(
                        color: const Color(0xFFDC1E0F).withValues(alpha: 0.35),
                        blurRadius: 20.0,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.spMin),
                ),
              ),
              onPressed: canSave ? _save : null,
              child: Text(
                _saving
                    ? 'Saving…'
                    : 'Save list · $count '
                          '${count == 1 ? 'person' : 'people'}',
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _deleteButtonBuilder() {
    return Padding(
      padding: EdgeInsets.only(top: 14.spMin),
      child: Center(
        child: TextButton(
          onPressed: _delete,
          child: Text(
            'Delete this list',
            style: TextStyle(
              fontSize: 13.spMin,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFC0271B),
            ),
          ),
        ),
      ),
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
          isDefault: _existing?.isDefault,
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

  Color _beaconOf(final FamilySosRecipientGroup group) {
    final hex = group.themeColor?.trim().replaceFirst('#', '');
    final value = hex == null || hex.isEmpty
        ? null
        : int.tryParse(hex, radix: 16);
    if (value == null) return FamilyColors.indigo;
    return Color(hex!.length <= 6 ? value | 0xFF000000 : value);
  }

  String _initialsOf(final String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
