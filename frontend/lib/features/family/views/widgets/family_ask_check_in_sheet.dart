import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "Ask for a check-in": everyone in this group, or exactly the people you
/// pick. The button always names who will be asked ("Ask Amy and Tom"),
/// so what you are about to send is never a guess (locked rule: an ask is
/// everyone OR exactly the people picked, and the button names them). Only
/// the people asked are notified and see it as owed; you keep it as your
/// tracker on the hub. Nothing about YOUR location travels with an ask.
///
/// [preselectMemberIds] opens with those people picked (the per-row
/// "Check on" path); otherwise it opens on "Everyone".
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
    builder: (_) => _AskCheckInSheet(preselectMemberIds: preselectMemberIds),
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
  const _AskCheckInSheet({this.preselectMemberIds});

  final List<String>? preselectMemberIds;

  @override
  ConsumerState<_AskCheckInSheet> createState() => _AskCheckInSheetState();
}

class _AskCheckInSheetState extends ConsumerState<_AskCheckInSheet> {
  /// Empty means "Everyone"; otherwise exactly these member ids.
  late final Set<String> _selected = {...?widget.preselectMemberIds};
  final _message = TextEditingController();
  bool _sending = false;

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
    final chosen = others.where((m) => _selected.contains(m.id)).toList();
    // Nobody picked (or only people who have since left) means everyone.
    final everyone = chosen.isEmpty;
    final canSend = !_sending && others.isNotEmpty;
    final buttonLabel = everyone
        ? 'Ask everyone in ${circle.name}'
        : 'Ask ${namesLabel(chosen.map((m) => m.name).toList())}';

    final media = MediaQuery.of(context);
    final bottom = media.viewInsets.bottom > media.viewPadding.bottom
        ? media.viewInsets.bottom
        : media.viewPadding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.spMin,
        16.spMin,
        20.spMin,
        bottom + 20.spMin,
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
              'Pick who to ask, or ask everyone.',
              style: TextStyle(
                fontSize: 12.5.spMin,
                height: 1.45,
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: 14.spMin),
            Wrap(
              spacing: 8.spMin,
              runSpacing: 8.spMin,
              children: [
                _chipBuilder(
                  label: 'Everyone',
                  selected: everyone,
                  onTap: () => setState(_selected.clear),
                ),
                for (final member in others)
                  _chipBuilder(
                    label: member.name,
                    selected: _selected.contains(member.id),
                    onTap: () => setState(() {
                      _selected.contains(member.id)
                          ? _selected.remove(member.id)
                          : _selected.add(member.id);
                    }),
                  ),
              ],
            ),
            SizedBox(height: 14.spMin),
            TextField(
              controller: _message,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 140,
              decoration: InputDecoration(
                labelText: 'Message (optional)',
                labelStyle: TextStyle(fontSize: 13.spMin, color: AppColors.grey),
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
                icon: Icon(LucideIcons.bell, size: 18.spMin),
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
            SizedBox(height: 4.spMin),
            TextButton(
              onPressed: _sending ? null : () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 13.5.spMin,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// One pick chip: indigo when selected, outlined otherwise. Selecting
  /// "Everyone" clears the names; picking a name leaves "Everyone".
  Widget _chipBuilder({
    required final String label,
    required final bool selected,
    required final VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 9.spMin),
        decoration: BoxDecoration(
          color: selected ? FamilyColors.indigo : Colors.white,
          borderRadius: BorderRadius.circular(20.spMin),
          border: Border.all(
            color: selected ? FamilyColors.indigo : FamilyColors.v31Border,
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(LucideIcons.check, size: 14.spMin, color: Colors.white),
              SizedBox(width: 5.spMin),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5.spMin,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : FamilyColors.indigo,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// POST check-in/request: memberIds for the people picked, none for
  /// everyone (FamilyProvider.requestCheckIn).
  Future<void> _send(
    final FamilyCircle circle,
    final List<FamilyMember> chosen,
  ) async {
    setState(() => _sending = true);
    final everyone = chosen.isEmpty;
    final message = _message.text.trim();
    final sent = await ref.read(providerOfFamily.notifier).requestCheckIn(
          message: message.isEmpty ? null : message,
          memberIds: everyone ? null : chosen.map((m) => m.id).toList(),
        );
    if (!mounted) return;
    setState(() => _sending = false);
    if (!sent) return; // the hub's error listener shows the reason
    final who = everyone
        ? 'everyone in ${circle.name}'
        : namesLabel(chosen.map((m) => m.name).toList());
    context.showSuccessToast(message: 'Asked $who to check in.');
    Navigator.of(context).maybePop();
  }
}
