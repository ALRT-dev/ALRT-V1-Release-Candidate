import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
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
/// The member's saved sharing level is a ceiling (approved policy): the
/// sheet never offers more than that level allows. `precise` offers the
/// snapshot as before; `approximate` offers a suburb-only snapshot and says
/// so; `alertsOnly` and `off` offer no location at all and explain where to
/// change the level. Passing null (level unknown) keeps the precise wording,
/// but the backend enforces the same ceiling regardless of what a client
/// sends, so the sheet is the explanation, not the guard.
///
/// Returns null when the sheet is dismissed without choosing.
Future<CheckInConsentChoice?> showCheckInConsentSheet(
  final BuildContext context, {
  final String? requesterName,
  final String? contextLine,
  final FamilySharingLevel? sharingLevel,
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
      sharingLevel: sharingLevel ?? FamilySharingLevel.precise,
    ),
  );
}

/// What the consent sheet may offer for a given saved sharing level.
/// Kept as a plain function so the rule is unit-testable without widgets.
CheckInLocationOffer checkInLocationOfferFor(final FamilySharingLevel level) {
  switch (level) {
    case FamilySharingLevel.precise:
      return CheckInLocationOffer.preciseSnapshot;
    case FamilySharingLevel.approximate:
      return CheckInLocationOffer.suburbOnly;
    case FamilySharingLevel.alertsOnly:
    case FamilySharingLevel.off:
      return CheckInLocationOffer.none;
  }
}

/// The most a check-in can share, given the member's saved sharing level.
enum CheckInLocationOffer { preciseSnapshot, suburbOnly, none }

String sharingLevelLabel(final FamilySharingLevel level) {
  switch (level) {
    case FamilySharingLevel.precise:
      return 'Precise';
    case FamilySharingLevel.approximate:
      return 'Approximate';
    case FamilySharingLevel.alertsOnly:
      return 'Alerts only';
    case FamilySharingLevel.off:
      return 'Off';
  }
}

class _CheckInConsentSheetBody extends StatelessWidget {
  const _CheckInConsentSheetBody({
    required this.requesterName,
    required this.contextLine,
    required this.sharingLevel,
  });

  final String? requesterName;
  final String? contextLine;
  final FamilySharingLevel sharingLevel;

  String _bodyCopy(final String who) {
    switch (checkInLocationOfferFor(sharingLevel)) {
      case CheckInLocationOffer.preciseSnapshot:
        return '$who will see that you checked in, not where you are. '
            'Sharing a location snapshot for the next hour is your '
            'choice, every time - it is never sent automatically.';
      case CheckInLocationOffer.suburbOnly:
        return '$who will see that you checked in, not where you are. '
            'Your sharing level is Approximate, so sharing adds your '
            'suburb for the next hour - never a precise pin. It is your '
            'choice, every time.';
      case CheckInLocationOffer.none:
        return '$who will see that you checked in, not where you are. '
            'Your sharing level is ${sharingLevelLabel(sharingLevel)}, so '
            'no location is ever shared with a check-in. You can change '
            'that under My sharing level.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final who = requesterName ?? 'Your circle';
    final offer = checkInLocationOfferFor(sharingLevel);
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
              _bodyCopy(who),
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
                  // The same green as the hub's check-in button.
                  backgroundColor: FamilyColors.safeBrightDeep,
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
            if (offer != CheckInLocationOffer.none) ...[
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
                  offer == CheckInLocationOffer.suburbOnly
                      ? 'Check in and share my suburb'
                      : 'Check in and share my location',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            ],
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
