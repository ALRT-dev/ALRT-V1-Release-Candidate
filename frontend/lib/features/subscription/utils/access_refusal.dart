import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/subscription/models/access_models.dart';
import 'package:hazard_app/features/subscription/views/widgets/plan_identity.dart';

/// A refusal the backend coded (HttpErrorCode in the backend). The app
/// answers each one for what it is: an ended group plan is not "buy ALRT
/// +", a full group is not a payment problem, a permission refusal offers
/// nothing to buy, and an SOS with nobody to reach asks for people.
enum AccessRefusalKind {
  individualRequired,
  groupPlanEnded,
  savedPlaceLimit,
  groupFull,
  alreadyCovered,
  planTooSmall,
  changeInStore,
  hostOnly,
  payerOnly,
  noSosRecipients,
  sosPresetOtherGroup,
}

class AccessRefusal {
  const AccessRefusal({
    required this.kind,
    required this.message,
    this.circleId,
    this.capacity,
    this.sponsored = false,
    this.hasCandidates = false,
    this.sosListId,
    this.presetState,
  });

  final AccessRefusalKind kind;

  /// The backend's own wording, used when the app adds nothing better.
  final String message;
  final String? circleId;
  final int? capacity;
  final bool sponsored;
  final bool hasCandidates;

  /// The SOS list the refusal is about (to open THAT list for repair).
  final String? sosListId;

  /// ok | outdated | otherGroup | empty
  final String? presetState;

  static const _codes = {
    'INDIVIDUAL_REQUIRED': AccessRefusalKind.individualRequired,
    'GROUP_PLAN_ENDED': AccessRefusalKind.groupPlanEnded,
    'SAVED_PLACE_LIMIT': AccessRefusalKind.savedPlaceLimit,
    'GROUP_FULL': AccessRefusalKind.groupFull,
    'GROUP_ALREADY_COVERED': AccessRefusalKind.alreadyCovered,
    'PLAN_TOO_SMALL': AccessRefusalKind.planTooSmall,
    'CHANGE_IN_STORE': AccessRefusalKind.changeInStore,
    'HOST_ONLY': AccessRefusalKind.hostOnly,
    'PAYER_ONLY': AccessRefusalKind.payerOnly,
    'NO_SOS_RECIPIENTS': AccessRefusalKind.noSosRecipients,
    'SOS_PRESET_OTHER_GROUP': AccessRefusalKind.sosPresetOtherGroup,
  };

  /// Null when [error] carries no known code (show its message as before).
  static AccessRefusal? fromError(final AppError? error) {
    if (error == null) return null;
    final kind = _codes[error.extraData['code']];
    if (kind == null) return null;
    final details = error.extraData['details'];
    final d = details is Map ? details : const {};
    return AccessRefusal(
      kind: kind,
      message: error.message,
      circleId: d['circleId']?.toString(),
      capacity: d['capacity'] is int ? d['capacity'] as int : null,
      sponsored: d['sponsored'] == true,
      hasCandidates: d['hasCandidates'] == true,
      sosListId: d['sosListId']?.toString(),
      presetState: d['presetState']?.toString(),
    );
  }
}

/// What the person can do next, never more than two choices.
enum RefusalAction {
  seeAlrtPlus,
  coverGroup,
  upgradeGroup,
  renewInStore,
  inviteSomeone,
  editSosList,

  /// A lapsed sponsored group goes back to each person's own ALRT +
  /// (POST /api/access/groups/:circleId/individual-funding). Offered to
  /// the host only, and only when they have ALRT + themselves.
  useOwnAlrtPlus,
}

class RefusalPresentation {
  const RefusalPresentation({
    required this.title,
    required this.body,
    this.primary,
    this.primaryLabel,
    this.secondary,
    this.secondaryLabel,
  });

  final String title;
  final String body;
  final RefusalAction? primary;
  final String? primaryLabel;
  final RefusalAction? secondary;
  final String? secondaryLabel;
}

const _dangerLine =
    'If you are in immediate danger, call your local emergency number.';

/// Wording and actions for [refusal], given what the person is in the
/// group it concerns ([group], from GET /api/access, may be null) and
/// whether they have their own ALRT + ([hasIndividual], the personal plan
/// or its trial).
RefusalPresentation refusalPresentation(
  final AccessRefusal refusal, {
  final GroupAccess? group,
  final bool hasIndividual = false,
}) {
  final isHost = group?.isHost ?? false;
  final youPay = group?.sponsorship?.youPay ?? false;
  switch (refusal.kind) {
    case AccessRefusalKind.individualRequired:
      return RefusalPresentation(
        title: 'ALRT + needed in this group',
        body:
            'This group doesn\'t have a Family or Group plan, so each person '
            'taking part needs their own ALRT +.'
            '${isHost ? ' As the host, you can cover everyone instead.' : ''}',
        primary: RefusalAction.seeAlrtPlus,
        primaryLabel: 'See ALRT +',
        secondary: isHost ? RefusalAction.coverGroup : null,
        secondaryLabel: isHost ? 'Cover this group' : null,
      );
    case AccessRefusalKind.groupPlanEnded:
      // Never an ALRT + upsell: buying it would not switch this group on.
      // A host who already has ALRT + can instead move the group back to
      // each person's own ALRT + (the backend allows the host only).
      final canUseOwn = isHost && hasIndividual;
      final primary = youPay
          ? RefusalAction.renewInStore
          : isHost
          ? RefusalAction.coverGroup
          : null;
      return RefusalPresentation(
        title: 'This group\'s plan has ended',
        body:
            'Check in, Check on, SOS and Journey are paused in this group. '
            'Stopping and ending still work.'
            '${youPay
                ? ''
                : isHost
                ? ''
                : ' The person who paid, or the host, can renew or replace it.'}'
            '${canUseOwn ? ' Or use your own ALRT + here: then everyone with '
                      'their own ALRT + can carry on in this group.' : ''}',
        primary: primary,
        primaryLabel: youPay
            ? 'Renew in your app store'
            : isHost
            ? 'Cover this group'
            : null,
        secondary: canUseOwn ? RefusalAction.useOwnAlrtPlus : null,
        secondaryLabel: canUseOwn ? 'Use my own ALRT +' : null,
      );
    case AccessRefusalKind.groupFull:
      final s = group?.sponsorship;
      final canUpgrade = youPay && s?.upgradeTier != null;
      final n = refusal.capacity;
      return RefusalPresentation(
        title: 'This group is full',
        body: refusal.sponsored
            ? 'Its plan covers up to ${n ?? 'its limit of'} people.'
                  '${canUpgrade ? '' : ' Ask the person who pays for it about a bigger plan.'}'
            : 'It already has ${n ?? 'the most'} people, the most a group can '
                  'have for now.',
        primary: canUpgrade ? RefusalAction.upgradeGroup : null,
        primaryLabel: canUpgrade
            ? 'Upgrade to ${planDisplayName(s!.upgradeTier!)}'
            : null,
      );
    case AccessRefusalKind.hostOnly:
      return RefusalPresentation(
        title: 'Only the host can do this',
        body: refusal.message,
      );
    case AccessRefusalKind.payerOnly:
      return RefusalPresentation(
        title: 'Only the person who pays can change this plan',
        body: refusal.message,
      );
    case AccessRefusalKind.noSosRecipients:
      // A list that names nobody in this group is a list to repair, not a
      // reason to invite people; people who exist but can't receive it are
      // neither. "Invite someone" only when the group has nobody else.
      if (refusal.sosListId != null) {
        return RefusalPresentation(
          title: 'Your SOS list needs fixing',
          body: refusal.message,
          primary: RefusalAction.editSosList,
          primaryLabel: 'Edit this list',
        );
      }
      return RefusalPresentation(
        title: refusal.hasCandidates
            ? 'No one here can receive an SOS right now'
            : 'Add someone first',
        body: refusal.hasCandidates
            ? 'Everyone in this group needs ALRT +, or a group plan that is '
                  'active. $_dangerLine'
            : 'You need at least one other person in this group to send an '
                  'SOS. $_dangerLine',
        primary: refusal.hasCandidates ? null : RefusalAction.inviteSomeone,
        primaryLabel: refusal.hasCandidates ? null : 'Invite someone',
      );
    case AccessRefusalKind.sosPresetOtherGroup:
      return RefusalPresentation(
        title: 'Your SOS list needs fixing',
        body: refusal.message,
        primary: RefusalAction.editSosList,
        primaryLabel: 'Edit this list',
      );
    case AccessRefusalKind.savedPlaceLimit:
      return RefusalPresentation(
        title: 'One saved place on ALRT Free',
        body: refusal.message,
        primary: RefusalAction.seeAlrtPlus,
        primaryLabel: 'See ALRT +',
      );
    case AccessRefusalKind.alreadyCovered:
    case AccessRefusalKind.planTooSmall:
    case AccessRefusalKind.changeInStore:
      return RefusalPresentation(
        title: 'Plan not changed',
        body: refusal.message,
      );
  }
}
