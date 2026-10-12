import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// What the person chose on the check-in consent sheet.
enum CheckInConsentChoice {
  /// Check in; send no location at all.
  checkInOnly,

  /// Check in AND share a one-hour location snapshot.
  checkInAndShareLocation,

  /// "I need help": a check-in with status needsHelp and no location (the
  /// same location rule as "Just check in"). Offered only where the host
  /// screen asked for it ([showCheckInConsentSheet] offerNeedHelp).
  needHelp,
}

/// The single consent gate every check-in goes through (locked rule:
/// location leaves a phone only by the owner's action).
///
/// A check-in confirms someone is okay - it never implies where they are.
/// So before anything is sent this asks, every time, whether a location
/// snapshot should ride along. "Just check in" is the primary action;
/// sharing is the deliberate extra step. Used by the hub's Check in
/// button, the answer to someone's check-in request, and the alert-detail
/// check-in strip. Background paths with no UI (notification quick
/// actions) never get to ask, so they check in WITHOUT location instead.
///
/// The member's saved sharing level is a ceiling (approved policy): the
/// sheet never enables more than that level allows. `precise` enables
/// "share my location"; `approximate` enables only "share my suburb" and
/// says so; `alertsOnly` and `off` leave both sharing buttons disabled and
/// explain where to change the level. Passing null (level unknown) keeps
/// the precise wording, but the backend enforces the same ceiling
/// regardless of what a client sends, so the sheet is the explanation, not
/// the guard.
///
/// [offerNeedHelp] adds the red "I need help" button (approved Family
/// board): a needsHelp check-in without location. Callers that cannot
/// carry the status through leave it off, so the sheet never offers a
/// choice that would be sent as a plain check-in.
///
/// Returns null when the sheet is dismissed without choosing.
Future<CheckInConsentChoice?> showCheckInConsentSheet(
  final BuildContext context, {
  final String? requesterName,
  final String? contextLine,
  final FamilySharingLevel? sharingLevel,
  final bool offerNeedHelp = false,
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
      offerNeedHelp: offerNeedHelp,
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
    required this.offerNeedHelp,
  });

  final String? requesterName;
  final String? contextLine;
  final FamilySharingLevel sharingLevel;
  final bool offerNeedHelp;

  /// One short line explaining why a sharing button is narrowed or off.
  /// Null when the saved level allows the precise snapshot.
  String? _reasonLine() {
    switch (checkInLocationOfferFor(sharingLevel)) {
      case CheckInLocationOffer.preciseSnapshot:
        return null;
      case CheckInLocationOffer.suburbOnly:
        return 'Your sharing level is Approximate, so this shares your '
            'suburb, never a precise pin.';
      case CheckInLocationOffer.none:
        return 'Your sharing level is ${sharingLevelLabel(sharingLevel)}, so '
            'no location is ever shared with a check-in. Change it under '
            'My sharing level.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final offer = checkInLocationOfferFor(sharingLevel);
    final reason = _reasonLine();
    // Each sharing button maps to the one existing path
    // (checkInAndShareLocation); the saved level decides what that path
    // sends, so only the button that tells the truth about it is enabled.
    final canShareLocation = offer == CheckInLocationOffer.preciseSnapshot;
    final canShareSuburb = offer == CheckInLocationOffer.suburbOnly;

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
                    color: FamilyColors.indigoLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.check,
                    color: FamilyColors.indigo,
                    size: 20.spMin,
                  ),
                ),
                SizedBox(width: 12.spMin),
                Expanded(
                  child: Text(
                    requesterName == null
                        ? 'Check in'
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
            SizedBox(height: 8.spMin),
            Text(
              'Tells your group you are okay. Location is only sent if you '
              'choose it.',
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
            _PrimaryGradientButton(
              label: 'Just check in',
              onPressed: () => Navigator.of(context).pop(
                CheckInConsentChoice.checkInOnly,
              ),
            ),
            SizedBox(height: 10.spMin),
            _ShareButton(
              label: 'Check in and share my location',
              enabled: canShareLocation,
              onPressed: () => Navigator.of(context).pop(
                CheckInConsentChoice.checkInAndShareLocation,
              ),
            ),
            SizedBox(height: 10.spMin),
            _ShareButton(
              label: 'Check in and share my suburb',
              enabled: canShareSuburb,
              onPressed: () => Navigator.of(context).pop(
                CheckInConsentChoice.checkInAndShareLocation,
              ),
            ),
            if (reason != null) ...[
              SizedBox(height: 8.spMin),
              Text(
                reason,
                style: TextStyle(
                  fontSize: 12.spMin,
                  height: 1.4,
                  color: AppColors.grey,
                ),
              ),
            ],
            if (offerNeedHelp) ...[
              SizedBox(height: 10.spMin),
              _NeedHelpButton(
                onPressed: () => Navigator.of(context).pop(
                  CheckInConsentChoice.needHelp,
                ),
              ),
            ],
            SizedBox(height: 6.spMin),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
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

/// The primary action on the family indigo gradient (FamilyColors only).
class _PrimaryGradientButton extends StatelessWidget {
  const _PrimaryGradientButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.spMin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: FamilyColors.headerGradient,
          borderRadius: BorderRadius.circular(16.spMin),
        ),
        child: TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.spMin),
            ),
          ),
          onPressed: onPressed,
          icon: Icon(LucideIcons.check, size: 20.spMin),
          label: Text(
            label,
            style: TextStyle(
              fontSize: 15.spMin,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// "I need help": the red SOS gradient, because this is the one check-in
/// that is not "I am okay". It sends no location (the same rule as "Just
/// check in"); the SOS screen is where location choices live.
class _NeedHelpButton extends StatelessWidget {
  const _NeedHelpButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.spMin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: FamilyColors.sosHeaderGradient,
          borderRadius: BorderRadius.circular(16.spMin),
        ),
        child: TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.spMin),
            ),
          ),
          onPressed: onPressed,
          icon: Icon(LucideIcons.siren, size: 20.spMin),
          label: Text(
            'I need help',
            style: TextStyle(
              fontSize: 15.spMin,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// A secondary sharing choice; greyed out when the saved sharing level
/// does not allow what it says.
class _ShareButton extends StatelessWidget {
  const _ShareButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? FamilyColors.indigo : AppColors.grey;
    return SizedBox(
      height: 52.spMin,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          disabledForegroundColor: AppColors.grey,
          side: BorderSide(
            color: enabled
                ? FamilyColors.indigo.withValues(alpha: 0.45)
                : FamilyColors.v31ToggleOff,
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.spMin),
          ),
        ),
        onPressed: enabled ? onPressed : null,
        icon: Icon(LucideIcons.mapPin, size: 18.spMin),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 14.spMin,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
