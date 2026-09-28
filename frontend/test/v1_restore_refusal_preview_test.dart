import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/utils/sos_preview.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/subscription/models/access_models.dart';
import 'package:hazard_app/features/subscription/utils/access_refusal.dart';
import 'package:hazard_app/features/subscription/utils/restore_outcome.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_group_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/widgets/plan_identity.dart';

AccessSummary _access({
  PersonalAccess personal = PersonalAccess.free,
  List<GroupAccess> groups = const [],
  List<UnboundSponsorship> unbound = const [],
}) => AccessSummary(
  billingEnabled: true,
  personal: personal,
  groups: groups,
  unboundSponsorships: unbound,
  computedAt: DateTime(2026, 9, 28),
);

GroupAccess _group({
  String role = 'owner',
  GroupSponsorship? sponsorship,
  GroupFundingMode mode = GroupFundingMode.individual,
}) => GroupAccess(
  circleId: 'g1',
  name: 'Nixon Family',
  role: role,
  fundingMode: mode,
  peopleCount: 6,
  capacity: sponsorship == null ? null : sponsoredCapacity(sponsorship.tier),
  sponsorship: sponsorship,
  connectionAllowed: true,
  connectionReason: 'sponsored',
);

const _familyPaidByMe = GroupSponsorship(
  tier: PlanTier.family,
  live: true,
  status: 'active',
  expiresAt: null,
  coveredBy: 'Sarah',
  youPay: true,
);

const _individual = PersonalAccess(
  plan: PersonalPlan.individual,
  reason: 'individual',
  isTrial: false,
  expiresAt: null,
  willRenew: true,
  extraSavedPlaces: null,
  askPerDay: 10,
);

ReconcileResult _reconcile(
  AccessSummary access, {
  bool checked = true,
  List<PlanTier> unrecorded = const [],
}) => ReconcileResult(
  storeChecked: checked,
  confirmedChanges: 0,
  unrecorded: unrecorded,
  access: access,
);

AppError _coded(String code, [Map<String, dynamic>? details]) => AppError(
  message: 'server wording',
  code: '402',
  extraData: {'error': 'server wording', 'code': code, 'details': ?details},
);

void main() {
  group('Restore says what really happened', () {
    test('store unreachable', () {
      final o = restoreOutcome(
        storeFailed: true,
        activeStoreProducts: const [],
        reconcile: null,
      );
      expect(o.kind, RestoreOutcomeKind.storeUnavailable);
      expect(o.isError, isTrue);
      expect(o.message, isNot(contains('restored')));
    });

    test('nothing on this store account', () {
      final o = restoreOutcome(
        storeFailed: false,
        activeStoreProducts: const [],
        reconcile: _reconcile(_access()),
      );
      expect(o.kind, RestoreOutcomeKind.nothingFound);
      expect(o.message, kRestoreNothingFound);
    });

    test('store has it, ALRT unreachable: never "restored"', () {
      final o = restoreOutcome(
        storeFailed: false,
        activeStoreProducts: const ['alrt_individual_monthly'],
        reconcile: null,
      );
      expect(o.kind, RestoreOutcomeKind.alrtUnreachable);
      expect(o.message, isNot(contains('restored')));
    });

    test('store has a purchase ALRT has not recorded: pending', () {
      final o = restoreOutcome(
        storeFailed: false,
        activeStoreProducts: const ['alrt_individual_monthly'],
        reconcile: _reconcile(_access(), unrecorded: [PlanTier.individual]),
      );
      expect(o.kind, RestoreOutcomeKind.pending);
      expect(o.message, kRestorePending);
    });

    test('unchecked store record and no paid access yet: pending', () {
      final o = restoreOutcome(
        storeFailed: false,
        activeStoreProducts: const ['alrt_family_monthly'],
        reconcile: _reconcile(_access(), checked: false),
      );
      expect(o.kind, RestoreOutcomeKind.pending);
    });

    test('confirmed: names exactly what is active', () {
      final o = restoreOutcome(
        storeFailed: false,
        activeStoreProducts: const ['a', 'b'],
        reconcile: _reconcile(
          _access(
            personal: _individual,
            groups: [
              _group(
                sponsorship: _familyPaidByMe,
                mode: GroupFundingMode.sponsored,
              ),
            ],
          ),
        ),
      );
      expect(o.kind, RestoreOutcomeKind.confirmed);
      expect(
        o.message,
        'Purchases restored. ALRT + is active for you. Your ALRT + Family '
        'plan covers Nixon Family.',
      );
    });

    test('billing switched off on the server is not a restored purchase', () {
      final o = restoreOutcome(
        storeFailed: false,
        activeStoreProducts: const ['a'],
        reconcile: _reconcile(
          _access(
            personal: const PersonalAccess(
              plan: PersonalPlan.individual,
              reason: 'billing_disabled',
              isTrial: false,
              expiresAt: null,
              willRenew: false,
              extraSavedPlaces: null,
              askPerDay: 10,
            ),
          ),
          checked: false,
        ),
      );
      expect(o.kind, RestoreOutcomeKind.pending);
    });
  });

  group('Refusals are answered for what they are', () {
    test('uncoded errors are left to the old toast', () {
      expect(AccessRefusal.fromError(const AppError(message: 'x')), isNull);
      expect(AccessRefusal.fromError(null), isNull);
    });

    test('ALRT + needed: member sees ALRT +, host can also cover the group', () {
      final r = AccessRefusal.fromError(
        _coded('INDIVIDUAL_REQUIRED', {'circleId': 'g1'}),
      )!;
      expect(r.kind, AccessRefusalKind.individualRequired);
      expect(r.circleId, 'g1');
      final member = refusalPresentation(r, group: _group(role: 'adult'));
      expect(member.primary, RefusalAction.seeAlrtPlus);
      expect(member.secondary, isNull);
      final host = refusalPresentation(r, group: _group());
      expect(host.secondary, RefusalAction.coverGroup);
    });

    test('an ended group plan never sells ALRT +', () {
      final r = AccessRefusal.fromError(_coded('GROUP_PLAN_ENDED'))!;
      final ended = GroupSponsorship(
        tier: PlanTier.family,
        live: false,
        status: 'expired',
        expiresAt: null,
        coveredBy: 'Sarah',
        youPay: true,
      );
      final payer = refusalPresentation(
        r,
        group: _group(role: 'adult', sponsorship: ended),
      );
      expect(payer.primary, RefusalAction.renewInStore);
      final host = refusalPresentation(r, group: _group());
      expect(host.primary, RefusalAction.coverGroup);
      final member = refusalPresentation(r, group: _group(role: 'adult'));
      expect(member.primary, isNull);
      for (final p in [payer, host, member]) {
        expect(p.primary, isNot(RefusalAction.seeAlrtPlus));
        expect(p.secondary, isNot(RefusalAction.seeAlrtPlus));
      }
    });

    test('a full group: the payer can upgrade, nobody is sold ALRT +', () {
      final r = AccessRefusal.fromError(
        _coded('GROUP_FULL', {'capacity': 6, 'sponsored': true}),
      )!;
      final payer = refusalPresentation(
        r,
        group: _group(
          sponsorship: _familyPaidByMe,
          mode: GroupFundingMode.sponsored,
        ),
      );
      expect(payer.body, contains('up to 6 people'));
      expect(payer.primary, RefusalAction.upgradeGroup);
      expect(payer.primaryLabel, 'Upgrade to ALRT + Group 20');
      final plain = refusalPresentation(
        AccessRefusal.fromError(
          _coded('GROUP_FULL', {'capacity': 10, 'sponsored': false}),
        )!,
      );
      expect(plain.primary, isNull);
      expect(plain.body, contains('10 people'));
    });

    test('permission refusals offer nothing to buy', () {
      for (final code in ['HOST_ONLY', 'PAYER_ONLY']) {
        final p = refusalPresentation(AccessRefusal.fromError(_coded(code))!);
        expect(p.primary, isNull, reason: code);
      }
    });

    test('no SOS recipients asks for people, and keeps the danger line', () {
      final none = refusalPresentation(
        AccessRefusal.fromError(
          _coded('NO_SOS_RECIPIENTS', {'hasCandidates': false}),
        )!,
      );
      expect(none.title, 'Add someone first');
      expect(none.primary, RefusalAction.inviteSomeone);
      expect(none.body, contains('call your local emergency number'));
      final unreachable = refusalPresentation(
        AccessRefusal.fromError(
          _coded('NO_SOS_RECIPIENTS', {'hasCandidates': true}),
        )!,
      );
      expect(unreachable.primary, isNull);
      expect(unreachable.body, contains('can receive an SOS'));
    });
  });

  group('SOS preview', () {
    const others = [
      FamilyMember(id: 'm1', userId: 'u1', name: 'Alex'),
      FamilyMember(id: 'm2', userId: 'u2', name: 'Morgan'),
      FamilyMember(id: 'm3', userId: 'u3', name: 'Taylor'),
    ];

    test('everyone, live: names and a live location line', () {
      final p = sosPreview(others: others, list: null, live: true);
      expect(p.recipientsLine, 'Alex, Morgan and Taylor');
      expect(p.locationLine, contains('live location'));
      expect(p.locationLine, contains('4 hours'));
    });

    test('a list, not live: only its people, and the one-time point', () {
      final p = sosPreview(
        others: others,
        list: const FamilySosList(
          id: 'l1',
          ownerUserId: 'me',
          name: 'Close',
          memberIds: ['m2'],
        ),
        live: false,
      );
      expect(p.recipientsLine, 'Morgan');
      expect(p.locationLine, 'Where you are when you send it, once. It '
          'won\'t update.');
    });

    test('nobody to reach is empty; long lists are summarised', () {
      expect(sosPreview(others: const [], list: null, live: true).isEmpty, isTrue);
      final many = SosPreview(
        names: const ['A', 'B', 'C', 'D', 'E', 'F'],
        live: true,
      );
      expect(many.recipientsLine, 'A, B, C and 3 others');
    });
  });

  group('Upgrades and plan identity', () {
    test('tier choices for the payer of a Family plan', () {
      expect(
        tierChoice(tier: PlanTier.family, current: PlanTier.family, peopleCount: 6),
        TierChoice.current,
      );
      expect(
        tierChoice(tier: PlanTier.group20, current: PlanTier.family, peopleCount: 6),
        TierChoice.upgrade,
      );
      expect(
        tierChoice(tier: PlanTier.family, current: PlanTier.group50, peopleCount: 6),
        TierChoice.smaller,
      );
      expect(
        tierChoice(tier: PlanTier.family, current: null, peopleCount: 7),
        TierChoice.tooSmall,
      );
    });

    test('upgrade wording is store-specific and never promises a trial', () {
      final play = upgradeDisclosure(
        isAndroid: true,
        price: r'$24.99 AUD',
        renewsEvery: 'monthly',
      );
      expect(play, contains('prorated difference'));
      expect(play, contains('No free trial.'));
      final apple = upgradeDisclosure(
        isAndroid: false,
        price: r'$24.99 AUD',
        renewsEvery: 'monthly',
      );
      expect(apple, contains('refunds the unused part'));
      expect(apple, contains('App Store'));
    });

    test('colours: ALRT + purple, Family green, Group blue, with gradients', () {
      expect(PlanIdentity.individual.accent, const Color(0xFF7B359A));
      expect(PlanIdentity.family.accent, const Color(0xFF0A7F4F));
      expect(PlanIdentity.group.accent, const Color(0xFF1F5CAD));
      for (final i in [
        PlanIdentity.individual,
        PlanIdentity.family,
        PlanIdentity.group,
      ]) {
        expect(i.gradient.length, 2);
      }
      expect(planDisplayName(PlanTier.individual), 'ALRT +');
      expect(planDisplayName(PlanTier.group50), 'ALRT + Group 50');
      expect(PlanIdentity.individual.label, 'ALRT +');
    });
  });
}
