/// The exact ALRT + purchase wording (master spec 28 Sep 2026, §9).
///
/// Kept in one place so every surface quotes the same sentences, and so
/// tests can pin them. Prices, periods, trial lengths and the store name
/// are always filled in from the store at runtime, never typed here.
library;

// --- Chooser ---------------------------------------------------------------

const kChooseHeading = 'Choose the ALRT + that fits you';
const kChooseForMyselfTitle = 'For myself';
const kChooseForMyselfBody =
    'Unlimited saved places, 10 Ask ALRT questions a day, and as many '
    'groups as you like.';
const kChooseCoverGroupTitle = 'Cover a group';
const kChooseCoverGroupBody =
    'Family (up to 6) or Group (up to 20 or 50). One person pays, and '
    'everyone in that group gets Check in, Check on, SOS and Journey.';
const kContinueFree = 'Continue with ALRT Free';

// --- Individual --------------------------------------------------------------

const kIndividualHeading = 'More for you. Wherever you go.';
const kIndividualIntro = 'Your places. Your questions. Your people, connected.';

/// The Individual benefits, in order. The Ask ALRT line says "questions",
/// matching what is counted today (open decision R03): every question that
/// needs the AI counts, not only successful answers.
const kIndividualBenefits = <String>[
  'Unlimited personal Saved Places',
  '10 Ask ALRT questions per day',
  'Join unlimited groups',
  'Check-ins, SOS and Journey sharing in eligible groups',
];

/// What ALRT + covers, in one line (My plans, Profile).
String kPersonalCoversLine(final int askPerDay) =>
    'Unlimited saved places, $askPerDay Ask ALRT questions a day, and as '
    'many groups as you like. In groups without a Family or Group plan, '
    'you can use Check in, Check on, SOS and Journey.';

const kIndividualUnlimitedGroupsLine = 'No limit on how many groups you join.';
const kIndividualScope =
    'Covers you, wherever you are. In a group without a Family or '
    'Group plan, each person taking part needs their own ALRT +.';

/// Button when no trial applies: "Subscribe for A$5.99/month".
String subscribeCta({
  required final String price,
  required final String period,
}) => 'Subscribe for $price/$period';

/// Individual disclosure. With a trial: "Eligible subscribers only.
/// [zero] today, then [price]/[period] after [duration]. Renews
/// automatically unless cancelled. Manage or cancel in your [store]
/// account." Without one, the trial sentence is omitted entirely.
String individualDisclosure({
  required final String store,
  required final String price,
  required final String period,
  final String? zeroPrice,
  final String? trialDuration,
}) {
  final renew =
      'Renews automatically unless cancelled. Manage or cancel in your '
      '$store account.';
  if (trialDuration == null || zeroPrice == null) {
    return '$price/$period. $renew';
  }
  return 'Eligible subscribers only. $zeroPrice today, then $price/$period '
      'after $trialDuration. $renew';
}

// --- Family / Group ---------------------------------------------------------

const kGroupHeading = 'Your people. One shared plan.';
const kGroupExplanation =
    'One payer. One group. Members can join with free ALRT accounts.';
const kGroupSelectorLabel = 'Group you will cover';
const kGroupBenefits = <String>[
  'Check in and Check on',
  'SOS to selected people in the group',
  'Journey and optional location sharing',
];

/// "Benefits stay inside this group. Covers up to 6 people in Smiths,
/// including you when you participate. ..."
String groupScope({required final int capacity, required final String group}) =>
    'Covers everyone in $group, up to $capacity people, you included. It '
    'does not change anyone\'s own saved places or Ask ALRT questions; '
    'those come with ALRT +.';

/// "A$15.99 charged on confirmation. No free trial. Renews monthly unless
/// cancelled. Manage or cancel in your Google Play account."
String groupDisclosure({
  required final String price,
  required final String renewsEvery,
  required final String store,
}) =>
    '$price charged on confirmation. No free trial. Renews $renewsEvery '
    'unless cancelled. Manage or cancel in your $store account.';

// --- Shared -----------------------------------------------------------------

const kSosSafetyStatement =
    'SOS notifies selected ALRT contacts. ALRT does not contact emergency '
    'services or monitor your SOS. If you are in immediate danger, call '
    'your local emergency number.';

const kCheckingPlans = 'Checking plans and offers…';
const kPurchaseConfirmedUpdating =
    'Purchase confirmed. We\'re updating your access.';
const kPurchasePending =
    'Your payment is pending with the store. ALRT + starts once it '
    'completes. You can keep using ALRT Free.';
const kPurchaseUncertain =
    'We couldn\'t confirm this purchase yet. Check your store account, or '
    'tap Restore purchases.';

/// "App Store" / "Google Play".
String storeName({required final bool isAndroid}) =>
    isAndroid ? 'Google Play' : 'App Store';

/// "month" -> "monthly", "year" -> "yearly"; anything else "every N".
String renewsEveryPhrase(final String? periodNoun) => switch (periodNoun) {
  'month' => 'monthly',
  'year' => 'yearly',
  'week' => 'weekly',
  null => 'each period',
  _ => 'every $periodNoun',
};
