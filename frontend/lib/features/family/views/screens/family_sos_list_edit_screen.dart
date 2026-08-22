import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';

class FamilySosListEditScreenArgs {
  const FamilySosListEditScreenArgs({this.list});

  /// The list being edited; null creates a new one.
  final FamilySosList? list;
}

/// Pick exactly who, in which group, this SOS reaches.
///
/// Members are shown per group because that is how the sender thinks of
/// them, but the list itself is a flat set of people: someone picked in two
/// groups is counted once, and the note says so. The count on the save
/// button is that deduplicated truth, never the sum of ticks.
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
            for (final group in groups!) ...[
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
                'Each group is separate — a person picked in two groups is '
                'counted once. If someone leaves a group, they drop off '
                'this list automatically.',
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
    return Container(
      color: Colors.white,
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1EEF4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 14.spMin,
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
                      ),
                    ),
                    Text(
                      'Pick exactly who, in which group, this SOS reaches',
                      style: TextStyle(
                        fontSize: 11.5.spMin,
                        color: FamilyColors.v31Ink,
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
              color: _page,
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
          "You're the only member of this group.",
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
            "Couldn't load your groups.",
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
          memberIds: _pickedMemberIds.toList(),
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
