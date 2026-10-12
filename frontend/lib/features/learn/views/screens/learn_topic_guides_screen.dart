import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/learn/models/guide_models.dart';
import 'package:hazard_app/features/learn/providers/learn_provider.dart';
import 'package:hazard_app/features/learn/views/screens/guide_detail_screen.dart';
import 'package:hazard_app/features/learn/views/screens/learn_topics_screen.dart';
import 'package:hazard_app/features/learn/views/widgets/guide_list_tile.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

class LearnTopicGuidesScreenArgs {
  const LearnTopicGuidesScreenArgs({required this.topic});

  /// The topic as it was when the tile was tapped. The screen prefers the
  /// live copy from [providerOfLearn] (so a guide read from here shows as
  /// done on return) and falls back to this snapshot.
  final GuideTopic topic;
}

/// One topic's guides: white header with the topic name, then the guide
/// rows (done check, title, one-line summary, XP, chevron). Tapping a row
/// opens [GuideDetailScreen].
class LearnTopicGuidesScreen extends ConsumerWidget {
  const LearnTopicGuidesScreen({
    super.key,
    required this.args,
  });

  static const route = '/learn-topic';

  final LearnTopicGuidesScreenArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveTopic = ref.watch(
      providerOfLearn.select(
        (value) => value.topics
            .where((topic) => topic.id == args.topic.id)
            .firstOrNull,
      ),
    );
    final topic = liveTopic ?? args.topic;

    return Scaffold(
      backgroundColor: AppColors.extraLightGrey,
      body: Column(
        children: [
          LearnHeader(title: topic.name),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.spMin),
              children: [
                _progressLineBuilder(topic),
                12.hSizedBox,
                if (topic.guides.isEmpty)
                  _emptyBuilder()
                else
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.spMin,
                      vertical: 4.spMin,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18.spMin),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowColorLight,
                          blurRadius: 3.0,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        for (final guide in topic.guides)
                          GuideListTile(
                            guide: guide,
                            onTap: () => _openGuide(context, topic, guide),
                          ),
                      ],
                    ),
                  ),
                20.hSizedBox,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressLineBuilder(final GuideTopic topic) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'GUIDES',
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.sectionLabel,
            ),
          ),
        ),
        Text(
          '${topic.completedCount} of ${topic.totalCount} read',
          style: TextStyle(
            fontSize: 12.spMin,
            fontWeight: FontWeight.w600,
            color: topic.isDone ? AppColors.darkGreen : AppColors.grey,
          ),
        ),
      ],
    );
  }

  Widget _emptyBuilder() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.spMin),
      child: Text(
        'Guides for this topic are coming soon.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13.spMin,
          color: AppColors.grey,
        ),
      ),
    );
  }

  void _openGuide(
    final BuildContext context,
    final GuideTopic topic,
    final GuideListItem guide,
  ) {
    context.push(
      GuideDetailScreen.route,
      extra: GuideDetailScreenArgs(
        slugOrId: guide.slug,
        topicName: topic.name,
      ),
    );
  }
}
