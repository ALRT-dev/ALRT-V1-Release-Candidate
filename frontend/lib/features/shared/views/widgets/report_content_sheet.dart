import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/models/blocked_user_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/community_safety_provider.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// What a person can do about a community report they object to: send it
/// for review, or stop seeing that account entirely.
///
/// Only community reports get this. An official alert belongs to the
/// agency that issued it and is not ours to hide, so the sheet says so and
/// sends people to the source instead.
Future<void> showReportContentSheet({
  required final BuildContext context,
  required final Hazard hazard,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
    ),
    builder: (context) => _ReportContentSheet(hazard: hazard),
  );
}

class _ReportContentSheet extends ConsumerStatefulWidget {
  const _ReportContentSheet({required this.hazard});

  final Hazard hazard;

  @override
  ConsumerState<_ReportContentSheet> createState() =>
      _ReportContentSheetState();
}

class _ReportContentSheetState extends ConsumerState<_ReportContentSheet> {
  bool _busy = false;
  HazardFlagReason? _reason;

  Future<void> _flag() async {
    final id = widget.hazard.id;
    final reason = _reason;
    if (id == null || reason == null || _busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(providerOfFlagHazard)(id, reason);
      if (!mounted) return;
      Navigator.of(context).maybePop();
      context.showSuccessToast(
        message: 'Thanks. This report has been sent for review.',
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      context.showErrorToast(
        message: 'That could not be sent. Please try again.',
      );
    }
  }

  Future<void> _block() async {
    final hazardId = widget.hazard.id;
    if (hazardId == null || _busy) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(providerOfBlockedUsers.notifier)
          .blockPosterOfHazard(hazardId);
      if (!mounted) return;
      Navigator.of(context).maybePop();
      context.showSuccessToast(
        message: 'Blocked. You will not see their reports again.',
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      context.showErrorToast(message: 'That did not work. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final canBlock = widget.hazard.reportedBy != null;
    final canSend = _reason != null && !_busy;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.spMin, 12.spMin, 20.spMin, 20.spMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
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
                  LucideIcons.flag,
                  size: 20.spMin,
                  color: AppColors.ink,
                ),
                SizedBox(width: 10.spMin),
                Expanded(
                  child: Text(
                    'Report this alert',
                    style: TextStyle(
                      fontSize: 20.spMin,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.spMin),
            Text(
              'Tell us what is wrong with it. Enough reports and it goes '
              'back for review.',
              style: TextStyle(
                fontSize: 13.spMin,
                height: 1.45,
                color: AppColors.mediumGrey,
              ),
            ),
            SizedBox(height: 14.spMin),
            Text(
              'REASON',
              style: TextStyle(
                fontSize: 11.spMin,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: AppColors.sectionLabel,
              ),
            ),
            SizedBox(height: 6.spMin),
            for (final reason in HazardFlagReason.values)
              _reasonRowBuilder(reason),
            SizedBox(height: 16.spMin),
            // Primary: send the chosen reason for review.
            SizedBox(
              width: double.infinity,
              height: 48.spMin,
              child: ElevatedButton(
                onPressed: canSend ? _flag : null,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.orange,
                  disabledBackgroundColor: AppColors.orange.withValues(
                    alpha: 0.4,
                  ),
                  foregroundColor: AppColors.white,
                  disabledForegroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.spMin),
                  ),
                ),
                child: Text(
                  'Send for review',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (canBlock) ...[
              SizedBox(height: 10.spMin),
              // Outlined: stop seeing this account. They are not told, and
              // nothing is deleted for anyone else.
              SizedBox(
                width: double.infinity,
                height: 48.spMin,
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _block,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    side: const BorderSide(
                      color: AppColors.lightGrey,
                      width: 1.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.spMin),
                    ),
                  ),
                  icon: Icon(
                    LucideIcons.circleX,
                    size: 18.spMin,
                    color: AppColors.ink,
                  ),
                  label: Text(
                    'Block this person',
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: 4.spMin),
            SizedBox(
              width: double.infinity,
              height: 44.spMin,
              child: TextButton(
                onPressed: _busy
                    ? null
                    : () => Navigator.of(context).maybePop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.mediumGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.spMin),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// One selectable reason. A filled circle marks the chosen one.
  Widget _reasonRowBuilder(final HazardFlagReason reason) {
    final selected = _reason == reason;
    return InkWell(
      onTap: _busy ? null : () => setState(() => _reason = reason),
      borderRadius: BorderRadius.circular(12.spMin),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.spMin, horizontal: 4.spMin),
        child: Row(
          children: [
            Icon(
              selected ? LucideIcons.circleCheck : LucideIcons.circle,
              size: 20.spMin,
              color: selected ? AppColors.orange : AppColors.grey,
            ),
            SizedBox(width: 12.spMin),
            Expanded(
              child: Text(
                reason.label,
                style: TextStyle(
                  fontSize: 14.5.spMin,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
