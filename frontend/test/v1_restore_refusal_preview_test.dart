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

AppError _coded(String code, [Map<String, dynamic>? details]) => AppError(
  message: 'server wording',
  code: '402',
  extraData: {'error': 'server wording', 'code': code, 'details': ?details},
);

void main() {
  group('Restore confirms the specific purchases found', () {
    ReconcileResult rec(
      List<(String, PlanTier?, ReconcileProductStatus, bool?)> products, {
      AccessSummary? access,
      bool checked = true,
    }) => ReconcileResult(
      storeChecked: checked,
      confirmedChanges: 0,
      unrecorded: const [],
      products: [
        for (final (id, tier, status, bound) in products)
          ReconcileProduct(productId: id, tier: tier, status: status, bound: bound),
      ],
      access: access ?? _access(),
    );
    const c = ReconcileProductStatus.confirmed;
    const pend = ReconcileProductStatus.pending;

    test('store unreachable / nothing found / ALRT unreachable', () {
      expect(
        restoreOutcome(storeFailed: true, activeStoreProducts: const [], reconcile: null).kind,
        RestoreOutcomeKind.storeUnavailable,
      );
      expect(
        restoreOutcome(storeFailed: false, activeStoreProducts: const [], reconcile: rec([])).message,
        kRestoreNothingFound,
      );
      final o = restoreOutcome(storeFailed: false, activeStoreProducts: const ['x'], reconcile: null);
      expect(o.kind, RestoreOutcomeKind.alrtUnreachable);
      expect(o.message, isNot(contains('restored')));
    });

    test('active Individual + restored Family not yet arrived: partial, never '
        '"Purchases restored"', () {
      final o = restoreOutcome(
        storeFailed: false,
        activeStoreProducts: const ['ind', 'fam'],
        reconcile: rec(
          [('ind', PlanTier.individual, c, null), ('fam', PlanTier.family, pend, null)],
          access: _access(personal: _individual),
        ),
      );
      expect(o.kind, RestoreOutcomeKind.partial);
      expect(o.message, 'Restored: ALRT +. Still confirming: ALRT + Family.');
      expect(o.message, isNot(startsWith('Purchases restored')));
    });

    test('unrelated existing access is not a restored purchase', () {
      // ALRT + already active; the store found only a Family purchase that
      // hasn't arrived. Nothing restored.
      final o = restoreOutcome(
        storeFailed: false,
        activeStoreProducts: const ['fam'],
        reconcile: rec(
          [('fam', PlanTier.family, pend, null)],
          access: _access(personal: _individual),
        ),
      );
      expect(o.kind, RestoreOutcomeKind.pending);
      expect(o.message, isNot(contains('restored')));
    });

    test('several purchases, all confirmed, each named', () {
      final o = restoreOutcome(
        storeFailed: false,
        activeStoreProducts: const ['ind', 'fam'],
        reconcile: rec(
          [('ind', PlanTier.individual, c, null), ('fam', PlanTier.family, c, true)],
          access: _access(
            personal: _individual,
            groups: [_group(sponsorship: _familyPaidByMe, mode: GroupFundingMode.sponsored)],
          ),
        ),
      );
      expect(o.kind, RestoreOutcomeKind.confirmed);
      expect(o.message, 'Purchases restored: ALRT + and ALRT + Family for Nixon Family.');
    });

    test('a valid unbound group plan is confirmed and says what to do', () {
      final o = restoreOutcome(
        storeFailed: false,
        activeStoreProducts: const ['g50'],
        reconcile: rec([('g50', PlanTier.group50, c, false)]),
      );
      expect(o.message, 'Purchases restored: ALRT + Group 50 (choose its group in My plans).');
    });

    test('server outage or missing key: unchecked, not a comparison', () {
      final o = restoreOutcome(
        storeFailed: false,
        activeStoreProducts: const ['fam'],
        reconcile: rec([('fam', PlanTier.family, ReconcileProductStatus.unchecked, null)], checked: false),
      );
      expect(o.kind, RestoreOutcomeKind.unchecked);
      expect(o.message, kRestoreUnchecked);
    });

    test('not on this account\'s server record: not linked', () {
      final o = restoreOutcome(
        storeFailed: false,
        activeStoreProducts: const ['fam'],
        reconcile: rec([('fam', PlanTier.family, ReconcileProductStatus.notFound, null)]),
      );
      expect(o.kind, RestoreOutcomeKind.notLinked);
    });

    test('an older backend that can\'t compare products is never "restored"', () {
      final o = restoreOutcome(
        storeFailed: false,
        activeStoreProducts: const ['fam'],
        reconcile: rec([], access: _access(personal: _individual)),
      );
      expect(o.kind, RestoreOutcomeKind.unchecked);
    });

    test('only non-ALRT products: nothing found', () {
      final o = restoreOutcome(
        storeFailed: false,
        activeStoreProducts: const ['other.app'],
        reconcile: rec([('other.app', null, ReconcileProductStatus.unknown, null)]),
      );
      expect(o.kind, RestoreOutcomeKind.nothingFound);
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
      expect(unreachable.title, contains('can receive an SOS'));
    });

    test('a list naming nobody in this group opens THAT list, never Invite', () {
      final r = AccessRefusal.fromError(
        _coded('NO_SOS_RECIPIENTS', {
          'hasCandidates': false,
          'sosListId': 'l1',
          'presetState': 'empty',
        }),
      )!;
      expect(r.sosListId, 'l1');
      final p = refusalPresentation(r);
      expect(p.primary, RefusalAction.editSosList);
      expect(p.primary, isNot(RefusalAction.inviteSomeone));
      final cross = refusalPresentation(
        AccessRefusal.fromError(
          _coded('SOS_PRESET_OTHER_GROUP', {'sosListId': 'l2'}),
        )!,
      );
      expect(cross.primary, RefusalAction.editSosList);
      expect(cross.primaryLabel, 'Edit this list');
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
      final many = LocalSosPreview(
        names: const ['A', 'B', 'C', 'D', 'E', 'F'],
        live: true,
      );
      expect(many.recipientsLine, 'A, B, C and 3 others');
    });
  });

  group('What a recipient is told about SOS location', () {
    final at = DateTime(2026, 9, 29, 12);
    FamilySosEvent ev({
      String? mode,
      String? label,
      DateTime? captured,
      bool isLive = false,
      double? lat,
    }) => FamilySosEvent(
      id: 's',
      circleId: 'c',
      memberId: 'm',
      isLive: isLive,
      locationMode: mode,
      locationLabel: label,
      locationCapturedAt: captured,
      latitude: lat,
      createdAt: at,
    );

    test('no location is said plainly', () {
      expect(sosLocationLine(ev(mode: 'none'), ended: false),
          'No location was shared with this SOS.');
    });
    test('a last-known point says how old it was', () {
      expect(
        sosLocationLine(
          ev(mode: 'once', label: 'Eleebana', captured: at.subtract(const Duration(minutes: 12))),
          ended: false,
        ),
        'Near Eleebana · last known location, 12 min before the SOS · shared once',
      );
    });
    test('live with no point yet never claims one', () {
      expect(sosLocationLine(ev(mode: 'live', isLive: true), ended: false),
          'Live location will appear when their phone finds them');
    });
    test('ended', () {
      expect(sosLocationLine(ev(mode: 'live'), ended: true), contains('ended'));
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
