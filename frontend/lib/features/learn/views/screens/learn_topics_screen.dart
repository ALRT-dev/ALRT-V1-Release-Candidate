import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/learn/models/guide_models.dart';
import 'package:hazard_app/features/learn/providers/learn_provider.dart';
import 'package:hazard_app/features/learn/views/screens/guide_detail_screen.dart';
import 'package:hazard_app/features/learn/views/screens/learn_topic_guides_screen.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The Learn hub content: "Start here" hero for the next unread guide, a
/// progress line, then a two-column grid of topic tiles. Tapping a tile
/// opens that topic's guide list ([LearnTopicGuidesScreen]).
///
/// This is NOT a routed screen - embed it directly. For direct navigation
/// use [LearnTopicsScreen] (route `/learn`) which wraps this in a Scaffold.
class LearnTopicsView extends ConsumerStatefulWidget {
  const LearnTopicsView({
    super.key,
    this.padding,
    this.isScrollable = true,
  });

  /// Outer scroll padding; defaults to 16 all around.
  final EdgeInsetsGeometry? padding;

  /// Whether this view brings its own scrolling.
  ///
  /// False when it is embedded inside a parent that already scrolls. That
  /// matters more than it sounds: a SliverToBoxAdapter hands its child
  /// UNBOUNDED height, and a ListView given unbounded height throws. In a
  /// release build that exception renders as nothing at all, which is why
  /// the Learn tab was once blank rather than showing an error. The topic
  /// grid is therefore shrink-wrapped and never scrolls on its own.
  final bool isScrollable;

  @override
  ConsumerState<LearnTopicsView> createState() => _LearnTopicsViewState();
}

class _LearnTopicsViewState extends ConsumerState<LearnTopicsView> {
  @override
  void initState() {
    super.initState();
    // The learn provider is kept alive and loads once, in its
    // constructor. If that first load failed (created before the auth
    // token was ready, a network blip at startup) the failed state stuck
    // and opening this tab just re-rendered it forever: nothing ever
    // asked again. Opening the tab asks again.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!ref.read(providerOfLearn).hasData) {
        ref.read(providerOfLearn.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenToRefreshErrors(context, ref);

    final learnState = ref.watch(providerOfLearn);

    if (!learnState.hasData) {
      if (learnState.isLoading) return _wrap(_loadingBuilder());
      if (learnState.error != null) {
        return _wrap(
          _errorBuilder(
            context: context,
            ref: ref,
            message: learnState.error?.message,
          ),
        );
      }
    }

    final topics = learnState.topics;
    final hero = _nextGuide(topics);

    return _wrap(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hero != null) ...[
            _heroBuilder(topic: hero.topic, guide: hero.guide),
            18.hSizedBox,
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  'BE READY FOR',
                  style: TextStyle(
                    fontSize: 12.spMin,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.sectionLabel,
                  ),
                ),
              ),
              Text(
                '${learnState.completedCount} of ${learnState.totalCount} '
                'guides read',
                style: TextStyle(
                  fontSize: 12.spMin,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
          12.hSizedBox,
          if (topics.isEmpty)
            _emptyBuilder(ref: ref)
          else
            _gridBuilder(topics),
        ],
      ),
    );
  }

  /// The first guide not yet read, scanning topics then guides in their
  /// published order. Null when everything is complete, which hides the
  /// hero.
  _NextGuide? _nextGuide(final List<GuideTopic> topics) {
    for (final topic in topics) {
      for (final guide in topic.guides) {
        if (!guide.completed) return _NextGuide(topic: topic, guide: guide);
      }
    }
    return null;
  }

  // -------------------------------- HERO --------------------------------

  Widget _heroBuilder({
    required final GuideTopic topic,
    required final GuideListItem guide,
  }) {
    final summary = (guide.summary ?? '').trim();

    return Container(
      padding: EdgeInsets.all(18.spMin),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.orange300, AppColors.red200],
        ),
        borderRadius: BorderRadius.circular(18.spMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'START HERE · +${guide.xpReward} XP',
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
          8.hSizedBox,
          Text(
            guide.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 24.spMin,
              fontWeight: FontWeight.w700,
              height: 1.15,
              color: AppColors.white,
            ),
          ),
          if (summary.isNotEmpty) ...[
            6.hSizedBox,
            Text(
              summary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.spMin,
                color: AppColors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
          14.hSizedBox,
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => _openGuide(context, topic, guide),
              borderRadius: BorderRadius.circular(100.spMin),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.spMin,
                  vertical: 10.spMin,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(100.spMin),
                ),
                child: Text(
                  'Read the guide',
                  style: TextStyle(
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orange,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------- GRID --------------------------------

  Widget _gridBuilder(final List<GuideTopic> topics) {
    return GridView.builder(
      // Never scrolls on its own: the parent (this view's ListView, or
      // whatever embeds the view) owns scrolling, and an inner scrollable
      // with unbounded height would throw.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.spMin,
        mainAxisSpacing: 12.spMin,
        mainAxisExtent: 158.spMin,
      ),
      itemCount: topics.length,
      itemBuilder: (context, index) => _topicTileBuilder(topics[index]),
    );
  }

  Widget _topicTileBuilder(final GuideTopic topic) {
    final look = _TopicLook.forName(topic.name);

    return Container(
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
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: () => _openTopic(context, topic),
          borderRadius: BorderRadius.circular(18.spMin),
          child: Padding(
            padding: EdgeInsets.all(14.spMin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46.spMin,
                      height: 46.spMin,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: look.gradient,
                        ),
                      ),
                      child: Icon(
                        look.icon,
                        color: AppColors.white,
                        size: 22.spMin,
                      ),
                    ),
                    const Spacer(),
                    _progressRingBuilder(topic),
                  ],
                ),
                const Spacer(),
                Text(
                  topic.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: AppColors.black,
                  ),
                ),
                4.hSizedBox,
                Text(
                  '${topic.totalCount} '
                  'guide${topic.totalCount == 1 ? '' : 's'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.spMin,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 34 px ring badge: completed / total for the topic, as a percent.
  Widget _progressRingBuilder(final GuideTopic topic) {
    final percentage = (topic.progress * 100).round();
    final ringColor = topic.isDone ? AppColors.green : AppColors.orange;

    return SizedBox(
      width: 34.spMin,
      height: 34.spMin,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 34.spMin,
            height: 34.spMin,
            child: CircularProgressIndicator(
              value: topic.progress,
              strokeWidth: 3.0,
              color: ringColor,
              backgroundColor: AppColors.extraLightGrey,
            ),
          ),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 9.spMin,
              fontWeight: FontWeight.w700,
              color: percentage > 0 ? ringColor : AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------- STATES -------------------------------

  /// Puts [content] behind this view's own scroll view, or straight onto
  /// the page when the parent is already scrolling it.
  Widget _wrap(final Widget content) {
    final padding = widget.padding ?? EdgeInsets.all(16.spMin);

    if (!widget.isScrollable) {
      return Padding(padding: padding, child: content);
    }

    return RefreshIndicator(
      color: AppColors.orange,
      onRefresh: () => ref.read(providerOfLearn.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        children: [content],
      ),
    );
  }

  /// Shows a toast when a pull-to-refresh fails while stale data is shown.
  void _listenToRefreshErrors(final BuildContext context, final WidgetRef ref) {
    ref.listen(
      providerOfLearn.select((value) => value.error),
      (previous, next) {
        if (next != null && next != previous) {
          final hasData = ref.read(providerOfLearn).hasData;
          if (hasData) {
            context.showErrorToast(
              message: 'Could not refresh guides. Please try again.',
            );
          }
        }
      },
    );
  }

  Widget _loadingBuilder() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 60.spMin),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.orange),
      ),
    );
  }

  Widget _errorBuilder({
    required final BuildContext context,
    required final WidgetRef ref,
    final String? message,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.spMin, horizontal: 24.spMin),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.wifiOff,
              size: 40.spMin,
              color: AppColors.grey,
            ),
            12.hSizedBox,
            Text(
              'Could not load guides',
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w600,
              ),
            ),
            6.hSizedBox,
            Text(
              (message ?? '').trim().isNotEmpty
                  ? message!.trim()
                  : 'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.spMin,
                color: AppColors.grey,
              ),
            ),
            16.hSizedBox,
            OutlinedButton.icon(
              onPressed: () => ref.read(providerOfLearn.notifier).load(),
              icon: Icon(
                LucideIcons.refreshCw,
                size: 16.spMin,
              ),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  /// The library comes from the server, so "empty" can mean two different
  /// things: nothing is published yet, or this device did not get it. The
  /// old copy asserted the first and hid the second. Say which we actually
  /// know, and give a way to try again.
  Widget _emptyBuilder({final WidgetRef? ref}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.spMin),
      child: Column(
        children: [
          Icon(
            LucideIcons.bookOpen,
            size: 40.spMin,
            color: AppColors.lightGrey,
          ),
          12.hSizedBox,
          Text(
            'No guides yet',
            style: TextStyle(
              fontSize: 15.spMin,
              fontWeight: FontWeight.w600,
            ),
          ),
          4.hSizedBox,
          Text(
            'The library loaded, but came back empty. If guides are showing '
            'on your alerts, this is a connection problem rather than an '
            'empty library, so it is worth another try.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.spMin,
              height: 1.45,
              color: AppColors.grey,
            ),
          ),
          if (ref != null) ...[
            14.hSizedBox,
            TextButton(
              onPressed: () => ref.read(providerOfLearn.notifier).load(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.orange,
              ),
              child: Text(
                'Try again',
                style: TextStyle(
                  fontSize: 13.spMin,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ----------------------------- NAVIGATION -----------------------------

  void _openTopic(final BuildContext context, final GuideTopic topic) {
    context.push(
      LearnTopicGuidesScreen.route,
      extra: LearnTopicGuidesScreenArgs(topic: topic),
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

/// The hero's pick: a guide together with the topic it belongs to.
class _NextGuide {
  const _NextGuide({required this.topic, required this.guide});

  final GuideTopic topic;
  final GuideListItem guide;
}

/// Icon and gradient for a topic tile, chosen from the topic's name.
class _TopicLook {
  const _TopicLook({required this.icon, required this.gradient});

  final IconData icon;
  final List<Color> gradient;

  static _TopicLook forName(final String name) {
    final lower = name.toLowerCase();

    if (lower.contains('fire') || lower.contains('heat')) {
      return const _TopicLook(
        icon: LucideIcons.flame,
        gradient: [AppColors.orange300, AppColors.red200],
      );
    }
    if (lower.contains('weather') ||
        lower.contains('flood') ||
        lower.contains('storm')) {
      return const _TopicLook(
        icon: LucideIcons.cloudRain,
        gradient: [Color(0xFF2FA6FF), Color(0xFF1F5CAD)],
      );
    }
    if (lower.contains('outage') || lower.contains('utilit')) {
      return const _TopicLook(
        icon: LucideIcons.zap,
        gradient: [Color(0xFFFFB300), Color(0xFFF07E1B)],
      );
    }
    if (lower.contains('security') || lower.contains('crime')) {
      return const _TopicLook(
        icon: LucideIcons.shield,
        gradient: [Color(0xFFD9304F), Color(0xFF9B1B3A)],
      );
    }
    return const _TopicLook(
      icon: LucideIcons.bookOpen,
      gradient: [Color(0xFF8A93A0), Color(0xFF5C6B7F)],
    );
  }
}

/// Thin routed wrapper around [LearnTopicsView] for direct navigation:
/// white header with a back chevron and "Learn", the hub below it.
class LearnTopicsScreen extends StatelessWidget {
  const LearnTopicsScreen({super.key});

  static const route = '/learn';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F5F7),
      body: Column(
        children: [
          _LearnHubHeader(),
          Expanded(child: LearnTopicsView()),
        ],
      ),
    );
  }
}

/// The Learn board's header: no bar, a back chevron with "Learn" at 28 px,
/// and the XP earned from guides in a white pill on the right.
class _LearnHubHeader extends ConsumerWidget {
  const _LearnHubHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(providerOfLearn.select((s) => s.totalXpEarned));
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.spMin, 8.spMin, 16.spMin, 4.spMin),
        child: Row(
          children: [
            InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(12.spMin),
              child: Padding(
                padding: EdgeInsets.all(4.spMin),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.chevronLeft,
                      color: AppColors.black,
                      size: 26.spMin,
                    ),
                    6.wSizedBox,
                    Text(
                      'Learn',
                      style: TextStyle(
                        fontSize: 28.spMin,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Container(
              height: 30.spMin,
              padding: EdgeInsets.symmetric(horizontal: 12.spMin),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(15.spMin),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.star, size: 14.spMin, color: AppColors.orange),
                  6.wSizedBox,
                  Text(
                    '$xp XP',
                    style: TextStyle(
                      fontSize: 13.spMin,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// White Learn header: back chevron and a title. Shared by the hub and the
/// per-topic guide list so the two read as one section.
class LearnHeader extends StatelessWidget {
  const LearnHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.lightGrey, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.spMin, 8.spMin, 16.spMin, 12.spMin),
          child: Row(
            children: [
              InkWell(
                onTap: () => context.pop(),
                borderRadius: BorderRadius.circular(100.spMin),
                child: Padding(
                  padding: EdgeInsets.all(4.spMin),
                  child: Icon(
                    LucideIcons.chevronLeft,
                    color: AppColors.black,
                    size: 24.spMin,
                  ),
                ),
              ),
              6.wSizedBox,
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
