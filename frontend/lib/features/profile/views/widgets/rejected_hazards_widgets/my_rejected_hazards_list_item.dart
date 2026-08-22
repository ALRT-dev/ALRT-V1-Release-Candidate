import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/hazard_item_provider.dart';
import 'package:hazard_app/features/shared/views/screens/view_hazard_screen.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyRejectedHazardsListItem extends ConsumerStatefulWidget {
  const MyRejectedHazardsListItem({
    super.key,
    required this.report,
  });

  /// The hazard to display in this list item.
  final Hazard report;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MyRejectedHazardsListItemState();
}

class _MyRejectedHazardsListItemState
    extends ConsumerState<MyRejectedHazardsListItem> {
  late final provider = providerOfHazardItem(widget.report.id ?? 'unknown');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.spMin),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.spMin),
        border: Border.all(
          color: AppColors.orange.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.edit_outlined,
            size: 20.spMin,
            color: AppColors.orange,
          ),
          12.spMin.wSizedBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.report.title ?? 'No Title',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                4.spMin.hSizedBox,
                Text(
                  widget.report.reviewFeedback ??
                      'Your alrt report has been reviewed and rejected. Please check your profile for feedback.',
                  style: TextStyle(
                    fontSize: 12.spMin,
                    color: AppColors.grey,
                  ),
                ),
                4.spMin.hSizedBox,
                Text(
                  timeago.format(
                    widget.report.createdAt ?? DateTime.now(),
                  ),
                  style: TextStyle(
                    fontSize: 10.spMin,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).onPressed(_gotoViewHazard);
  }

  /// Navigate to the View Hazard screen with the current hazard as an argument.
  void _gotoViewHazard() {
    context.unfocusInputs();
    context.push(
      ViewHazardScreen.route,
      extra: ViewHazardScreenArgs(hazard: widget.report),
    );
  }
}
