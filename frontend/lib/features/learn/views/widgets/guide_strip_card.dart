import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/learn/providers/guide_for_category_provider.dart';
import 'package:hazard_app/features/learn/views/screens/guide_detail_screen.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The "What to do in a bushfire" strip shown on alerts: deep-links into the
/// safety guide matching the alert's category. Renders nothing when no
/// guide maps to the category.
class GuideStripCard extends ConsumerWidget {
  const GuideStripCard({
    super.key,
    required this.categoryId,
    this.level,
  });

  final String? categoryId;

  /// The alert's level, which picks the guide's stage (before, during or
  /// after the event).
  final String? level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = categoryId;
    if (id == null || id.isEmpty) return const SizedBox.shrink();

    final guideAsync = ref.watch(
      providerOfGuideForCategory(guideForCategoryKey(id, level)),
    );

    return guideAsync.maybeWhen(
      data: (guide) {
        if (guide == null) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () => context.push(
            GuideDetailScreen.route,
            extra: GuideDetailScreenArgs(slugOrId: guide.slug),
          ),
          child: Container(
            margin: EdgeInsets.only(top: 10.spMin),
            padding: EdgeInsets.all(12.spMin),
            // A clear orange outline on white (owner review, 17 November
            // 2026), so the guide reads as a tappable box.
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14.spMin),
              border: Border.all(color: AppColors.orange, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 38.spMin,
                  height: 38.spMin,
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.spMin),
                  ),
                  child: Icon(
                    LucideIcons.bookOpen,
                    color: AppColors.orange,
                    size: 18.spMin,
                  ),
                ),
                SizedBox(width: 10.spMin),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.spMin,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        'Read the safety guide',
                        style: TextStyle(
                          fontSize: 11.spMin,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 18.spMin,
                  color: AppColors.orange,
                ),
              ],
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
