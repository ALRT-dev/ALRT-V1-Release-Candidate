import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/learn/models/guide_models.dart';
import 'package:hazard_app/features/learn/utils/learn_ui_utils.dart';
import 'package:hazard_app/features/learn/views/widgets/guide_list_tile.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Rounded white card for one guide topic: tinted icon square, title,
/// "N guides · Before / During / After" subtitle and a progress indicator.
///
/// Tapping the header expands the card to list its guides.
class LearnTopicCard extends StatefulWidget {
  const LearnTopicCard({
    super.key,
    required this.topic,
    required this.onGuideTap,
    this.initiallyExpanded = false,
  });

  final GuideTopic topic;
  final void Function(GuideListItem guide) onGuideTap;
  final bool initiallyExpanded;

  @override
  State<LearnTopicCard> createState() => _LearnTopicCardState();
}

class _LearnTopicCardState extends State<LearnTopicCard> {
  late bool _isExpanded = widget.initiallyExpanded;

  GuideTopic get _topic => widget.topic;

  Color get _topicColor => learnColorFromHex(_topic.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.spMin),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColorLight,
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Column(
        children: [
          _headerBuilder(),
          if (_isExpanded) _guidesBuilder(),
        ],
      ),
    );
  }

  Widget _headerBuilder() {
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: BorderRadius.circular(14.spMin),
      child: Padding(
        padding: EdgeInsets.all(14.spMin),
        child: Row(
          children: [
            Container(
              width: 44.spMin,
              height: 44.spMin,
              decoration: BoxDecoration(
                color: _topicColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.spMin),
              ),
              child: Icon(
                learnIconForKey(_topic.icon),
                color: _topicColor,
                size: 22.spMin,
              ),
            ),
            12.wSizedBox,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _topic.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  3.hSizedBox,
                  Text(
                    '${_topic.totalCount} '
                    'guide${_topic.totalCount == 1 ? '' : 's'}'
                    ' · Before / During / After',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.spMin,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            10.wSizedBox,
            _trailingBuilder(),
            6.wSizedBox,
            Icon(
              _isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
              color: AppColors.lightGrey,
              size: 18.spMin,
            ),
          ],
        ),
      ),
    );
  }

  Widget _trailingBuilder() {
    if (_topic.isDone) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10.spMin,
          vertical: 5.spMin,
        ),
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(100.spMin),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.check,
              color: AppColors.darkGreen,
              size: 12.spMin,
            ),
            4.wSizedBox,
            Text(
              'Done',
              style: TextStyle(
                fontSize: 11.spMin,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGreen,
              ),
            ),
          ],
        ),
      );
    }

    final percentage = (_topic.progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 13.spMin,
            fontWeight: FontWeight.w700,
            color: percentage > 0 ? AppColors.orange : AppColors.grey,
          ),
        ),
        4.hSizedBox,
        Container(
          width: 44.spMin,
          height: 4.spMin,
          decoration: BoxDecoration(
            color: AppColors.extraLightGrey,
            borderRadius: BorderRadius.circular(100.spMin),
          ),
          child: Row(
            children: [
              Container(
                width: 44.spMin * _topic.progress,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(100.spMin),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _guidesBuilder() {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.spMin, 0, 14.spMin, 10.spMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(
            height: 1,
            color: AppColors.extraLightGrey,
          ),
          4.hSizedBox,
          if (_topic.guides.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.spMin),
              child: Text(
                'Guides for this topic are coming soon.',
                style: TextStyle(
                  fontSize: 12.spMin,
                  color: AppColors.grey,
                ),
              ),
            )
          else
            ..._topic.guides.map(
              (guide) => GuideListTile(
                guide: guide,
                onTap: () => widget.onGuideTap(guide),
              ),
            ),
        ],
      ),
    );
  }
}
