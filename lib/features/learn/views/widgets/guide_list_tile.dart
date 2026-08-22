import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/learn/models/guide_models.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A single guide row inside an expanded topic card: completion check,
/// title, XP reward and a chevron.
class GuideListTile extends StatelessWidget {
  const GuideListTile({
    super.key,
    required this.guide,
    required this.onTap,
  });

  final GuideListItem guide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.spMin),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 4.spMin,
          vertical: 10.spMin,
        ),
        child: Row(
          children: [
            Icon(
              guide.completed ? LucideIcons.circleCheck : LucideIcons.circle,
              color: guide.completed ? AppColors.green : AppColors.lightGrey,
              size: 20.spMin,
            ),
            10.wSizedBox,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guide.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.spMin,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  if ((guide.summary ?? '').trim().isNotEmpty) ...[
                    2.hSizedBox,
                    Text(
                      guide.summary!.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.spMin,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            8.wSizedBox,
            Text(
              guide.completed ? 'Done' : '+${guide.xpReward} XP',
              style: TextStyle(
                fontSize: 11.spMin,
                fontWeight: FontWeight.w700,
                color: guide.completed ? AppColors.green : AppColors.orange,
              ),
            ),
            6.wSizedBox,
            Icon(
              LucideIcons.chevronRight,
              color: AppColors.lightGrey,
              size: 16.spMin,
            ),
          ],
        ),
      ),
    );
  }
}
