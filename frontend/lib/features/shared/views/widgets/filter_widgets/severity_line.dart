import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';

/// One horizontal bar in the four alert colours, shared by the Filters
/// sheet and the Notifications screen (product owner, 16 Oct 2026: keep
/// the horizontal bar with red clearly locked; the three-tile version was
/// dropped). Tapping a segment picks the lowest severity to see; colours
/// below it are dimmed. Red (emergency) can never be hidden and carries a
/// lock, and grey has no switch of its own on the server, so both stay
/// lit. The bar carries no colour names: the colour is the severity the
/// issuing agency gave.
///
/// Yellow maps to the Advice switch and orange to Watch and Act:
/// - grey or yellow: both on
/// - orange: Advice off, Watch and Act on
/// - red: both off
class SeverityLine extends StatelessWidget {
  const SeverityLine({
    super.key,
    required this.advice,
    required this.watchAndAct,
    required this.onChanged,
  });

  final bool advice;
  final bool watchAndAct;

  /// Called with the new (advice, watchAndAct) pair.
  final void Function(bool advice, bool watchAndAct) onChanged;

  static const _colours = [
    AppColors.info,
    AppColors.advice,
    AppColors.watchAndAct,
    AppColors.emergency,
  ];

  /// Screen-reader names only; the line itself shows no words.
  static const _semanticNames = [
    'Show grey and above',
    'Show yellow and above',
    'Show orange and above',
    'Red, always shown',
  ];

  /// Index of the lowest segment currently shown.
  int get _lowest {
    if (advice) return 0;
    if (watchAndAct) return 2;
    return 3;
  }

  void _select(final int index) {
    switch (index) {
      case 0:
      case 1:
        onChanged(true, true);
      case 2:
        onChanged(false, true);
      default:
        onChanged(false, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lowest = _lowest;
    return Semantics(
      label: 'Lowest severity to show',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Each colour is a full-height segment (48 pt tap target: the
          // thin bars were too hard to hit, product owner 14 and 15 Oct
          // 2026). The lowest colour shown carries a tick; red carries a
          // lock because it can never be hidden.
          Row(
            children: [
              for (var i = 0; i < _colours.length; i++)
                Expanded(
                  child: Semantics(
                    button: i != _colours.length - 1,
                    selected: i == lowest,
                    label: _semanticNames[i],
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _select(i),
                      child: Container(
                        height: 48.spMin,
                        margin: EdgeInsets.symmetric(horizontal: 2.spMin),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: i >= lowest
                              ? _colours[i]
                              : _colours[i].withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(12.spMin),
                          border: i == lowest
                              ? Border.all(color: AppColors.ink, width: 2)
                              : null,
                        ),
                        child: i == _colours.length - 1
                            ? Icon(
                                Icons.lock_rounded,
                                size: 18.spMin,
                                color: AppColors.white,
                              )
                            : i == lowest
                                ? Icon(
                                    Icons.check_rounded,
                                    size: 18.spMin,
                                    color: i == 1
                                        ? AppColors.ink
                                        : AppColors.white,
                                  )
                                : null,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          6.hSizedBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lower',
                style: TextStyle(fontSize: 11.spMin, color: AppColors.grey),
              ),
              Text(
                'Higher',
                style: TextStyle(fontSize: 11.spMin, color: AppColors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
