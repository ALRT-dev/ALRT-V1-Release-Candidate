/// The access the backend computed for the signed-in person
/// (GET /api/access, V1 access model, master spec 28 Sep 2026).
///
/// Two independent things, never merged:
/// - [personal]: ALRT + Individual (or its trial) versus ALRT Free. Only
///   this changes personal limits (saved places, Ask ALRT).
/// - [groups]: per group, how its connection features are paid for and
///   whether this person can use them there.
///
/// The app renders this; it never decides access itself. Plain classes
/// with hand-written parsing (no codegen), tolerant of missing fields.
library;

enum PersonalPlan { free, individual }

enum PlanTier { individual, family, group20, group50 }

enum GroupFundingMode { individual, sponsored }

PlanTier? planTierFromString(final Object? value) => switch (value) {
  'individual' => PlanTier.individual,
  'family' => PlanTier.family,
  'group20' => PlanTier.group20,
  'group50' => PlanTier.group50,
  _ => null,
};

DateTime? _date(final Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

class PersonalAccess {
  const PersonalAccess({
    required this.plan,
    required this.reason,
    required this.isTrial,
    required this.expiresAt,
    required this.willRenew,
    required this.extraSavedPlaces,
    required this.askPerDay,
  });

  factory PersonalAccess.fromJson(final Map<String, dynamic> json) {
    final plan = json['plan'] == 'individual'
        ? PersonalPlan.individual
        : PersonalPlan.free;
    return PersonalAccess(
      plan: plan,
      reason: json['reason']?.toString() ?? 'free',
      isTrial: json['isTrial'] == true,
      expiresAt: _date(json['expiresAt']),
      willRenew: json['willRenew'] == true,
      extraSavedPlaces: json['extraSavedPlaces'] is int
          ? json['extraSavedPlaces'] as int
          : (plan == PersonalPlan.individual ? null : 1),
      askPerDay: json['askPerDay'] is int
          ? json['askPerDay'] as int
          : (plan == PersonalPlan.individual ? 10 : 3),
    );
  }

  /// A Free person: one saved place besides where they are, 3 Ask a day.
  static const free = PersonalAccess(
    plan: PersonalPlan.free,
    reason: 'free',
    isTrial: false,
    expiresAt: null,
    willRenew: false,
    extraSavedPlaces: 1,
    askPerDay: 3,
  );

  final PersonalPlan plan;

  /// billing_disabled | individual | trial | free.
  final String reason;
  final bool isTrial;
  final DateTime? expiresAt;
  final bool willRenew;

  /// Saved places allowed besides the own-location follow; null = no limit.
  final int? extraSavedPlaces;
  final int askPerDay;

  bool get isIndividual => plan == PersonalPlan.individual;

  /// True only on a server that isn't enforcing billing yet (TEST today).
  bool get billingDisabled => reason == 'billing_disabled';
}

class GroupSponsorship {
  const GroupSponsorship({
    required this.tier,
    required this.live,
    required this.status,
    required this.expiresAt,
    required this.coveredBy,
    required this.youPay,
  });

  factory GroupSponsorship.fromJson(final Map<String, dynamic> json) =>
      GroupSponsorship(
        tier: planTierFromString(json['tier']) ?? PlanTier.family,
        live: json['live'] == true,
        status: json['status']?.toString() ?? '',
        expiresAt: _date(json['expiresAt']),
        coveredBy: json['coveredBy']?.toString(),
        youPay: json['youPay'] == true,
      );

  final PlanTier tier;
  final bool live;
  final String status;
  final DateTime? expiresAt;

  /// Display name of the payer, when known.
  final String? coveredBy;
  final bool youPay;
}

class GroupAccess {
  const GroupAccess({
    required this.circleId,
    required this.name,
    required this.role,
    required this.fundingMode,
    required this.peopleCount,
    required this.capacity,
    required this.sponsorship,
    required this.connectionAllowed,
    required this.connectionReason,
  });

  factory GroupAccess.fromJson(final Map<String, dynamic> json) {
    final access = json['connectionAccess'];
    return GroupAccess(
      circleId: json['circleId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      fundingMode: json['fundingMode'] == 'sponsored'
          ? GroupFundingMode.sponsored
          : GroupFundingMode.individual,
      peopleCount: json['peopleCount'] is int ? json['peopleCount'] as int : 0,
      capacity: json['capacity'] is int ? json['capacity'] as int : null,
      sponsorship: json['sponsorship'] is Map
          ? GroupSponsorship.fromJson(
              Map<String, dynamic>.from(json['sponsorship'] as Map),
            )
          : null,
      connectionAllowed: access is Map ? access['allowed'] == true : true,
      connectionReason: access is Map ? access['reason']?.toString() : null,
    );
  }

  final String circleId;
  final String name;
  final String role;
  final GroupFundingMode fundingMode;
  final int peopleCount;
  final int? capacity;
  final GroupSponsorship? sponsorship;
  final bool connectionAllowed;

  /// billing_disabled | sponsored | individual | sponsorship_paused |
  /// needs_individual.
  final String? connectionReason;

  bool get isHost => role == 'owner';
  bool get isSponsoredAndLive =>
      fundingMode == GroupFundingMode.sponsored && (sponsorship?.live ?? false);
  bool get isSponsorshipPaused =>
      fundingMode == GroupFundingMode.sponsored && !(sponsorship?.live ?? false);
}

class UnboundSponsorship {
  const UnboundSponsorship({
    required this.id,
    required this.tier,
    required this.expiresAt,
  });

  factory UnboundSponsorship.fromJson(final Map<String, dynamic> json) =>
      UnboundSponsorship(
        id: json['id']?.toString() ?? '',
        tier: planTierFromString(json['tier']) ?? PlanTier.family,
        expiresAt: _date(json['expiresAt']),
      );

  final String id;
  final PlanTier tier;
  final DateTime? expiresAt;
}

class AccessSummary {
  const AccessSummary({
    required this.billingEnabled,
    required this.personal,
    required this.groups,
    required this.unboundSponsorships,
    required this.computedAt,
  });

  factory AccessSummary.fromJson(final Map<String, dynamic> json) =>
      AccessSummary(
        billingEnabled: json['billingEnabled'] == true,
        personal: json['personal'] is Map
            ? PersonalAccess.fromJson(
                Map<String, dynamic>.from(json['personal'] as Map),
              )
            : PersonalAccess.free,
        groups: [
          for (final g in (json['groups'] as List? ?? const []))
            if (g is Map) GroupAccess.fromJson(Map<String, dynamic>.from(g)),
        ],
        unboundSponsorships: [
          for (final s in (json['unboundSponsorships'] as List? ?? const []))
            if (s is Map)
              UnboundSponsorship.fromJson(Map<String, dynamic>.from(s)),
        ],
        computedAt: _date(json['computedAt']),
      );

  final bool billingEnabled;
  final PersonalAccess personal;
  final List<GroupAccess> groups;
  final List<UnboundSponsorship> unboundSponsorships;
  final DateTime? computedAt;

  GroupAccess? groupById(final String circleId) {
    for (final g in groups) {
      if (g.circleId == circleId) return g;
    }
    return null;
  }

  /// Groups this person hosts (the ones they can cover with a plan).
  List<GroupAccess> get hostedGroups =>
      groups.where((g) => g.isHost).toList(growable: false);
}

/// People a sponsored plan covers in its one group.
int sponsoredCapacity(final PlanTier tier) => switch (tier) {
  PlanTier.family => 6,
  PlanTier.group20 => 20,
  PlanTier.group50 => 50,
  PlanTier.individual => 1,
};

/// "Family", "Group 20", "Group 50", "Individual".
String planTierName(final PlanTier tier) => switch (tier) {
  PlanTier.individual => 'Individual',
  PlanTier.family => 'Family',
  PlanTier.group20 => 'Group 20',
  PlanTier.group50 => 'Group 50',
};
