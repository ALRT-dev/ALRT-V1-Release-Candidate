import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/profile/models/for_you_library.dart';
import 'package:hazard_app/features/profile/models/safety_cohort.dart';
import 'package:hazard_app/features/profile/providers/safety_profile_provider.dart';
import 'package:hazard_app/features/profile/views/screens/safety_profile_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The FOR YOU card on an alert: pre-written, human-reviewed guidance pinned
/// by the on-device safety profile. Zero AI at render. The tint is the
/// cohort's permanent identity; rows without a topic icon render the tint
/// block alone (always legal per the anchor rules). Renders nothing when no
/// ticked cohort has a line for this hazard - never a substitute line.
class ForYouCard extends ConsumerStatefulWidget {
  const ForYouCard({
    super.key,
    required this.categoryName,
    this.parentCategoryName,
    this.title,
    this.isAws = false,
    this.isGlobal = false,
    this.publishedRows,
  });

  /// The alert's own category name, tried first.
  final String? categoryName;

  /// The broad parent it hangs under, used only if the specific one has
  /// no guidance of its own.
  final String? parentCategoryName;

  /// The alert title, checked for specific hazards (cyclone, snakes...).
  final String? title;

  /// Whether the alert is an AWS warning (drives the visitor explainer).
  final bool isAws;

  /// Whether the alert is a global / humanitarian alert (GDACS etc).
  final bool isGlobal;

  /// Server supplies generic reviewed rows; selected cohorts stay on phone.
  final Map<String, String>? publishedRows;

  @override
  ConsumerState<ForYouCard> createState() => _ForYouCardState();
}

class _ForYouCardState extends ConsumerState<ForYouCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ticked = ref.watch(providerOfSafetyProfile);

    final bucket = ForYouLibrary.bucketFor(
      categoryName: widget.categoryName,
      parentCategoryName: widget.parentCategoryName,
      title: widget.title,
    );
    final bundledRows = widget.isGlobal
        ? ForYouLibrary.globalRows
        : (ForYouLibrary.rows[bucket] ?? const <SafetyCohort, String>{});
    final publishedRows = widget.publishedRows == null
        ? const <SafetyCohort, String>{}
        : <SafetyCohort, String>{
            for (final cohort in SafetyCohort.values)
              if (widget.publishedRows!.containsKey(cohort.id))
                cohort: widget.publishedRows![cohort.id]!,
          };
    // Owner review, 13 November 2026 ("there isn't the safety profile"):
    // the reviewed on-device rows always apply, and published rows replace
    // them group by group. A published template with no profile rows used
    // to hide For You on every templated alert.
    final rows = <SafetyCohort, String>{...bundledRows, ...publishedRows};
    if (rows.isEmpty) return const SizedBox.shrink();

    // Only explicitly selected needs belong on alert detail.
    if (ticked.isEmpty) return const SizedBox.shrink();

    // Ticked cohorts that have a line for this hazard, in enum order.
    final matched = [
      for (final cohort in SafetyCohort.values)
        if (ticked.contains(cohort) && rows.containsKey(cohort)) cohort,
    ];
    if (matched.isEmpty) return const SizedBox.shrink();

    // Standard: maximum three lines visible at once; further matches
    // collapse behind the "Guidance for other groups" expander. Whether
    // that expander/toggle row exists at all depends only on whether there
    // IS more than the cap - not on the current expand state, or "Show
    // less" would have nowhere to render once expanded.
    const maxVisibleLines = 3;
    final hasMore = matched.length > maxVisibleLines;
    final visible = _expanded
        ? matched
        : matched.take(maxVisibleLines).toList();
    final hiddenCount = matched.length - maxVisibleLines;
    final showVisitorExplainer =
        widget.isAws && ticked.contains(SafetyCohort.visitor);

    // Approved Detail board (12 Oct 2026): the brand-gradient strip, the
    // left-bordered rows with their cohort tag pills, and a footer that
    // says whose words these are. The card sits flush with its siblings.
    return Container(
      margin: EdgeInsets.only(bottom: 16.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        border: Border.all(color: const Color(0xFFFFD9B8), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 14.spMin,
              vertical: 9.spMin,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFFF6B00), Color(0xFFFF0004)],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'FOR YOU',
                    style: TextStyle(
                      fontSize: 12.spMin,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(LucideIcons.lock, size: 11.spMin, color: Colors.white),
                SizedBox(width: 4.spMin),
                Text(
                  'stays on your phone',
                  style: TextStyle(
                    fontSize: 11.spMin,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (showVisitorExplainer) _visitorExplainerBuilder(),
          for (final cohort in visible) _lineBuilder(cohort, rows[cohort]!),
          if (hasMore)
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 13.spMin,
                  vertical: 9.spMin,
                ),
                child: Row(
                  children: [
                    Text(
                      _expanded ? 'Show less' : 'Guidance for other groups',
                      style: TextStyle(
                        fontSize: 11.spMin,
                        color: const Color(0xFF6B6875),
                      ),
                    ),
                    SizedBox(width: 7.spMin),
                    if (!_expanded) ...[
                      for (final cohort
                          in matched.skip(maxVisibleLines).take(3))
                        Container(
                          width: 12.spMin,
                          height: 12.spMin,
                          margin: EdgeInsets.only(right: 2.spMin),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cohort.tintBg,
                            border: Border.all(
                              color: cohort.tintInk,
                              width: 1.4,
                            ),
                          ),
                        ),
                      if (hiddenCount > 3)
                        Container(
                          margin: EdgeInsets.only(left: 3.spMin),
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.spMin,
                            vertical: 1.spMin,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1EFE8),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '+${hiddenCount - 3}',
                            style: TextStyle(
                              fontSize: 9.spMin,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF6B6875),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          _footerBuilder(),
        ],
      ),
    );
  }

  /// Whose words these are. The For You lines are ALRT's general guidance
  /// for a household, never the agency's warning, and the card says so.
  Widget _footerBuilder() {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.spMin, 10.spMin, 14.spMin, 12.spMin),
      child: Text(
        'General guidance from ALRT, not part of the official warning.',
        style: TextStyle(
          fontSize: 11.spMin,
          height: 1.4,
          color: const Color(0xFF6B6875),
        ),
      ),
    );
  }

  Widget _visitorExplainerBuilder() {
    return Container(
      margin: EdgeInsets.fromLTRB(14.spMin, 10.spMin, 14.spMin, 0),
      padding: EdgeInsets.all(10.spMin),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FE),
        borderRadius: BorderRadius.circular(10.spMin),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text: 'New to Australian warnings? ',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const TextSpan(
              text:
                  '"Watch and Act" is the middle of Australia\'s three '
                  'warning levels. The levels are: Advice (stay informed), '
                  'Watch and Act (act now), Emergency Warning (danger, act '
                  'immediately).',
            ),
          ],
        ),
        style: TextStyle(
          fontSize: 11.spMin,
          height: 1.5,
          color: const Color(0xFF1D4F91),
        ),
      ),
    );
  }

  Widget _lineBuilder(final SafetyCohort cohort, final String line) {
    return Container(
      margin: EdgeInsets.fromLTRB(14.spMin, 10.spMin, 14.spMin, 0),
      padding: EdgeInsets.only(left: 10.spMin),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: cohort.tintInk, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.spMin,
              vertical: 3.spMin,
            ),
            decoration: BoxDecoration(
              color: cohort.tintBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '● ${safetyCohortDisplayLabel(cohort)}',
              style: TextStyle(
                fontSize: 10.spMin,
                fontWeight: FontWeight.w700,
                color: cohort.tintInk,
              ),
            ),
          ),
          SizedBox(height: 4.spMin),
          Text(
            line,
            style: TextStyle(
              fontSize: 11.5.spMin,
              height: 1.5,
              color: const Color(0xFF44414C),
            ),
          ),
        ],
      ),
    );
  }
}
