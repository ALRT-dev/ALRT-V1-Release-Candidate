import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/others/app_colors.dart';

/// One horizontal line in the four alert colours. Tapping a segment picks
/// the lowest severity to see; colours below it are dimmed. Red (emergency)
/// can never be hidden, and grey has no switch of its own on the server, so
/// both stay lit. The line carries no colour names: the colour is the
/// severity the issuing agency gave.
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
          Row(
            children: [
              for (var i = 0; i < _colours.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _select(i),
                    child: Padding(
                      // A real tap target, not a hairline (owner, 15 Oct
                      // 2026: too thin and too hard to hit). Still one
                      // horizontal row.
                      padding: EdgeInsets.symmetric(vertical: 6.spMin),
                      child: Container(
                        height: 48.spMin,
                        margin: EdgeInsets.symmetric(horizontal: 3.spMin),
                        decoration: BoxDecoration(
                          color: i >= lowest
                              ? _colours[i]
                              : _colours[i].withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(14.spMin),
                          border: i == lowest && lowest > 1
                              ? Border.all(color: AppColors.ink, width: 2)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
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
