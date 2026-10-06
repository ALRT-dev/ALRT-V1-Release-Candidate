import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/repositories/access_repository.dart';
import 'package:hazard_app/features/subscription/utils/paywall_copy.dart';
import 'package:hazard_app/features/subscription/utils/restore_outcome.dart';
import 'package:hazard_app/features/subscription/utils/purchase_error_message.dart';
import 'package:hazard_app/features/subscription/utils/store_price.dart';
import 'package:hazard_app/features/subscription/utils/trial_copy.dart';
import 'package:hazard_app/features/subscription/services/revenuecat_service.dart';
import 'package:hazard_app/features/subscription/views/widgets/paywall_parts.dart';
import 'package:hazard_app/features/subscription/views/widgets/plan_identity.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Why the Individual paywall opened (master spec §8, §13, §14). It only
/// ever opens from a personal-limit or participation moment, or from the
/// one ALRT + entry; opening another screen never triggers it.
enum AlrtPlusPaywallReason {
  /// The second saved place (Free has one besides where you are).
  savedLocation,

  /// Today's Ask ALRT questions are used up.
  askLimit,

  /// Taking part in a group funded by Individual.
  individualGroup,

  /// The ALRT + entry in Profile, onboarding or the chooser.
  general,

  /// Legacy value from the old seat model (hosting needed ALRT+). Hosting
  /// is free now; kept so an old deep link still opens the general view.
  hostCircle,
}

class AlrtPlusPaywallArgs {
  const AlrtPlusPaywallArgs({this.reason = AlrtPlusPaywallReason.general});
  final AlrtPlusPaywallReason reason;
}

/// The ALRT + Individual purchase screen (master spec §9, teal identity).
///
/// Prices, periods and any trial come from the store; a trial is offered
/// only when the store says this account is eligible, and while products
/// or eligibility are loading the screen says so instead of guessing.
/// Pops `true` once the backend confirms Individual (or the purchase is
/// confirmed and access is still updating).
class AlrtPlusPaywallScreen extends ConsumerStatefulWidget {
  const AlrtPlusPaywallScreen({super.key, this.args, this.isAndroidOverride});

  static const route = '/alrt-plus';

  final AlrtPlusPaywallArgs? args;

  /// Tests pin the platform; the app reads it from the device.
  final bool? isAndroidOverride;

  @override
  ConsumerState<AlrtPlusPaywallScreen> createState() =>
      _AlrtPlusPaywallScreenState();
}

class _AlrtPlusPaywallScreenState extends ConsumerState<AlrtPlusPaywallScreen> {
  static const _identity = PlanIdentity.individual;

  Package? _package;
  TrialOffer? _trial;
  bool _loading = true;
  bool _busy = false;
  String? _notice;
  bool _noticeIsError = false;
  bool _confirmedUpdating = false;

  /// QA builds without store keys preview the flow with labelled dummy
  /// values; never true in store builds.
  bool _dummy = false;

  bool get _isAndroid =>
      widget.isAndroidOverride ?? (!kIsWeb && Platform.isAndroid);

  String get _store => storeName(isAndroid: _isAndroid);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (isAlrtPlusTestUnlocked) {
      setState(() {
        _dummy = true;
        _loading = false;
      });
      return;
    }
    final rc = ref.read(providerOfRevenueCat);
    if (!rc.hasKeys) {
      setState(() {
        _loading = false;
        _notice =
            'This build has no billing key, so ALRT + cannot be '
            'bought here.';
        _noticeIsError = true;
      });
      return;
    }
    setState(() {
      _loading = true;
      _notice = null;
    });
    final offering = await rc.offering(RevenueCatService.personalOfferingId);
    final package =
        offering?.monthly ?? offering?.availablePackages.firstOrNull;
    Map<String, IntroEligibilityStatus> eligibility = const {};
    if (package != null && !_isAndroid) {
      eligibility = await rc.introEligibility([
        package.storeProduct.identifier,
      ]);
    }
    // This email has had its free trial before: never advertise another.
    final access = await ref.read(providerOfAccess.future);
    final trialAllowed = access?.trialEligible ?? true;
    if (!mounted) return;
    setState(() {
      _package = package;
      _trial = package == null || !trialAllowed
          ? null
          : eligibleTrialOffer(
              product: package.storeProduct,
              eligibility: eligibility[package.storeProduct.identifier],
              isAndroid: _isAndroid,
            );
      _loading = false;
      if (package == null) {
        _notice =
            'ALRT + could not be loaded from the store. '
            'Check your connection and try again.';
        _noticeIsError = true;
      }
    });
  }

  String get _price => _dummy
      ? 'A\$5.99 (preview)'
      : (_package == null ? '' : storePriceLabel(_package!.storeProduct));

  String get _period => _dummy
      ? 'month'
      : (_package == null
            ? ''
            : billingPeriodNoun(
                    _package!.storeProduct,
                    _package!.packageType,
                  ) ??
                  'period');

  TrialOffer? get _trialShown =>
      _dummy ? const TrialOffer(1, PeriodUnit.month) : _trial;

  String get _ctaLabel {
    if (_loading) return kCheckingPlans;
    final trial = _trialShown;
    if (trial != null) return trial.startCta;
    return subscribeCta(price: _price, period: _period);
  }

  String get _zeroPrice {
    final product = _package?.storeProduct;
    final intro = product?.introductoryPrice;
    if (intro != null && intro.priceString.trim().isNotEmpty) {
      return intro.priceString;
    }
    final code = product?.currencyCode ?? 'AUD';
    return NumberFormat.simpleCurrency(name: code).format(0);
  }

  Future<void> _subscribe() async {
    if (_busy) return;
    if (_dummy) {
      Navigator.of(context).pop(true);
      return;
    }
    final package = _package;
    if (package == null) return;
    setState(() {
      _busy = true;
      _notice = null;
    });
    try {
      await ref.read(providerOfRevenueCat).purchasePackage(package);
      await _confirmWithBackend();
    } catch (error) {
      final message = purchaseErrorMessage(error);
      if (mounted && message != null) {
        setState(() {
          _notice = message;
          _noticeIsError = message != kPurchasePending;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// The store said yes; access comes from the backend once RevenueCat's
  /// webhook lands. Poll briefly, then say plainly that it's updating.
  Future<void> _confirmWithBackend() async {
    final repo = ref.read(providerOfAccessRepository);
    for (var attempt = 0; attempt < 5; attempt++) {
      final result = await repo.getAccess();
      if (result.isSuccess && result.success.personal.isIndividual) {
        _invalidateAccess();
        if (mounted) Navigator.of(context).pop(true);
        return;
      }
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
    }
    _invalidateAccess();
    if (mounted) {
      setState(() {
        _confirmedUpdating = true;
        _notice = kPurchaseConfirmedUpdating;
        _noticeIsError = false;
      });
    }
  }

  void _invalidateAccess() {
    ref.invalidate(providerOfAccess);
    ref.invalidate(providerOfAlrtPlus);
    ref.invalidate(providerOfExpiredAlrtPlus);
    ref.invalidate(providerOfAlrtPlusBillingIssue);
  }

  Future<void> _restore() async {
    if (_busy) return;
    if (isAlrtPlusTestUnlocked) {
      _snack('Preview build: nothing to restore.');
      return;
    }
    setState(() {
      _busy = true;
      _notice = null;
    });
    final outcome = await runRestore(ref);
    if (!mounted) return;
    _invalidateAccess();
    final access = ref.read(providerOfAccessRepository);
    final personal = outcome.kind == RestoreOutcomeKind.confirmed
        ? await access.getAccess()
        : null;
    if (!mounted) return;
    setState(() => _busy = false);
    if (personal != null &&
        personal.isSuccess &&
        personal.success.personal.isIndividual) {
      _snack(outcome.message);
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _notice = outcome.message;
      _noticeIsError = outcome.isError;
    });
  }

  void _snack(final String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  AlrtPlusPaywallReason get _reason =>
      widget.args?.reason ?? AlrtPlusPaywallReason.general;

  /// One line on why this opened, above the benefits. Never a surprise
  /// modal: each reason matches a moment the person chose.
  String? get _reasonLine => switch (_reason) {
    AlrtPlusPaywallReason.savedLocation =>
      'ALRT Free includes one saved place as well as where you are.',
    AlrtPlusPaywallReason.askLimit =>
      'You\'ve used today\'s Ask ALRT questions on ALRT Free.',
    AlrtPlusPaywallReason.individualGroup =>
      'This group has no Family or Group plan, so each person taking part '
          'needs ALRT +.',
    AlrtPlusPaywallReason.general || AlrtPlusPaywallReason.hostCircle => null,
  };

  @override
  Widget build(BuildContext context) {
    final trial = _trialShown;
    return Scaffold(
      backgroundColor: kPaywallBody,
      body: Column(
        children: [
          PlanHero(
            identity: _identity,
            heading: kIndividualHeading,
            intro: kIndividualIntro,
            onClose: _busy ? null : () => Navigator.of(context).pop(false),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                18.spMin,
                16.spMin,
                18.spMin,
                24.spMin,
              ),
              children: [
                if (_reasonLine != null) ...[
                  PaywallNotice(text: _reasonLine!),
                  SizedBox(height: 12.spMin),
                ],
                PaywallCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final b in kIndividualBenefits)
                        PlanBenefit(text: b, identity: _identity),
                      SizedBox(height: 6.spMin),
                      PaywallFinePrint(kIndividualUnlimitedGroupsLine),
                    ],
                  ),
                ),
                SizedBox(height: 12.spMin),
                _planRow(),
                SizedBox(height: 12.spMin),
                PaywallFinePrint(kIndividualScope),
                SizedBox(height: 16.spMin),
                if (_notice != null) ...[
                  PaywallNotice(text: _notice!, isError: _noticeIsError),
                  SizedBox(height: 12.spMin),
                ],
                if (_confirmedUpdating)
                  PlanCta(
                    label: 'Done',
                    identity: _identity,
                    onPressed: () => Navigator.of(context).pop(true),
                  )
                else
                  PlanCta(
                    label: _ctaLabel,
                    identity: _identity,
                    busy: _busy,
                    onPressed: (_loading || (_package == null && !_dummy))
                        ? null
                        : _subscribe,
                  ),
                SizedBox(height: 10.spMin),
                if (!_loading && (_package != null || _dummy))
                  PaywallFinePrint(
                    individualDisclosure(
                      store: _store,
                      price: _price,
                      period: _period,
                      zeroPrice: trial == null
                          ? null
                          : (_dummy ? 'A\$0.00' : _zeroPrice),
                      trialDuration: trial?.duration,
                    ),
                    center: true,
                  ),
                if (_dummy)
                  PaywallFinePrint(
                    'Preview build: not store prices, no real purchase.',
                    center: true,
                  ),
                if (!_loading && _package == null && !_dummy && !_busy)
                  TextButton(onPressed: _load, child: const Text('Try again')),
                SizedBox(height: 14.spMin),
                PaywallFooter(
                  busy: _busy,
                  onContinueFree: () => Navigator.of(context).pop(false),
                  onRestore: _restore,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The one Individual plan: name left, store price right.
  Widget _planRow() {
    final accent = _identity.accentFor(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 12.spMin),
      decoration: BoxDecoration(
        color: _identity.tint,
        borderRadius: BorderRadius.circular(16.spMin),
        border: Border.all(color: accent, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: accent, size: 22.spMin),
          SizedBox(width: 10.spMin),
          Expanded(
            child: Text(
              'ALRT +',
              style: TextStyle(
                fontSize: 14.spMin,
                fontWeight: FontWeight.w700,
                color: kPaywallInk,
              ),
            ),
          ),
          Text(
            _loading ? '…' : (_price.isEmpty ? '' : '$_price/$_period'),
            style: TextStyle(
              fontSize: 14.spMin,
              fontWeight: FontWeight.w700,
              color: kPaywallInk,
            ),
          ),
        ],
      ),
    );
  }
}
