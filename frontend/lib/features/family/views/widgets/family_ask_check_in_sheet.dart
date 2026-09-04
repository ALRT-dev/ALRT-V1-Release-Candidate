import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/utils/check_in_roll.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_member_avatar.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "Ask for a check-in": everyone in this group, or exactly the people you
/// tick. The button always names who will be asked ("Ask Amy and Tom"),
/// so what you are about to send is never a guess. Only the people asked
/// are notified and see it as owed; you keep it as your tracker on the
/// hub. Nothing about YOUR location travels with an ask (locked rule).
///
/// [preselectMemberIds] ticks those people and opens in "Choose people"
/// straight away (the per-row Ask and Nudge paths); otherwise it opens
/// on "Everyone" with the people still owed pre-ticked for a quick switch.
Future<void> showFamilyAskCheckInSheet(
  final BuildContext context,
  final WidgetRef ref, {
  final List<String>? preselectMemberIds,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
    ),
    builder: (_) => _AskCheckInSheet(
      hostContext: context,
      hostRef: ref,
      preselectMemberIds: preselectMemberIds,
    ),
  );
}

/// "Amy", "Amy and Tom", "Amy, Tom and 2 more".
String namesLabel(final List<String> names) {
  if (names.isEmpty) return 'nobody';
  if (names.length == 1) return names[0];
  if (names.length == 2) return '${names[0]} and ${names[1]}';
  return '${names[0]}, ${names[1]} and ${names.length - 2} more';
}

class _AskCheckInSheet extends ConsumerStatefulWidget {
  const _AskCheckInSheet({
    required this.hostContext,
    required this.hostRef,
    this.preselectMemberIds,
  });

  /// The screen that opened the sheet: what "ask another group" re-opens
  /// on, since this sheet's own context and ref die when it closes.
  final BuildContext hostContext;
  final WidgetRef hostRef;
  final List<String>? preselectMemberIds;

  @override
  ConsumerState<_AskCheckInSheet> createState() => _AskCheckInSheetState();
}

class _AskCheckInSheetState extends ConsumerState<_AskCheckInSheet> {
  late bool _choosePeople = widget.preselectMemberIds != null;
  late final Set<String> _selected = {...?widget.preselectMemberIds};
  final _message = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // With nothing preselected, tick the people still owed so switching
    // to "Choose people" starts from the useful answer.
    if (widget.preselectMemberIds == null) {
      final circle = ref.read(providerOfFamily).circle;
      if (circle != null) {
        final roll = CheckInRoll.of(circle);
        _selected.addAll(
          roll.notYet.where((m) => m.id != circle.myMemberId).map((m) => m.id),
        );
      }
    }
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final circle = ref.watch(providerOfFamily.select((s) => s.circle));
    if (circle == null) return const SizedBox.shrink();
    final others = circle.others;
    final roll = CheckInRoll.of(circle);
    final chosen = others.where((m) => _selected.contains(m.id)).toList();
    final canSend =
        !_sending && others.isNotEmpty && (!_choosePeople || chosen.isNotEmpty);
    final buttonLabel = _choosePeople
        ? (chosen.isEmpty
              ? 'Pick who to ask'
              : 'Ask ${namesLabel(chosen.map((m) => m.name).toList())}')
        : 'Ask everyone in ${circle.name}';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.spMin,
        16.spMin,
        20.spMin,
        MediaQuery.of(context).viewInsets.bottom + 20.spMin,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.spMin,
                height: 4.spMin,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 14.spMin),
            Text(
              'Ask for a check-in',
              style: TextStyle(fontSize: 18.spMin, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 4.spMin),
            Text(
              'They get one tap to say they are safe. They choose whether '
              'to share where they are; you never send your own location.',
              style: TextStyle(
                fontSize: 12.5.spMin,
                height: 1.45,
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: 16.spMin),
            _scopeToggleBuilder(circle),
            if (_choosePeople) ...[
              SizedBox(height: 12.spMin),
              Container(
                decoration: BoxDecoration(
                  color: FamilyColors.v31Page,
                  borderRadius: BorderRadius.circular(16.spMin),
                ),
                child: Column(
                  children: [
                    for (final (index, member) in others.indexed) ...[
                      if (index > 0)
                        Divider(
                          height: 1,
                          indent: 60.spMin,
                          color: Colors.white,
                        ),
                      _personRowBuilder(
                        member,
                        answered: roll.hasAnswered(member),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            SizedBox(height: 14.spMin),
            TextField(
              controller: _message,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 140,
              decoration: InputDecoration(
                hintText: 'Add a note (optional), e.g. "Storm near you, all OK?"',
                hintStyle: TextStyle(fontSize: 13.spMin, color: AppColors.grey),
                counterText: '',
                filled: true,
                fillColor: FamilyColors.v31Page,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.spMin),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 14.spMin),
            SizedBox(
              height: 52.spMin,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FamilyColors.indigo,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: FamilyColors.indigo.withValues(
                    alpha: 0.35,
                  ),
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.spMin),
                  ),
                ),
                onPressed: canSend ? () => _send(circle, chosen) : null,
                icon: Icon(LucideIcons.bellRing, size: 18.spMin),
                label: Text(
                  buttonLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (others.isEmpty) ...[
              SizedBox(height: 8.spMin),
              Text(
                'There is nobody else in this group yet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.spMin, color: AppColors.grey),
              ),
            ],
            _otherGroupsBuilder(circle),
          ],
        ),
      ),
    );
  }

  /// Everyone / Choose people. Two equal choices, one always selected.
  Widget _scopeToggleBuilder(final FamilyCircle circle) {
    Widget option({
      required final String label,
      required final bool selected,
      required final VoidCallback onTap,
    }) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 44.spMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? FamilyColors.indigo : Colors.transparent,
              borderRadius: BorderRadius.circular(12.spMin),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.5.spMin,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : FamilyColors.indigo,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(4.spMin),
      decoration: BoxDecoration(
        color: FamilyColors.indigoLight,
        borderRadius: BorderRadius.circular(14.spMin),
      ),
      child: Row(
        children: [
          option(
            label: 'Everyone in ${circle.name}',
            selected: !_choosePeople,
            onTap: () => setState(() => _choosePeople = false),
          ),
          option(
            label: 'Choose people',
            selected: _choosePeople,
            onTap: () => setState(() => _choosePeople = true),
          ),
        ],
      ),
    );
  }

  Widget _personRowBuilder(final FamilyMember member, {required final bool answered}) {
    final selected = _selected.contains(member.id);
    return InkWell(
      onTap: () => setState(() {
        selected ? _selected.remove(member.id) : _selected.add(member.id);
      }),
      borderRadius: BorderRadius.circular(16.spMin),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.spMin, vertical: 10.spMin),
        child: Row(
          children: [
            FamilyMemberAvatar(member: member, size: 36.spMin),
            SizedBox(width: 12.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    answered ? 'Checked in today' : 'Not yet checked in',
                    style: TextStyle(
                      fontSize: 11.5.spMin,
                      color: answered ? FamilyColors.safeGreen : FamilyColors.amber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24.spMin,
              height: 24.spMin,
              decoration: BoxDecoration(
                color: selected ? FamilyColors.indigo : Colors.white,
                borderRadius: BorderRadius.circular(7.spMin),
                border: Border.all(
                  color: selected ? FamilyColors.indigo : FamilyColors.v31Border,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? Icon(Icons.check, size: 16.spMin, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Your other groups, one tap each: switch the hub to that group and
  /// re-open this sheet there. Asking is always per group, because a
  /// check-in is answered per group.
  Widget _otherGroupsBuilder(final FamilyCircle circle) {
    final others = ref
        .watch(providerOfFamily.select((s) => s.circles))
        .where((c) => c.circleId != circle.id)
        .toList();
    if (others.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.spMin),
        Text(
          'ASK ANOTHER GROUP',
          style: TextStyle(
            fontSize: 11.spMin,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: FamilyColors.v31Label,
          ),
        ),
        SizedBox(height: 8.spMin),
        Wrap(
          spacing: 8.spMin,
          runSpacing: 8.spMin,
          children: [
            for (final summary in others)
              ActionChip(
                label: Text(summary.name),
                avatar: Icon(LucideIcons.users, size: 14.spMin),
                onPressed: _sending
                    ? null
                    : () => _switchGroupAndReopen(summary.circleId),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _switchGroupAndReopen(final String circleId) async {
    final notifier = ref.read(providerOfFamily.notifier);
    final host = widget.hostContext;
    final hostRef = widget.hostRef;
    Navigator.of(context).pop();
    await notifier.selectCircle(circleId);
    if (!host.mounted) return;
    await showFamilyAskCheckInSheet(host, hostRef);
  }

  Future<void> _send(
    final FamilyCircle circle,
    final List<FamilyMember> chosen,
  ) async {
    setState(() => _sending = true);
    final message = _message.text.trim();
    final sent = await ref.read(providerOfFamily.notifier).requestCheckIn(
          message: message.isEmpty ? null : message,
          memberIds: _choosePeople ? chosen.map((m) => m.id).toList() : null,
        );
    if (!mounted) return;
    setState(() => _sending = false);
    if (!sent) return; // the hub's error listener shows the reason
    final who = _choosePeople
        ? namesLabel(chosen.map((m) => m.name).toList())
        : 'everyone in ${circle.name}';
    context.showSuccessToast(message: 'Asked $who to check in.');
    Navigator.of(context).maybePop();
  }
}
