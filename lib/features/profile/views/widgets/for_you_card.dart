import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/profile/models/for_you_library.dart';
import 'package:hazard_app/features/profile/models/safety_cohort.dart';
import 'package:hazard_app/features/profile/providers/safety_profile_provider.dart';
import 'package:hazard_app/features/profile/views/screens/safety_profile_screen.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The FOR YOU card on an alert: pre-written, human-reviewed guidance pinned
/// by the on-device safety profile. Zero AI at render. The tint is the
/// cohort's permanent identity; rows without a topic icon render the tint
/// block alone (always legal per the anchor rules). Renders nothing when no
/// ticked cohort has a line for this hazard — never a substitute line.
class ForYouCard extends ConsumerStatefulWidget {
  const ForYouCard({
    super.key,
    required this.categoryName,
    this.parentCategoryName,
    this.title,
    this.isAws = false,
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
    if (bucket == null) return const SizedBox.shrink();
    final rows = ForYouLibrary.rows[bucket];
    if (rows == null) return const SizedBox.shrink();

    // Guidance exists for this hazard but nothing is ticked yet. Silence
    // here is why the feature looks missing: the card simply never appears
    // and nothing tells you it could. Offer it instead, on the alert where
    // it would have helped.
    if (ticked.isEmpty) return _setupPromptBuilder(context);

    // Ticked cohorts that have a line for this hazard, in enum order.
    final matched = [
      for (final cohort in SafetyCohort.values)
        if (ticked.contains(cohort) && rows.containsKey(cohort)) cohort,
    ];
    if (matched.isEmpty) return const SizedBox.shrink();

    final visible = _expanded ? matched : [matched.first];
    final others = matched.length - 1;
    final showVisitorExplainer =
        widget.isAws && ticked.contains(SafetyCohort.visitor);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 8.spMin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(color: const Color(0xFFFFD9B8), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 13.spMin,
              vertical: 8.spMin,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF8C00), Color(0xFFFF6B01)],
              ),
            ),
            child: Row(
              children: [
                Text(
                  'FOR YOU',
                  style: TextStyle(
                    fontSize: 10.spMin,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8.spMin),
                Icon(LucideIcons.lock, size: 10.spMin, color: Colors.white),
                SizedBox(width: 4.spMin),
                Text(
                  'STAYS ON YOUR PHONE',
                  style: TextStyle(
                    fontSize: 10.spMin,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (showVisitorExplainer) _visitorExplainerBuilder(),
          for (final cohort in visible) _lineBuilder(cohort, rows[cohort]!),
          if (others > 0)
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
                      _expanded
                          ? 'Show less'
                          : 'Guidance for other groups',
                      style: TextStyle(
                        fontSize: 11.spMin,
                        color: const Color(0xFF6B6875),
                      ),
                    ),
                    SizedBox(width: 7.spMin),
                    if (!_expanded) ...[
                      for (final cohort in matched.skip(1).take(3))
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
                      if (others > 3)
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
                            '+${others - 3}',
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
          SizedBox(height: 4.spMin),
        ],
      ),
    );
  }

  /// Shown on an alert that HAS guidance when the reader has ticked nothing
  /// yet. One tap to the safety profile, and it says what it stays: on the
  /// phone.
  Widget _setupPromptBuilder(final BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 12.spMin),
      padding: EdgeInsets.all(13.spMin),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F8),
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(color: const Color(0xFFE2E0E6)),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.shieldCheck,
            size: 20.spMin,
            color: const Color(0xFF5F5C66),
          ),
          SizedBox(width: 11.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guidance for your household',
                  style: TextStyle(
                    fontSize: 13.5.spMin,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF232326),
                  ),
                ),
                SizedBox(height: 2.spMin),
                Text(
                  'This alert has advice for older adults, children, '
                  'mobility and more. Tick what applies and it shows here. '
                  'Stays on your phone.',
                  style: TextStyle(
                    fontSize: 11.5.spMin,
                    height: 1.4,
                    color: const Color(0xFF5F5C66),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.spMin),
          Icon(
            LucideIcons.chevronRight,
            size: 18.spMin,
            color: const Color(0xFF8A8792),
          ),
        ],
      ),
    ).onPressed(() => context.push(SafetyProfileScreen.route));
  }

  Widget _visitorExplainerBuilder() {
    return Container(
      margin: EdgeInsets.fromLTRB(11.spMin, 9.spMin, 13.spMin, 0),
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
      margin: EdgeInsets.fromLTRB(11.spMin, 9.spMin, 13.spMin, 0),
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
              '● ${cohort.label}',
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
