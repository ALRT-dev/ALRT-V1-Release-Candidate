import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';

/// What leaving actually costs, stated before it happens.
///
/// Every line is a consequence rather than a warning, and the last two are
/// deliberately reassuring: you keep your own safety, and nobody is told.
/// Leaving a circle is allowed to be an ordinary decision.
Future<bool> showFamilyLeaveConfirmSheet({
  required final BuildContext context,
  required final String circleName,
  final int sosListCount = 0,
}) async {
  final left = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _FamilyLeaveConfirmSheet(
      circleName: circleName,
      sosListCount: sosListCount,
    ),
  );
  return left ?? false;
}

class _FamilyLeaveConfirmSheet extends StatelessWidget {
  const _FamilyLeaveConfirmSheet({
    required this.circleName,
    required this.sosListCount,
  });

  final String circleName;
  final int sosListCount;

  static const _loseInk = Color(0xFFE03A2F);
  static const _keepInk = Color(0xFF0A8A58);
  static const _bodyInk = Color(0xFF5F5C66);
  static const _strongInk = Color(0xFF1D1D21);
  static const _stayBackground = Color(0xFFF1EEF4);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.spMin)),
      ),
      padding: EdgeInsets.fromLTRB(20.spMin, 10.spMin, 20.spMin, 16.spMin),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38.spMin,
                height: 4.spMin,
                decoration: BoxDecoration(
                  color: FamilyColors.v31Border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 18.spMin),
            Text(
              'Leave $circleName?',
              style: TextStyle(
                fontSize: 20.spMin,
                fontWeight: FontWeight.w800,
                color: _strongInk,
              ),
            ),
            SizedBox(height: 16.spMin),

            _lineBuilder(
              isKept: false,
              lead: "You'll ",
              strong: 'stop getting their SOS alerts',
              tail: ", and they'll stop getting yours.",
            ),
            _lineBuilder(
              isKept: false,
              lead: 'Nobody here can ask where you are; your snapshots are ',
              strong: 'deleted straight away',
              tail: '.',
            ),
            if (sosListCount > 0)
              _lineBuilder(
                isKept: false,
                lead: 'You come off ',
                strong: '$sosListCount of your SOS '
                    '${sosListCount == 1 ? 'list' : 'lists'}',
                tail: ", and we'll show you which.",
              ),
            _lineBuilder(
              isKept: true,
              lead: 'You ',
              strong: 'keep your own alerts, map and emergency guidance',
              tail: ', and your other groups.',
            ),
            _lineBuilder(
              isNeutral: true,
              lead: 'The group sees your name disappear from the list. ',
              strong: 'No announcement is sent.',
              tail: '',
            ),

            SizedBox(height: 16.spMin),
            SizedBox(
              height: 46.spMin,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF0301C), Color(0xFFC0170A)],
                  ),
                  borderRadius: BorderRadius.circular(14.spMin),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.spMin),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Leave circle',
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.spMin),
            SizedBox(
              height: 42.spMin,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: _stayBackground,
                  foregroundColor: _bodyInk,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.spMin),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Stay',
                  style: TextStyle(
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// One consequence: a cross for what goes, a tick for what stays, an
  /// info dot for what simply happens.
  Widget _lineBuilder({
    required final String lead,
    required final String strong,
    required final String tail,
    final bool isKept = false,
    final bool isNeutral = false,
  }) {
    final icon = isNeutral
        ? Icons.info_outline_rounded
        : isKept
        ? Icons.check_rounded
        : Icons.close_rounded;
    final iconColor = isNeutral
        ? _bodyInk
        : isKept
        ? _keepInk
        : _loseInk;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.spMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.spMin),
            child: Icon(icon, size: 15.spMin, color: iconColor),
          ),
          SizedBox(width: 10.spMin),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: lead),
                  TextSpan(
                    text: strong,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _strongInk,
                    ),
                  ),
                  TextSpan(text: tail),
                ],
              ),
              style: TextStyle(
                fontSize: 13.spMin,
                height: 1.5,
                color: _bodyInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
