import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/others/app_colors.dart';

/// "Colour shows severity" picker, shared by the Filters sheet and the
/// Notifications screen.
///
/// Three big choices instead of four thin colour bars (product owner,
/// 15 Oct 2026: the bars were too thin to hit, there was no "all" choice,
/// and it was hard to tell what each one did). Each choice is a 60 pt tile
/// that says what it includes in plain words and shows the colours it
/// covers. Red (emergency) is in every choice and can never be switched
/// off. Grey has no switch of its own on the server, so it travels with
/// yellow; that is why "All" covers both and there is no separate grey
/// choice. No warning-level names are written, only colours and plain
/// words, as before.
///
/// Mapping to the server switches:
/// - All: Advice on, Watch and Act on
/// - Orange and red: Advice off, Watch and Act on
/// - Red only: both off
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

  static const _choices = <_Choice>[
    _Choice(
      title: 'All',
      sub: 'Every colour',
      colours: [
        AppColors.info,
        AppColors.advice,
        AppColors.watchAndAct,
        AppColors.emergency,
      ],
      advice: true,
      watchAndAct: true,
    ),
    _Choice(
      title: 'Orange and red',
      sub: 'Skip grey and yellow',
      colours: [AppColors.watchAndAct, AppColors.emergency],
      advice: false,
      watchAndAct: true,
    ),
    _Choice(
      title: 'Red only',
      sub: 'Emergency warnings',
      colours: [AppColors.emergency],
      advice: false,
      watchAndAct: false,
    ),
  ];

  int get _selected {
    if (advice) return 0;
    if (watchAndAct) return 1;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Semantics(
      label: 'Which colours to show',
      // Both screens put this in a vertical scroll view (unbounded height),
      // so the tiles are stretched to the tallest one, not to infinity.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < _choices.length; i++) ...[
              if (i > 0) SizedBox(width: 8.spMin),
              Expanded(
                child: _tile(_choices[i], isSelected: i == selected),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tile(final _Choice choice, {required final bool isSelected}) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '${choice.title}, ${choice.sub}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(choice.advice, choice.watchAndAct),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: BoxConstraints(minHeight: 60.spMin),
          padding: EdgeInsets.fromLTRB(
            10.spMin,
            10.spMin,
            10.spMin,
            10.spMin,
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFAF9F7) : AppColors.white,
            borderRadius: BorderRadius.circular(14.spMin),
            border: Border.all(
              color: isSelected ? AppColors.ink : AppColors.lightGrey,
              width: isSelected ? 2.0 : 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The colours this choice covers, as one thick bar.
              ClipRRect(
                borderRadius: BorderRadius.circular(6.spMin),
                child: SizedBox(
                  height: 12.spMin,
                  child: Row(
                    children: [
                      for (final c in choice.colours)
                        Expanded(child: ColoredBox(color: c)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8.spMin),
              Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        choice.title,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          fontSize: 14.spMin,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 18.spMin,
                      height: 18.spMin,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.ink,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 12.spMin,
                        color: AppColors.white,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 2.spMin),
              Text(
                choice.sub,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 11.5.spMin,
                  height: 1.25,
                  color: AppColors.mediumGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Choice {
  const _Choice({
    required this.title,
    required this.sub,
    required this.colours,
    required this.advice,
    required this.watchAndAct,
  });

  final String title;
  final String sub;
  final List<Color> colours;
  final bool advice;
  final bool watchAndAct;
}
