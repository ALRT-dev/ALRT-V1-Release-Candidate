import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

class ManagePushNotificationsListItem extends ConsumerStatefulWidget {
  const ManagePushNotificationsListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.emoji,
    this.isEnabled = false,
    this.onToggle,
  });

  final String title;

  final String subtitle;

  final Color color;

  final String emoji;

  final bool isEnabled;

  final void Function(bool)? onToggle;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ManagePushNotificationsListItemState();
}

class _ManagePushNotificationsListItemState
    extends ConsumerState<ManagePushNotificationsListItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.spMin),
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.spMin),
        side: BorderSide(
          color: widget.isEnabled
              ? widget.color.withValues(alpha: 0.5)
              : AppColors.lightGrey.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.spMin),
        child: Row(
          children: [
            Container(
              width: 40.spMin,
              height: 40.spMin,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.spMin),
              ),
              child: Center(
                child: Text(
                  widget.emoji,
                  style: TextStyle(
                    fontSize: 18.spMin,
                  ),
                ),
              ),
            ),
            12.wSizedBox,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  2.spMin.hSizedBox,
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 12.spMin,
                      color: AppColors.grey,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: widget.isEnabled,
              onChanged: (value) => widget.onToggle?.call(value),
              activeTrackColor: widget.color.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
