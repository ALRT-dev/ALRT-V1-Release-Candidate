import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/repositories/family_repository.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "Send to my group" on an alert (approved Detail board, 12 Oct 2026):
/// everyone in the chosen group gets the alert and the sender's optional
/// one-line note.
///
/// Resolves to `true` when the group was told, `false` when the send
/// failed, and `null` when the sheet was dismissed. The caller owns the
/// toast, because this sheet's context is gone by the time there is a
/// result to announce.
Future<bool?> showSendToGroupSheet({
  required final BuildContext context,
  required final Hazard hazard,
  required final String circleId,
  required final String circleName,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
    ),
    builder: (context) => _SendToGroupSheet(
      hazard: hazard,
      circleId: circleId,
      circleName: circleName,
    ),
  );
}

class _SendToGroupSheet extends ConsumerStatefulWidget {
  const _SendToGroupSheet({
    required this.hazard,
    required this.circleId,
    required this.circleName,
  });

  final Hazard hazard;
  final String circleId;
  final String circleName;

  @override
  ConsumerState<_SendToGroupSheet> createState() => _SendToGroupSheetState();
}

class _SendToGroupSheetState extends ConsumerState<_SendToGroupSheet> {
  final _noteController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  /// POST /api/family/hazards/{hazardId}/share. While that route is not
  /// deployed the backend answers 404; the group is still told, through
  /// the check-in call that carries the alert and the note today.
  Future<void> _send() async {
    final hazardId = widget.hazard.id;
    if (hazardId == null || _busy) return;
    setState(() => _busy = true);

    final note = _noteController.text.trim();
    final result = await ref
        .read(providerOfFamilyRepository)
        .shareHazardWithCircle(
          circleId: widget.circleId,
          hazardId: hazardId,
          note: note.isEmpty ? null : note,
        );
    if (!mounted) return;

    final sent = await result.when(
      (_) async => true,
      (error) async {
        if (error.code != '404') return false;
        return _fallBackToCheckIn(hazardId: hazardId, note: note);
      },
    );
    if (!mounted) return;
    Navigator.of(context).pop(sent);
  }

  Future<bool> _fallBackToCheckIn({
    required final String hazardId,
    required final String note,
  }) async {
    final title = widget.hazard.title;
    final alertLine = title == null ? 'Alert shared' : 'Alert: "$title"';
    await ref.read(providerOfFamily.notifier).checkIn(
          message: note.isEmpty ? alertLine : '$alertLine. $note',
          shareLocation: false,
          hazardId: hazardId,
        );
    if (!mounted) return false;
    return ref.read(providerOfFamily).checkInState.isSuccess;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.hazard.title?.trim();
    final alertLine = (title == null || title.isEmpty)
        ? 'This alert'
        : title;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20.spMin,
          12.spMin,
          20.spMin,
          20.spMin + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.spMin,
                height: 4.spMin,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2.spMin),
                ),
              ),
            ),
            SizedBox(height: 16.spMin),
            Row(
              children: [
                Icon(
                  LucideIcons.users,
                  size: 20.spMin,
                  color: FamilyColors.indigo,
                ),
                SizedBox(width: 10.spMin),
                Expanded(
                  child: Text(
                    'Send to ${widget.circleName}',
                    style: TextStyle(
                      fontSize: 18.spMin,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.spMin),
            Text(
              '$alertLine. Everyone in the group gets the alert and your note.',
              style: TextStyle(
                fontSize: 13.spMin,
                height: 1.4,
                color: FamilyColors.v31Ink,
              ),
            ),
            SizedBox(height: 16.spMin),
            TextField(
              controller: _noteController,
              enabled: !_busy,
              maxLines: 2,
              minLines: 1,
              maxLength: 140,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(fontSize: 14.spMin, color: AppColors.ink),
              decoration: InputDecoration(
                hintText: 'Add a note (optional), e.g. "Heading home now"',
                hintStyle: TextStyle(
                  fontSize: 13.spMin,
                  color: AppColors.grey,
                ),
                counterText: '',
                filled: true,
                fillColor: FamilyColors.indigoLight,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.spMin,
                  vertical: 12.spMin,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.spMin),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.spMin),
                  borderSide: BorderSide(
                    color: FamilyColors.indigo,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.spMin),
            SizedBox(
              width: double.infinity,
              height: 48.spMin,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: FamilyColors.headerGradient,
                  borderRadius: BorderRadius.circular(14.spMin),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _busy ? null : _send,
                    borderRadius: BorderRadius.circular(14.spMin),
                    child: Center(
                      child: _busy
                          ? SizedBox(
                              width: 20.spMin,
                              height: 20.spMin,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.send,
                                  size: 16.spMin,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8.spMin),
                                Text(
                                  'Send',
                                  style: TextStyle(
                                    fontSize: 15.spMin,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 6.spMin),
            Center(
              child: TextButton(
                onPressed: _busy ? null : () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w600,
                    color: FamilyColors.v31Ink,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
