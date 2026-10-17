import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/models/blocked_user_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/community_safety_provider.dart';
import 'package:hazard_app/others/app_colors.dart';

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

  /// Misleading is picked to start with, as on the ReportAlert board; any
  /// chip can be chosen instead.
  HazardFlagReason? _reason = HazardFlagReason.misleading;

  static const _ink = Color(0xFF1C1C1E);
  static const _muted = Color(0xFF5C5C66);
  static const _chipBorder = Color(0xFFE3E6EA);
  static const _chipOnWash = Color(0xFFFAF9F7);
  static const _secondaryBorder = Color(0xFFD9D6D0);
  static const _handle = Color(0xFFD9D6D0);

  /// The one-word chip labels from the board. The longer labels on
  /// [HazardFlagReason] stay for other screens.
  static String _chipLabel(final HazardFlagReason reason) =>
      switch (reason) {
        HazardFlagReason.inappropriate => 'Inappropriate',
        HazardFlagReason.misleading => 'Misleading',
        HazardFlagReason.spam => 'Spam',
        HazardFlagReason.harassment => 'Harassment',
        HazardFlagReason.other => 'Other',
      };

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

    // ReportAlert board (16 Oct 2026): title, who sees it, five reason
    // chips, Send for review, Block this person, Cancel.
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.spMin, 10.spMin, 16.spMin, 28.spMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.spMin,
                height: 5.spMin,
                decoration: BoxDecoration(
                  color: _handle,
                  borderRadius: BorderRadius.circular(3.spMin),
                ),
              ),
            ),
            SizedBox(height: 14.spMin),
            Text(
              'Report this alert',
              style: TextStyle(
                fontSize: 22.spMin,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: _ink,
              ),
            ),
            SizedBox(height: 4.spMin),
            Text(
              'Sent to ALRT for review. The reporter is not told who '
              'flagged it.',
              style: TextStyle(
                fontSize: 14.spMin,
                height: 1.45,
                color: _muted,
              ),
            ),
            SizedBox(height: 14.spMin),
            Wrap(
              spacing: 8.spMin,
              runSpacing: 8.spMin,
              children: [
                for (final reason in HazardFlagReason.values)
                  _reasonChipBuilder(reason),
              ],
            ),
            SizedBox(height: 14.spMin),
            // Primary: send the chosen reason for review.
            SizedBox(
              height: 54.spMin,
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
                    borderRadius: BorderRadius.circular(14.spMin),
                  ),
                ),
                child: Text(
                  'Send for review',
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (canBlock) ...[
              SizedBox(height: 14.spMin),
              // Outlined: stop seeing this account. They are not told, and
              // nothing is deleted for anyone else.
              SizedBox(
                height: 48.spMin,
                child: OutlinedButton(
                  onPressed: _busy ? null : _block,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _ink,
                    side: const BorderSide(color: _secondaryBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.spMin),
                    ),
                  ),
                  child: Text(
                    'Block this person',
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w600,
                      color: _ink,
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: 6.spMin),
            SizedBox(
              height: 44.spMin,
              child: TextButton(
                onPressed: _busy
                    ? null
                    : () => Navigator.of(context).maybePop(),
                style: TextButton.styleFrom(foregroundColor: _muted),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14.spMin,
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

  /// One reason chip: 40 high, a dark outline when chosen.
  Widget _reasonChipBuilder(final HazardFlagReason reason) {
    final selected = _reason == reason;
    return Semantics(
      button: true,
      selected: selected,
      label: reason.label,
      child: GestureDetector(
        onTap: _busy ? null : () => setState(() => _reason = reason),
        child: Container(
          height: 40.spMin,
          padding: EdgeInsets.symmetric(horizontal: 16.spMin),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? _chipOnWash : AppColors.white,
            borderRadius: BorderRadius.circular(20.spMin),
            border: Border.all(
              color: selected ? _ink : _chipBorder,
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Text(
            _chipLabel(reason),
            style: TextStyle(
              fontSize: 14.spMin,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: _ink,
            ),
          ),
        ),
      ),
    );
  }
}
