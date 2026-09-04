import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// What the person chose on the check-in consent sheet.
enum CheckInConsentChoice {
  /// Check in as safe; send no location at all.
  checkInOnly,

  /// Check in as safe AND share a one-hour location snapshot.
  checkInAndShareLocation,
}

/// The single consent gate every check-in goes through (locked rule:
/// location leaves a phone only by the owner's action).
///
/// A check-in confirms someone is okay - it never implies where they are.
/// So before anything is sent this asks, every time, whether a location
/// snapshot should ride along. "Just check in" is the primary action;
/// sharing is the deliberate extra step. Used by the hub's I'm Safe
/// button, the answer to someone's check-in request, and the alert-detail
/// "I'm safe" strip. Background paths with no UI (notification quick
/// actions) never get to ask, so they check in WITHOUT location instead.
///
/// Returns null when the sheet is dismissed without choosing.
Future<CheckInConsentChoice?> showCheckInConsentSheet(
  final BuildContext context, {
  final String? requesterName,
  final String? contextLine,
}) {
  return showModalBottomSheet<CheckInConsentChoice>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
    ),
    builder: (sheetContext) => _CheckInConsentSheetBody(
      requesterName: requesterName,
      contextLine: contextLine,
    ),
  );
}

class _CheckInConsentSheetBody extends StatelessWidget {
  const _CheckInConsentSheetBody({
    required this.requesterName,
    required this.contextLine,
  });

  final String? requesterName;
  final String? contextLine;

  @override
  Widget build(BuildContext context) {
    final who = requesterName ?? 'Your circle';
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.spMin, 14.spMin, 20.spMin, 16.spMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.spMin,
                height: 4.spMin,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 18.spMin),
            Row(
              children: [
                Container(
                  width: 40.spMin,
                  height: 40.spMin,
                  decoration: const BoxDecoration(
                    color: FamilyColors.safeGreenLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.shieldCheck,
                    color: FamilyColors.safeGreen,
                    size: 20.spMin,
                  ),
                ),
                SizedBox(width: 12.spMin),
                Expanded(
                  child: Text(
                    requesterName == null
                        ? 'Check in as safe'
                        : 'Check in for $requesterName',
                    style: TextStyle(
                      fontSize: 18.spMin,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.spMin),
            Text(
              '$who will see that you checked in, not where you are. '
              'Sharing a location snapshot for the next hour is your '
              'choice, every time - it is never sent automatically.',
              style: TextStyle(
                fontSize: 13.5.spMin,
                height: 1.45,
                color: AppColors.mediumGrey,
              ),
            ),
            if (contextLine != null) ...[
              SizedBox(height: 8.spMin),
              Text(
                contextLine!,
                style: TextStyle(
                  fontSize: 12.5.spMin,
                  fontStyle: FontStyle.italic,
                  color: AppColors.grey,
                ),
              ),
            ],
            SizedBox(height: 18.spMin),
            SizedBox(
              height: 52.spMin,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FamilyColors.safeGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.spMin),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(
                  CheckInConsentChoice.checkInOnly,
                ),
                icon: Icon(Icons.check, size: 20.spMin),
                label: Text(
                  'Just check in',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.spMin),
            SizedBox(
              height: 52.spMin,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: FamilyColors.indigo,
                  side: BorderSide(
                    color: FamilyColors.indigo.withValues(alpha: 0.45),
                    width: 1.4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.spMin),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(
                  CheckInConsentChoice.checkInAndShareLocation,
                ),
                icon: Icon(LucideIcons.mapPin, size: 18.spMin),
                label: Text(
                  'Check in and share my location too',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(height: 6.spMin),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Not now',
                style: TextStyle(
                  fontSize: 13.5.spMin,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
