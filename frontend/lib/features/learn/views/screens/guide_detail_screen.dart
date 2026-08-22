import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/learn/enums/guide_phase_types.dart';
import 'package:hazard_app/features/learn/models/guide_models.dart';
import 'package:hazard_app/features/learn/providers/guide_detail_provider.dart';
import 'package:hazard_app/features/learn/views/widgets/guide_phase_selector.dart';
import 'package:hazard_app/features/learn/views/widgets/guide_step_card.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/utils/open_link.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class GuideDetailScreenArgs {
  const GuideDetailScreenArgs({
    required this.slugOrId,
    this.topicName,
  });

  /// Slug (or id) of the guide to show.
  final String slugOrId;

  /// Optional topic name shown in the header + category chip.
  final String? topicName;
}

/// Full guide screen: orange gradient header, Before/During/After phases,
/// numbered steps, source attribution and a sticky "Mark complete" button.
class GuideDetailScreen extends ConsumerStatefulWidget {
  const GuideDetailScreen({
    super.key,
    required this.args,
  });

  static const route = '/guide-detail';

  final GuideDetailScreenArgs args;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GuideDetailScreenState();
}

class _GuideDetailScreenState extends ConsumerState<GuideDetailScreen> {
  /// The phase the reader explicitly picked. Null means "not chosen yet",
  /// so the guide opens on whichever phase actually has steps.
  GuidePhase? _pickedPhase;

  /// Opening on a fixed phase meant a guide whose content lives in During
  /// or After rendered as "no steps" — the lesson was there, just never
  /// shown. Fall back to the first phase that has something to read.
  GuidePhase _phaseFor(final GuideDetail detail) {
    if (_pickedPhase != null) return _pickedPhase!;
    for (final phase in GuidePhase.values) {
      if (phase.stepsOf(detail.sections).isNotEmpty) return phase;
    }
    return GuidePhase.before;
  }

  String get _slugOrId => widget.args.slugOrId;

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(
      providerOfGuideDetail(_slugOrId).select((value) => value.detail),
    );
    final isLoading = ref.watch(
      providerOfGuideDetail(_slugOrId).select((value) => value.isLoading),
    );
    final hasError = ref.watch(
      providerOfGuideDetail(_slugOrId).select((value) => value.error != null),
    );

    return Scaffold(
      backgroundColor: AppColors.extraLightGrey,
      bottomNavigationBar: detail == null ? null : _bottomBarBuilder(detail),
      body: Column(
        children: [
          _headerBuilder(detail),
          Expanded(
            child: detail != null
                ? _bodyBuilder(detail)
                : isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.orange,
                    ),
                  )
                : hasError
                ? _errorBuilder()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ------------------------------- HEADER -------------------------------

  Widget _headerBuilder(final GuideDetail? detail) {
    final topicName = widget.args.topicName?.trim();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.orange300,
            AppColors.orange,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.spMin, 8.spMin, 16.spMin, 18.spMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(100.spMin),
                    child: Padding(
                      padding: EdgeInsets.all(4.spMin),
                      child: Icon(
                        LucideIcons.chevronLeft,
                        color: AppColors.white,
                        size: 24.spMin,
                      ),
                    ),
                  ),
                  6.wSizedBox,
                  Expanded(
                    child: Text(
                      topicName ?? 'Learn',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.spMin,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              if (detail != null) ...[
                10.hSizedBox,
                if (topicName != null && topicName.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.spMin,
                      vertical: 4.spMin,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(100.spMin),
                    ),
                    child: Text(
                      topicName,
                      style: TextStyle(
                        fontSize: 11.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.orange,
                      ),
                    ),
                  ),
                8.hSizedBox,
                Text(
                  detail.title,
                  style: TextStyle(
                    fontSize: 22.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    height: 1.2,
                  ),
                ),
                if ((detail.sourceName ?? '').trim().isNotEmpty) ...[
                  8.hSizedBox,
                  Row(
                    children: [
                      Icon(
                        LucideIcons.shieldCheck,
                        color: AppColors.white,
                        size: 15.spMin,
                      ),
                      6.wSizedBox,
                      Expanded(
                        child: Text(
                          'Guidance sourced from ${detail.sourceName!.trim()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.spMin,
                            fontWeight: FontWeight.w500,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------- BODY --------------------------------

  Widget _bodyBuilder(final GuideDetail detail) {
    final selectedPhase = _phaseFor(detail);
    final steps = selectedPhase.stepsOf(detail.sections);
    final hasAnySteps = GuidePhase.values.any(
      (phase) => phase.stepsOf(detail.sections).isNotEmpty,
    );

    return ListView(
      padding: EdgeInsets.all(16.spMin),
      children: [
        GuidePhaseSelector(
          selectedPhase: selectedPhase,
          onPhaseSelected: (phase) => setState(() => _pickedPhase = phase),
        ),
        16.hSizedBox,
        if (steps.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.spMin),
            child: Text(
              hasAnySteps
                  ? 'Nothing for this phase. Try the other tabs above.'
                  : 'This guide has no steps yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.spMin,
                color: AppColors.grey,
              ),
            ),
          )
        else
          ...List.generate(
            steps.length,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 12.spMin),
              child: GuideStepCard(
                stepNumber: index + 1,
                step: steps[index],
              ),
            ),
          ),
        8.hSizedBox,
        _sourceCardBuilder(detail),
        20.hSizedBox,
      ],
    );
  }

  Widget _sourceCardBuilder(final GuideDetail detail) {
    final sourceNote = detail.sourceNote?.trim();
    final sourceName = detail.sourceName?.trim();
    final sourceUrl = detail.sourceUrl?.trim();

    final hasNote = (sourceNote ?? '').isNotEmpty;
    final hasName = (sourceName ?? '').isNotEmpty;
    if (!hasNote && !hasName) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.spMin),
        border: const Border(
          left: BorderSide(
            color: AppColors.orange,
            width: 4.0,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColorLight,
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SOURCE',
            style: TextStyle(
              fontSize: 11.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.orange,
            ),
          ),
          if (hasNote) ...[
            6.hSizedBox,
            // Rendered verbatim — this is the official disclaimer text.
            Text(
              sourceNote!,
              style: TextStyle(
                fontSize: 12.spMin,
                color: AppColors.grey,
                height: 1.4,
              ),
            ),
          ],
          if (hasName) ...[
            8.hSizedBox,
            InkWell(
              onTap: (sourceUrl ?? '').isEmpty
                  ? null
                  : () => openLink(
                      context: context,
                      link: sourceUrl!,
                    ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      sourceName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  if ((sourceUrl ?? '').isNotEmpty) ...[
                    5.wSizedBox,
                    Icon(
                      LucideIcons.externalLink,
                      size: 13.spMin,
                      color: AppColors.grey,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _errorBuilder() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.spMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.triangleAlert,
              size: 40.spMin,
              color: AppColors.grey,
            ),
            12.hSizedBox,
            Text(
              'Could not load this guide',
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w600,
              ),
            ),
            6.hSizedBox,
            Text(
              'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.spMin,
                color: AppColors.grey,
              ),
            ),
            16.hSizedBox,
            OutlinedButton.icon(
              onPressed: () => ref
                  .read(providerOfGuideDetail(_slugOrId).notifier)
                  .loadGuideDetail(),
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

  // ----------------------------- BOTTOM BAR -----------------------------

  Widget _bottomBarBuilder(final GuideDetail detail) {
    return Container(
      padding: EdgeInsets.all(12.spMin),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColorMedium,
            blurRadius: 3,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: detail.completed
            ? _completedStateBuilder()
            : _completeButtonBuilder(detail),
      ),
    );
  }

  Widget _completedStateBuilder() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 13.spMin),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.spMin),
        border: Border.all(
          color: AppColors.green.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.circleCheck,
            color: AppColors.darkGreen,
            size: 18.spMin,
          ),
          8.wSizedBox,
          Text(
            'Completed',
            style: TextStyle(
              fontSize: 15.spMin,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _completeButtonBuilder(final GuideDetail detail) {
    final isCompleting = ref.watch(
      providerOfGuideDetail(_slugOrId).select((value) => value.isCompleting),
    );

    return SizedBox(
      width: double.infinity,
      height: 48.spMin,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.green.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.spMin),
          ),
        ),
        onPressed: isCompleting ? null : _handleMarkComplete,
        child: isCompleting
            ? SizedBox(
                width: 20.spMin,
                height: 20.spMin,
                child: const CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.check,
                    size: 18.spMin,
                  ),
                  8.wSizedBox,
                  Text(
                    'Mark complete · +${detail.xpReward} XP',
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _handleMarkComplete() async {
    final completion = await ref
        .read(providerOfGuideDetail(_slugOrId).notifier)
        .completeGuide();
    if (!mounted) return;

    if (completion == null) {
      final error = ref.read(providerOfGuideDetail(_slugOrId)).completionError;
      context.showErrorToast(
        message: (error?.message ?? '').trim().isNotEmpty
            ? 'Could not mark as complete: ${error!.message}'
            : 'Could not mark as complete. Please try again.',
      );
      return;
    }

    if (completion.alreadyCompleted) {
      context.showSuccessToast(
        message: 'Already completed — nice work staying prepared!',
      );
    } else {
      context.showSuccessToast(
        message: '🎉 Guide complete! +${completion.xpAwarded} XP earned',
      );
    }
  }
}
