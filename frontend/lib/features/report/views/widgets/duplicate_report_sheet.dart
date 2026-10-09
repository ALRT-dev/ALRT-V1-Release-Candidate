import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/report/providers/duplicate_report_provider.dart';
import 'package:hazard_app/features/shared/enums/hazard_vote_types.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/others/app_colors.dart';

/// "Is this the alert?": shown when a new report repeats a live one nearby.
/// Confirming adds a vote to the existing alert instead of posting twice.
Future<void> showDuplicateReportSheet({
  required final BuildContext context,
  required final DuplicateReport duplicate,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
    ),
    builder: (context) => _DuplicateReportSheet(duplicate: duplicate),
  );
}

class _DuplicateReportSheet extends ConsumerStatefulWidget {
  const _DuplicateReportSheet({required this.duplicate});

  final DuplicateReport duplicate;

  @override
  ConsumerState<_DuplicateReportSheet> createState() =>
      _DuplicateReportSheetState();
}

class _DuplicateReportSheetState extends ConsumerState<_DuplicateReportSheet> {
  bool _busy = false;

  Future<void> _confirm() async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await ref.read(providerOfHazardService).voteHazard(
      hazardId: widget.duplicate.hazardId,
      voteType: HazardVoteType.upvote,
    );
    if (!mounted) return;
    result.when(
      (_) {
        Navigator.of(context).maybePop();
        context.showSuccessToast(message: 'Thanks. You confirmed this alert.');
      },
      (_) {
        setState(() => _busy = false);
        context.showErrorToast(message: 'That did not work. Please try again.');
      },
    );
  }

  String _age(final DateTime? at) {
    if (at == null) return '';
    final minutes = DateTime.now().difference(at).inMinutes;
    if (minutes < 1) return 'posted just now';
    if (minutes < 60) return 'posted $minutes min ago';
    final hours = minutes ~/ 60;
    return 'posted $hours h ago';
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.duplicate;
    final colour = lockedCategoryColorFor(d.categoryName) ?? AppColors.grey;
    final detail = [
      if (d.locationName != null && d.locationName!.isNotEmpty) d.locationName!,
      _age(d.createdAt),
    ].where((e) => e.isNotEmpty).join(' · ');

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.spMin, 14.spMin, 20.spMin, 20.spMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Is this the alert?',
              style: TextStyle(
                fontSize: 19.spMin,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 6.spMin),
            Text(
              d.canConfirm
                  ? 'There is already a live alert like this nearby. '
                        'Confirming it helps everyone, and keeps the map clear.'
                  : 'There is already an alert like this nearby, waiting '
                        'for review. It can be confirmed once it is live.',
              style: TextStyle(
                fontSize: 13.5.spMin,
                height: 1.45,
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: 14.spMin),
            Container(
              padding: EdgeInsets.all(14.spMin),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.lightGrey),
                borderRadius: BorderRadius.circular(16.spMin),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22.spMin,
                    height: 22.spMin,
                    decoration: BoxDecoration(
                      color: colour,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.black, width: 2),
                    ),
                  ),
                  SizedBox(width: 12.spMin),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${d.categoryName} · Community report',
                          style: TextStyle(
                            fontSize: 11.spMin,
                            fontWeight: FontWeight.w700,
                            color: AppColors.grey,
                          ),
                        ),
                        SizedBox(height: 3.spMin),
                        Text(
                          d.title,
                          style: TextStyle(
                            fontSize: 15.spMin,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                        ),
                        if (detail.isNotEmpty) ...[
                          SizedBox(height: 3.spMin),
                          Text(
                            detail,
                            style: TextStyle(
                              fontSize: 12.5.spMin,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.spMin),
            if (d.canConfirm)
              SizedBox(
                width: double.infinity,
                height: 50.spMin,
                child: FilledButton(
                  onPressed: _busy ? null : _confirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF232326),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    'Yes, confirm this alert',
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            SizedBox(height: 10.spMin),
            SizedBox(
              width: double.infinity,
              height: 50.spMin,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF232326),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.spMin),
            Center(
              child: Text(
                'Alerts of the same type within about 500 m are combined. '
                'Only the number of confirmations is shown, never who '
                'confirmed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.spMin,
                  height: 1.4,
                  color: AppColors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
