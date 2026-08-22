import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/learn/models/guide_models.dart';
import 'package:hazard_app/features/learn/providers/learn_provider.dart';
import 'package:hazard_app/features/learn/views/screens/guide_detail_screen.dart';
import 'package:hazard_app/features/learn/views/widgets/learn_progress_hero_card.dart';
import 'package:hazard_app/features/learn/views/widgets/learn_topic_card.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The Learn hub content: progress hero card + expandable topic cards.
///
/// This is NOT a routed screen — embed it directly (e.g. as the "Learn"
/// toggle tab of the alerts feed screen). For direct navigation use
/// [LearnTopicsScreen] (route `/learn`) which wraps this in a Scaffold.
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
  /// False when it is embedded inside a parent that already scrolls, which
  /// is how the alerts feed uses it. That matters more than it sounds: a
  /// SliverToBoxAdapter hands its child UNBOUNDED height, and a ListView
  /// given unbounded height throws. In a release build that exception
  /// renders as nothing at all, which is why the Learn tab was blank
  /// rather than showing an error.
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

    return _wrap(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LearnProgressHeroCard(
            completedCount: learnState.completedCount,
            totalCount: learnState.totalCount,
            totalXpEarned: learnState.totalXpEarned,
          ),
          // The weekly challenge now lives INSIDE the hero card: two
          // stacked cards read as two competing challenges (QA 2026-08-07).
          20.hSizedBox,
          Text(
            'BE READY FOR',
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.grey,
            ),
          ),
          10.hSizedBox,
          if (learnState.topics.isEmpty)
            _emptyBuilder(ref: ref)
          else
            ...learnState.topics.map(
              (topic) => Padding(
                padding: EdgeInsets.only(bottom: 12.spMin),
                child: LearnTopicCard(
                  topic: topic,
                  // Lessons are the point of this screen, so they are open
                  // on arrival. Collapsing is there for tidying up, not for
                  // finding out the guides exist.
                  initiallyExpanded: true,
                  onGuideTap: (guide) => _openGuide(context, topic, guide),
                ),
              ),
            ),
        ],
      ),
    );
  }

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

/// Thin routed wrapper around [LearnTopicsView] for direct navigation.
class LearnTopicsScreen extends StatelessWidget {
  const LearnTopicsScreen({super.key});

  static const route = '/learn';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Learn',
          style: TextStyle(
            color: AppColors.black,
          ),
        ),
        foregroundColor: AppColors.black,
      ),
      body: const LearnTopicsView(),
    );
  }
}
