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
    required this.freeCell,
    required this.plusCell,
  });

  final IconData icon;

  /// The full wording (member sheets, upsell copy).
  final String label;

  /// What the free plan gives; null means "not included".
  final String? free;
  final String plus;

  /// Short forms for the two-column table: null means "not included" and
  /// is drawn as a dash; [kAlwaysCell] is drawn as a tick with "Always".
  final String? freeCell;
  final String plusCell;

  /// True when ALRT+ changes anything; false for the always-free rows.
  bool get isPaidDifference => free != plus;

  static const kAlwaysCell = 'Always';
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
    freeCell: AlrtPlusBenefit.kAlwaysCell,
    plusCell: AlrtPlusBenefit.kAlwaysCell,
  ),
  AlrtPlusBenefit(
    icon: LucideIcons.users,
    label: 'Join a family circle someone else hosts',
    free: 'Always free',
    plus: 'Always free',
    freeCell: AlrtPlusBenefit.kAlwaysCell,
    plusCell: AlrtPlusBenefit.kAlwaysCell,
  ),
  AlrtPlusBenefit(
    icon: LucideIcons.mapPin,
    label: 'Saved locations for alerts (your own location never counts)',
    free: '$kFreeSavedLocationsLimit location',
    plus: 'As many as you like',
    freeCell: '$kFreeSavedLocationsLimit place',
    plusCell: 'Unlimited',
  ),
  AlrtPlusBenefit(
    icon: LucideIcons.crown,
    label: 'Host your own family circle: invites, seats, circle settings',
    free: null,
    plus: 'Up to $kAlrtPlusMaxOwnedCircles circles',
    freeCell: null,
    plusCell: 'Up to $kAlrtPlusMaxOwnedCircles',
  ),
  AlrtPlusBenefit(
    icon: LucideIcons.armchair,
    label: 'Seats for the people you host',
    free: null,
    plus: '$kAlrtPlusSeats seats across your circles',
    freeCell: null,
    plusCell: '$kAlrtPlusSeats seats',
  ),
  AlrtPlusBenefit(
    icon: LucideIcons.heartHandshake,
    label: 'Check-ins, SOS and saved places inside a circle',
    free: 'In a circle you join',
    plus: 'In every circle you host too',
    freeCell: 'In a circle you join',
    plusCell: 'In circles you host too',
  ),
];

/// The free promise, in the app's own words. Shown above the comparison.
const kAlrtPlusFreeLead = 'Alerts are always free.';
const kAlrtPlusFreeText =
    'We want everyone informed, always. Official alerts, the map and '
    'emergency guidance never cost anything, and joining a circle someone '
    'else hosts is free too.';

/// What ALRT+ is for, stated from the enforced allowances only.
const kAlrtPlusHostLine =
    'ALRT+ is for the person who hosts: create your family circle, invite '
    'up to $kAlrtPlusSeats people, and give everyone in it check-ins, SOS and '
    'saved places.';

/// Free and ALRT+ as two columns, one short cell per plan, readable at
/// large text (the label wraps; cells stay short). Nothing is colour-only:
/// a tick, a dash or a word sits in every cell.
class AlrtPlusBenefitsTable extends StatelessWidget {
  const AlrtPlusBenefitsTable({
    super.key,
    this.title = 'Free versus ALRT+',
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
    final line = onDark
        ? Colors.white.withValues(alpha: 0.12)
        : AlrtPlusStyle.cardLine;
    final plusColumn = onDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFF9F0FC);

    Widget cell(
      final String? value, {
      required final bool plus,
    }) {
      final Widget child;
      if (value == null) {
        child = Text(
          '—',
          style: TextStyle(fontSize: 13.spMin, color: muted),
        );
      } else if (value == AlrtPlusBenefit.kAlwaysCell) {
        // A Wrap, not a Row: at large text on a narrow phone the word
        // drops under the tick instead of overflowing the column.
        child = Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4.spMin,
          children: [
            Icon(
              LucideIcons.check,
              size: 14.spMin,
              color: plus ? AlrtPlusStyle.magenta : muted,
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12.spMin,
                fontWeight: plus ? FontWeight.w700 : FontWeight.w500,
                color: plus ? ink : muted,
              ),
            ),
          ],
        );
      } else {
        child = Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.spMin,
            height: 1.25,
            fontWeight: plus ? FontWeight.w700 : FontWeight.w500,
            color: plus ? ink : muted,
          ),
        );
      }
      return Center(child: child);
    }

    Widget header(final String text, {required final bool plus}) => Center(
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10.5.spMin,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: plus ? AlrtPlusStyle.magenta : muted,
        ),
      ),
    );

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
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: onDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
            borderRadius: BorderRadius.circular(14.spMin),
            border: Border.all(color: line),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2.1),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1.15),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: line)),
                ),
                children: [
                  const SizedBox.shrink(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 9.spMin),
                    child: header('Free', plus: false),
                  ),
                  Container(
                    color: plusColumn,
                    padding: EdgeInsets.symmetric(vertical: 9.spMin),
                    child: header('ALRT+', plus: true),
                  ),
                ],
              ),
              for (final (index, benefit) in alrtPlusBenefits.indexed)
                TableRow(
                  decoration: index == alrtPlusBenefits.length - 1
                      ? null
                      : BoxDecoration(
                          border: Border(bottom: BorderSide(color: line)),
                        ),
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        10.spMin,
                        9.spMin,
                        6.spMin,
                        9.spMin,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 1.spMin),
                            child: Icon(
                              benefit.icon,
                              size: 15.spMin,
                              color: AlrtPlusStyle.magenta,
                            ),
                          ),
                          SizedBox(width: 7.spMin),
                          Expanded(
                            child: Text(
                              benefit.label,
                              style: TextStyle(
                                fontSize: 12.5.spMin,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                                color: ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.spMin,
                        vertical: 9.spMin,
                      ),
                      child: cell(benefit.freeCell, plus: false),
                    ),
                    Container(
                      color: plusColumn,
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.spMin,
                        vertical: 9.spMin,
                      ),
                      child: cell(benefit.plusCell, plus: true),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
