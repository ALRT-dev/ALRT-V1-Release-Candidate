import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/subscription/utils/alrt_plus_limits.dart';
import 'package:hazard_app/features/subscription/views/widgets/alrt_plus_style.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// One row of the Free versus ALRT+ comparison.
class AlrtPlusBenefit {
  const AlrtPlusBenefit({
    required this.icon,
    required this.label,
    required this.free,
    required this.plus,
  });

  final IconData icon;
  final String label;

  /// What the free plan gives; null means "not included".
  final String? free;
  final String plus;
}

/// The verified allowances only: nothing here is a promise about safety
/// outcomes, prices or trials (those come from the store at the moment
/// they are shown). Shared by the paywall, Your ALRT+, the expired screen
/// and the upsell copy, so the wording never drifts between them.
const alrtPlusBenefits = <AlrtPlusBenefit>[
  AlrtPlusBenefit(
    icon: LucideIcons.bellRing,
    label: 'Official alerts, the map and emergency guidance',
    free: 'Always free',
    plus: 'Always free',
  ),
  AlrtPlusBenefit(
    icon: LucideIcons.users,
    label: "Join a family circle someone else hosts",
    free: 'Always free',
    plus: 'Always free',
  ),
  AlrtPlusBenefit(
    icon: LucideIcons.mapPin,
    label: 'Saved locations for alerts (your own location never counts)',
    free: '$kFreeSavedLocationsLimit location',
    plus: 'As many as you like',
  ),
  AlrtPlusBenefit(
    icon: LucideIcons.crown,
    label: 'Host your own family circle: invites, seats, circle settings',
    free: null,
    plus:
        'Up to $kAlrtPlusMaxOwnedCircles circles, $kAlrtPlusSeats seats across them',
  ),
  AlrtPlusBenefit(
    icon: LucideIcons.heartHandshake,
    label: 'Check-ins, SOS and saved places inside a hosted circle',
    free: 'For every member of a circle you join',
    plus: 'For every member of the circles you host',
  ),
];

/// Free versus ALRT+ side by side, readable at large text (rows wrap;
/// nothing is colour-only: a tick or a dash sits next to every value).
class AlrtPlusBenefitsTable extends StatelessWidget {
  const AlrtPlusBenefitsTable({
    super.key,
    this.title = 'What you get',
    this.onDark = false,
  });

  final String title;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final ink = onDark ? Colors.white : AlrtPlusStyle.ink;
    final muted = onDark
        ? Colors.white.withValues(alpha: 0.75)
        : AlrtPlusStyle.inkSoft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 10.5.spMin,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: onDark
                ? Colors.white.withValues(alpha: 0.8)
                : AlrtPlusStyle.label,
          ),
        ),
        SizedBox(height: 8.spMin),
        Container(
          decoration: BoxDecoration(
            color: onDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(14.spMin),
            border: Border.all(
              color: onDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : AlrtPlusStyle.cardLine,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 12.spMin,
            vertical: 6.spMin,
          ),
          child: Column(
            children: [
              for (final (index, benefit) in alrtPlusBenefits.indexed) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    color: onDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : AlrtPlusStyle.cardLine,
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.spMin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            benefit.icon,
                            size: 16.spMin,
                            color: AlrtPlusStyle.magenta,
                          ),
                          SizedBox(width: 8.spMin),
                          Expanded(
                            child: Text(
                              benefit.label,
                              style: TextStyle(
                                fontSize: 13.spMin,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                                color: ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.spMin),
                      Padding(
                        padding: EdgeInsets.only(left: 24.spMin),
                        child: Wrap(
                          spacing: 14.spMin,
                          runSpacing: 4.spMin,
                          children: [
                            _valueBuilder(
                              plan: 'Free',
                              value: benefit.free,
                              ink: ink,
                              muted: muted,
                            ),
                            _valueBuilder(
                              plan: 'ALRT+',
                              value: benefit.plus,
                              ink: ink,
                              muted: muted,
                              highlight: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _valueBuilder({
    required final String plan,
    required final String? value,
    required final Color ink,
    required final Color muted,
    final bool highlight = false,
  }) {
    final included = value != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          included ? LucideIcons.check : LucideIcons.minus,
          size: 13.spMin,
          color: included
              ? (highlight ? AlrtPlusStyle.magenta : muted)
              : muted.withValues(alpha: 0.6),
        ),
        SizedBox(width: 4.spMin),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 240.spMin),
          child: Text(
            '$plan: ${value ?? 'Not included'}',
            style: TextStyle(
              fontSize: 12.spMin,
              height: 1.35,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
              color: included ? ink : muted,
            ),
          ),
        ),
      ],
    );
  }
}
