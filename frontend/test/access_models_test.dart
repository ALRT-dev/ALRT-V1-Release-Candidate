import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/subscription/models/access_models.dart';
import 'package:hazard_app/features/subscription/utils/paywall_copy.dart';
import 'package:hazard_app/features/subscription/utils/trial_copy.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// GET /api/access parsing and the V1 copy helpers. The app renders what
/// the backend computed; personal plan and group coverage stay separate.
void main() {
  group('AccessSummary.fromJson', () {
    final json = {
      'billingEnabled': true,
      'personal': {
        'plan': 'free',
        'reason': 'free',
        'isTrial': false,
        'expiresAt': null,
        'willRenew': false,
        'extraSavedPlaces': 1,
        'askPerDay': 3,
      },
      'groups': [
        {
          'circleId': 'g1',
          'name': 'Nixon Family',
          'role': 'owner',
          'fundingMode': 'sponsored',
          'peopleCount': 4,
          'capacity': 6,
          'sponsorship': {
            'tier': 'family',
            'live': true,
            'status': 'active',
            'expiresAt': '2026-10-28T00:00:00.000Z',
            'coveredBy': 'Sarah',
            'youPay': true,
          },
          'connectionAccess': {'allowed': true, 'reason': 'sponsored'},
        },
        {
          'circleId': 'g2',
          'name': 'Club',
          'role': 'adult',
          'fundingMode': 'individual',
          'peopleCount': 12,
          'capacity': null,
          'sponsorship': null,
          'connectionAccess': {'allowed': false, 'reason': 'needs_individual'},
        },
      ],
      'unboundSponsorships': [
        {'id': 's1', 'tier': 'group50', 'expiresAt': null},
      ],
      'computedAt': '2026-09-28T10:00:00.000Z',
    };

    test('a payer covering a group is still personally Free', () {
      final a = AccessSummary.fromJson(json);
      expect(a.personal.isIndividual, isFalse);
      expect(a.personal.askPerDay, 3);
      expect(a.personal.extraSavedPlaces, 1);
      final g1 = a.groupById('g1')!;
      expect(g1.isSponsoredAndLive, isTrue);
      expect(g1.sponsorship!.tier, PlanTier.family);
      expect(g1.sponsorship!.youPay, isTrue);
    });

    test('an individually funded group reports this person paused', () {
      final g2 = AccessSummary.fromJson(json).groupById('g2')!;
      expect(g2.fundingMode, GroupFundingMode.individual);
      expect(g2.connectionAllowed, isFalse);
      expect(g2.connectionReason, 'needs_individual');
    });

    test('hosted groups and unbound plans are exposed', () {
      final a = AccessSummary.fromJson(json);
      expect(a.hostedGroups.map((g) => g.circleId), ['g1']);
      expect(a.unboundSponsorships.single.tier, PlanTier.group50);
    });

    test('an Individual person has no saved-place limit and 10 a day', () {
      final p = PersonalAccess.fromJson({
        'plan': 'individual',
        'reason': 'trial',
        'isTrial': true,
        'extraSavedPlaces': null,
        'askPerDay': 10,
      });
      expect(p.isIndividual, isTrue);
      expect(p.isTrial, isTrue);
      expect(p.extraSavedPlaces, isNull);
      expect(p.askPerDay, 10);
    });

    test('capacities are 6 / 20 / 50', () {
      expect(sponsoredCapacity(PlanTier.family), 6);
      expect(sponsoredCapacity(PlanTier.group20), 20);
      expect(sponsoredCapacity(PlanTier.group50), 50);
    });
  });

  group('trial offers', () {
    StoreProduct product({IntroductoryPrice? intro}) => StoreProduct(
      'alrt_individual_monthly',
      'ALRT + Individual',
      'ALRT + Individual',
      5.99,
      r'$5.99',
      'AUD',
      introductoryPrice: intro,
    );

    test('an iPhone month is "1 month", never rewritten as 30 days', () {
      final offer = freeTrialOffer(
        product(
          intro: const IntroductoryPrice(0, r'$0.00', 'P1M', 1, PeriodUnit.month, 1),
        ),
      )!;
      expect(offer.duration, '1 month');
      expect(offer.startCta, 'Start 1 month free');
    });

    test('an Android 30-day offer is "30 days"', () {
      final offer = freeTrialOffer(
        product(
          intro: const IntroductoryPrice(0, r'$0.00', 'P30D', 1, PeriodUnit.day, 30),
        ),
      )!;
      expect(offer.startCta, 'Start 30 days free');
    });

    test('iPhone only offers the trial when the store says eligible', () {
      final p = product(
        intro: const IntroductoryPrice(0, r'$0.00', 'P1M', 1, PeriodUnit.month, 1),
      );
      for (final status in [
        IntroEligibilityStatus.introEligibilityStatusIneligible,
        IntroEligibilityStatus.introEligibilityStatusUnknown,
        null,
      ]) {
        expect(
          eligibleTrialOffer(product: p, eligibility: status, isAndroid: false),
          isNull,
        );
      }
      expect(
        eligibleTrialOffer(
          product: p,
          eligibility: IntroEligibilityStatus.introEligibilityStatusEligible,
          isAndroid: false,
        ),
        isNotNull,
      );
    });

    test('no free intro period means no trial on any platform', () {
      expect(
        eligibleTrialOffer(product: product(), eligibility: null, isAndroid: true),
        isNull,
      );
    });
  });

  group('copy', () {
    test('Individual disclosure omits trial wording when there is none', () {
      final text = individualDisclosure(
        store: 'App Store',
        price: r'$5.99 AUD',
        period: 'month',
      );
      expect(text, isNot(contains('Eligible')));
      expect(text, isNot(contains('free')));
    });

    test('group disclosure always says no free trial', () {
      expect(
        groupDisclosure(
          price: r'$15.99 AUD',
          renewsEvery: 'monthly',
          store: 'Google Play',
        ),
        contains('No free trial.'),
      );
    });

    test('no em dashes and "ALRT +" with a space in every constant', () {
      for (final line in [
        kChooseHeading,
        kChooseForMyselfBody,
        kChooseCoverGroupBody,
        kIndividualHeading,
        kIndividualIntro,
        kIndividualScope,
        kGroupHeading,
        kGroupExplanation,
        kSosSafetyStatement,
        kPurchaseConfirmedUpdating,
        ...kIndividualBenefits,
        ...kGroupBenefits,
      ]) {
        expect(line, isNot(contains('—')), reason: line);
        expect(line, isNot(contains('ALRT+')), reason: line);
      }
    });
  });
}
