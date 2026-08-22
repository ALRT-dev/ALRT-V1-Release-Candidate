import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/models/blocked_user_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/community_safety_provider.dart';
import 'package:hazard_app/features/shared/views/widgets/alert_card_style.dart';
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
    backgroundColor: Colors.white,
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

  Future<void> _flag(final HazardFlagReason reason) async {
    final id = widget.hazard.id;
    if (id == null || _busy) return;
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
    final reporterId = widget.hazard.reportedBy?.id;
    if (reporterId == null || _busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(providerOfBlockedUsers.notifier).block(reporterId);
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
    final canBlock = widget.hazard.reportedBy?.id != null;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.spMin, 18.spMin, 20.spMin, 20.spMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report this alert',
              style: TextStyle(
                fontSize: 18.spMin,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 5.spMin),
            Text(
              'Tell us what is wrong with it. Enough reports and it goes '
              'back for review.',
              style: TextStyle(
                fontSize: 13.spMin,
                height: 1.45,
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: 14.spMin),
            for (final reason in HazardFlagReason.values)
              _reasonRowBuilder(reason),
            if (canBlock) ...[
              SizedBox(height: 8.spMin),
              Divider(color: AppColors.lightGrey.withValues(alpha: 0.7)),
              SizedBox(height: 8.spMin),
              InkWell(
                onTap: _busy ? null : _block,
                borderRadius: BorderRadius.circular(12.spMin),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.spMin),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.userX,
                        size: 19.spMin,
                        color: AlertCardStyle.bandCritical,
                      ),
                      SizedBox(width: 12.spMin),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Block this person',
                              style: TextStyle(
                                fontSize: 14.5.spMin,
                                fontWeight: FontWeight.w700,
                                color: AlertCardStyle.bandCritical,
                              ),
                            ),
                            SizedBox(height: 2.spMin),
                            Text(
                              'You stop seeing their reports. They are not '
                              'told, and nothing is deleted for anyone else.',
                              style: TextStyle(
                                fontSize: 11.5.spMin,
                                height: 1.35,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _reasonRowBuilder(final HazardFlagReason reason) {
    return InkWell(
      onTap: _busy ? null : () => _flag(reason),
      borderRadius: BorderRadius.circular(12.spMin),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.spMin),
        child: Row(
          children: [
            Expanded(
              child: Text(
                reason.label,
                style: TextStyle(
                  fontSize: 14.5.spMin,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 18.spMin,
              color: AppColors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
