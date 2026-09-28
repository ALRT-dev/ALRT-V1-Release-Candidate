import {
  FamilyPlan,
  type PlanTier,
  type Prisma,
  type StoreSubscription,
  type StoreSubscriptionStatus,
} from "@prisma/client";
import prisma from "../utils/prisma_client.util.js";
import { HttpError } from "../models/http_error.js";

// ---------------------------------------------------------------------------
// V1 access model (master spec 28 Sep 2026)
//
// Two independent access sources, never merged:
//  * Personal: ALRT + Individual (or its trial). Unlimited Saved Places,
//    10 Ask ALRT a day, and participation in individually funded groups.
//  * Group sponsorship: Family (6) / Group 20 / Group 50. One payer covers
//    the connection features of ONE nominated group. It grants nobody any
//    personal benefit, the payer included.
//
// RevenueCat/store state is verified INPUT (the webhook below); this module
// is the only place that turns it into access. Clients never write it.
// ---------------------------------------------------------------------------

/**
 * The single switch for the whole billing system.
 *
 * Billing is not launched. Until it is, every access check answers yes,
 * which is exactly today's behaviour. Set BILLING_ENABLED=true and the same
 * code paths start enforcing the store-synced access below.
 */
export const billingEnabled = (): boolean =>
  process.env.BILLING_ENABLED === "true";

/** People a sponsorship tier covers in its one nominated group. */
export const SPONSORED_CAPACITY: Record<Exclude<PlanTier, "individual">, number> = {
  family: 6,
  group20: 20,
  group50: 50,
};

/** Group tiers in upgrade order: Family -> Group 20 -> Group 50. */
export const SPONSOR_TIER_RANK: Record<Exclude<PlanTier, "individual">, number> = {
  family: 1,
  group20: 2,
  group50: 3,
};

/** Personal allowances by personal plan (master spec §3, §14). */
export const PERSONAL_LIMITS = {
  free: { extraSavedPlaces: 1, askPerDay: 3 },
  individual: { extraSavedPlaces: null as number | null, askPerDay: 10 },
} as const;

/** How long a sponsorship intent waits for its purchase to arrive. */
const SPONSORSHIP_INTENT_TTL_MS = 60 * 60 * 1000;

/**
 * Store product id -> tier, from RC_PRODUCT_TIERS
 * ("productA:individual,productB:family,..."). There are deliberately no
 * built-in ids: an unmapped product is recorded and ignored, never guessed,
 * so an old generic "plus" product can't grant anything by accident.
 */
export const productTierMap = (): Map<string, PlanTier> => {
  const map = new Map<string, PlanTier>();
  const raw = process.env.RC_PRODUCT_TIERS ?? "";
  for (const pair of raw.split(",")) {
    const [productId, tier] = pair.split(":").map((s) => s?.trim());
    if (!productId || !tier) continue;
    if (["individual", "family", "group20", "group50"].includes(tier)) {
      map.set(productId, tier as PlanTier);
    }
  }
  return map;
};

/** Base product id: Google sends "sub_id:base_plan_id". */
export const tierForProduct = (productId: string | null | undefined) => {
  if (!productId) return null;
  const map = productTierMap();
  return map.get(productId) ?? map.get(productId.split(":")[0]!) ?? null;
};

/** Same store product, ignoring Google's ":base_plan" suffix. */
const sameProduct = (a: string | null | undefined, b: string | null | undefined) =>
  Boolean(a && b) && (a === b || a!.split(":")[0] === b!.split(":")[0]);

const LIVE_STATUSES: StoreSubscriptionStatus[] = [
  "active",
  "cancelled",
  "billingIssue",
];

/** Whether a subscription currently grants access. */
export const isSubscriptionLive = (
  sub: Pick<StoreSubscription, "status" | "expiresAt" | "gracePeriodExpiresAt">,
  now = new Date(),
): boolean => {
  if (!LIVE_STATUSES.includes(sub.status)) return false;
  if (sub.expiresAt === null) return true; // non-expiring grant
  if (sub.expiresAt > now) return true;
  return sub.gracePeriodExpiresAt !== null && sub.gracePeriodExpiresAt > now;
};

// ---------------------------------------------------------------------------
// Personal access
// ---------------------------------------------------------------------------

export interface PersonalAccess {
  plan: "individual" | "free";
  /** Why: billing_disabled | individual | trial | free. */
  reason: "billing_disabled" | "individual" | "trial" | "free";
  isTrial: boolean;
  expiresAt: Date | null;
  willRenew: boolean;
  /** null = unlimited. Current location never counts. */
  extraSavedPlaces: number | null;
  askPerDay: number;
}

export const getPersonalAccess = async (
  userId: string,
  db: Prisma.TransactionClient | typeof prisma = prisma,
): Promise<PersonalAccess> => {
  if (!billingEnabled()) {
    return {
      plan: "individual",
      reason: "billing_disabled",
      isTrial: false,
      expiresAt: null,
      willRenew: false,
      ...PERSONAL_LIMITS.individual,
    };
  }
  const subs = await db.storeSubscription.findMany({
    where: { userId, tier: "individual" },
    orderBy: { expiresAt: "desc" },
  });
  const live = subs.find((s) => isSubscriptionLive(s));
  if (!live) {
    return {
      plan: "free",
      reason: "free",
      isTrial: false,
      expiresAt: null,
      willRenew: false,
      ...PERSONAL_LIMITS.free,
    };
  }
  const isTrial = live.periodType === "TRIAL";
  return {
    plan: "individual",
    reason: isTrial ? "trial" : "individual",
    isTrial,
    expiresAt: live.expiresAt,
    willRenew: live.status === "active",
    ...PERSONAL_LIMITS.individual,
  };
};

/** Personal Individual (or trial) is live. Always true pre-billing. */
export const hasIndividualAccess = async (userId: string): Promise<boolean> =>
  (await getPersonalAccess(userId)).plan === "individual";

/**
 * @deprecated Kept for call sites that meant "personal premium". Group
 * sponsorship never makes this true.
 */
export const hasActiveSubscription = hasIndividualAccess;

// ---------------------------------------------------------------------------
// Group coverage
// ---------------------------------------------------------------------------

export interface GroupCoverage {
  circleId: string;
  fundingMode: "individual" | "sponsored";
  /** People in the group now (every membership row, any role). */
  peopleCount: number;
  /** Sponsored capacity from the live (or last) sponsorship; null otherwise. */
  capacity: number | null;
  sponsorship: {
    id: string;
    tier: PlanTier;
    payerUserId: string;
    live: boolean;
    status: StoreSubscriptionStatus;
    expiresAt: Date | null;
    productId: string;
    store: string | null;
    /** A requested change the store has not confirmed yet. */
    pendingTier: PlanTier | null;
  } | null;
  /** Sponsored group whose sponsorship is not live: grants are paused. */
  sponsorshipPaused: boolean;
}

export const getGroupCoverage = async (
  circleId: string,
  db: Prisma.TransactionClient | typeof prisma = prisma,
): Promise<GroupCoverage> => {
  const circle = await db.familyCircle.findUnique({
    where: { id: circleId },
    select: { id: true, fundingMode: true, _count: { select: { members: true } } },
  });
  if (!circle) throw new HttpError(404, "Group not found");

  const subs = await db.storeSubscription.findMany({
    where: { boundCircleId: circleId, tier: { not: "individual" }, supersededAt: null },
    orderBy: [{ lastEventAt: "desc" }],
  });
  const live = subs.find((s) => isSubscriptionLive(s));
  const current = live ?? subs[0] ?? null;

  return {
    circleId,
    fundingMode: circle.fundingMode,
    peopleCount: circle._count.members,
    capacity:
      current && current.tier !== "individual"
        ? SPONSORED_CAPACITY[current.tier]
        : null,
    sponsorship: current
      ? {
          id: current.id,
          tier: current.tier,
          payerUserId: current.userId,
          live: Boolean(live),
          status: current.status,
          expiresAt: current.expiresAt,
          productId: current.productId,
          store: current.store,
          pendingTier: current.pendingTier,
        }
      : null,
    sponsorshipPaused: circle.fundingMode === "sponsored" && !live,
  };
};

export type ConnectionAccessReason =
  | "billing_disabled"
  | "sponsored"
  | "individual"
  | "sponsorship_paused"
  | "needs_individual";

export interface ConnectionAccess {
  allowed: boolean;
  reason: ConnectionAccessReason;
}

/**
 * Whether [userId] may use the covered connection features (check in,
 * check on, SOS, Journey, location sharing) in [circleId]. Per person, per
 * group: one person's lapse never switches anyone else off, and one group's
 * sponsorship never reaches into another group.
 */
export const getConnectionAccess = async (
  userId: string,
  circleId: string,
  db: Prisma.TransactionClient | typeof prisma = prisma,
): Promise<ConnectionAccess> => {
  if (!billingEnabled()) return { allowed: true, reason: "billing_disabled" };
  const coverage = await getGroupCoverage(circleId, db);
  if (coverage.fundingMode === "sponsored") {
    return coverage.sponsorship?.live
      ? { allowed: true, reason: "sponsored" }
      : { allowed: false, reason: "sponsorship_paused" };
  }
  return (await getPersonalAccess(userId, db)).plan === "individual"
    ? { allowed: true, reason: "individual" }
    : { allowed: false, reason: "needs_individual" };
};

/** Throws a 402 the app can act on when connection access is missing. */
export const assertConnectionAccess = async (
  userId: string,
  circleId: string,
) => {
  const access = await getConnectionAccess(userId, circleId);
  if (access.allowed) return access;
  if (access.reason === "sponsorship_paused") {
    throw new HttpError(
      402,
      "This group's plan has ended, so check-ins, SOS and Journey are paused here. Stopping and ending still work.",
      "GROUP_PLAN_ENDED",
      { circleId },
    );
  }
  throw new HttpError(
    402,
    "Each person in this group needs ALRT + to take part. You can start ALRT +, or the host can cover the group with a Family or Group plan.",
    "INDIVIDUAL_REQUIRED",
    { circleId },
  );
};

/**
 * Throws 409 when adding [adding] people would take a sponsored group past
 * its capacity. Individually funded groups have no commercial cap (their
 * capacity is an open decision, R01); the technical maxMembers limit on the
 * circle still applies separately. Call inside the join transaction after
 * locking the circle row so concurrent joins can't both pass.
 */
export const assertSponsoredCapacity = async (
  circleId: string,
  adding: number,
  db: Prisma.TransactionClient | typeof prisma = prisma,
) => {
  const coverage = await getGroupCoverage(circleId, db);
  if (coverage.fundingMode !== "sponsored" || coverage.capacity === null) {
    return coverage;
  }
  if (coverage.peopleCount + adding > coverage.capacity) {
    throw new HttpError(
      409,
      `This group's plan covers up to ${coverage.capacity} people and is full.`,
      "GROUP_FULL",
      { capacity: coverage.capacity, sponsored: true },
    );
  }
  return coverage;
};

// ---------------------------------------------------------------------------
// Sponsorship intents and binding
// ---------------------------------------------------------------------------

/**
 * Records "this payer is about to buy [tier] for [circleId]" before the
 * store sheet opens. The payer must host the group; capacity is checked
 * now and again when the purchase is bound.
 *
 * Upgrades (Family -> Group 20 -> Group 50): when the group already has a
 * live plan, only the person paying for it may choose a bigger tier. The
 * intent then names the subscription it replaces, so the new purchase
 * takes over the SAME group once the store confirms it, whether the store
 * keeps the transaction (App Store) or issues a new one (Google Play
 * replacement). A smaller tier is changed in the store and applies at
 * renewal, never from here.
 */
export const createSponsorshipIntent = async (
  payerUserId: string,
  circleId: string,
  tier: Exclude<PlanTier, "individual">,
) => {
  const coverage = await getGroupCoverage(circleId);
  const current = coverage.sponsorship?.live ? coverage.sponsorship : null;

  if (current) {
    if (current.payerUserId !== payerUserId) {
      throw new HttpError(
        409,
        "This group is already covered by someone else's plan.",
        "GROUP_ALREADY_COVERED",
      );
    }
    const from = current.tier as Exclude<PlanTier, "individual">;
    if (SPONSOR_TIER_RANK[tier] === SPONSOR_TIER_RANK[from]) {
      throw new HttpError(409, "This group already has this plan.", "GROUP_ALREADY_COVERED");
    }
    if (SPONSOR_TIER_RANK[tier] < SPONSOR_TIER_RANK[from]) {
      throw new HttpError(
        409,
        "To move to a smaller plan, change it in your app store. It takes effect when your current period renews.",
        "CHANGE_IN_STORE",
      );
    }
  } else {
    const host = await prisma.familyMember.findFirst({
      where: { circleId, userId: payerUserId, role: "owner" },
      select: { id: true },
    });
    if (!host) {
      throw new HttpError(403, "Only the group's host can choose a plan for it.", "HOST_ONLY");
    }
  }
  if (coverage.peopleCount > SPONSORED_CAPACITY[tier]) {
    throw new HttpError(
      409,
      `This group has ${coverage.peopleCount} people. Choose a plan that covers at least that many.`,
      "PLAN_TOO_SMALL",
      { peopleCount: coverage.peopleCount },
    );
  }
  const intent = await prisma.sponsorshipIntent.create({
    data: {
      payerUserId,
      circleId,
      tier,
      replacesSubscriptionId: current?.id ?? null,
      expiresAt: new Date(Date.now() + SPONSORSHIP_INTENT_TTL_MS),
    },
  });
  return {
    ...intent,
    // What the app needs for a store replacement (Android asks for the old
    // product id). Never a transaction or token.
    replaces: current
      ? { tier: current.tier, productId: current.productId, store: current.store }
      : null,
  };
};

/**
 * Binds a verified, unbound sponsorship to a group, once, inside one
 * transaction that locks the group row. Used by the webhook (intent match)
 * and by the payer when an intent was not matched.
 */
export const bindSponsorship = async (
  subscriptionId: string,
  circleId: string,
  actingUserId: string,
  intentId?: string,
) => {
  return prisma.$transaction(async (tx) => {
    await tx.$queryRaw`SELECT id FROM "FamilyCircle" WHERE id = ${circleId} FOR UPDATE`;
    const sub = await tx.storeSubscription.findUnique({
      where: { id: subscriptionId },
    });
    if (!sub || sub.tier === "individual") {
      throw new HttpError(404, "Group plan purchase not found");
    }
    if (sub.userId !== actingUserId) {
      throw new HttpError(403, "Only the person who bought this plan can apply it.", "PAYER_ONLY");
    }
    if (sub.boundCircleId) {
      if (sub.boundCircleId === circleId) return sub; // idempotent
      throw new HttpError(409, "This plan already covers another group.", "GROUP_ALREADY_COVERED");
    }
    if (!isSubscriptionLive(sub)) {
      throw new HttpError(409, "This plan is no longer active.");
    }
    const host = await tx.familyMember.findFirst({
      where: { circleId, userId: actingUserId, role: "owner" },
      select: { id: true },
    });
    if (!host) {
      throw new HttpError(403, "Only the group's host can choose a plan for it.", "HOST_ONLY");
    }
    const otherLive = await tx.storeSubscription.findMany({
      where: { boundCircleId: circleId, tier: { not: "individual" }, supersededAt: null },
    });
    if (otherLive.some((s) => isSubscriptionLive(s))) {
      throw new HttpError(409, "This group already has a plan.", "GROUP_ALREADY_COVERED");
    }
    const people = await tx.familyMember.count({ where: { circleId } });
    if (people > SPONSORED_CAPACITY[sub.tier]) {
      throw new HttpError(
        409,
        `This group has ${people} people, more than this plan covers.`,
        "PLAN_TOO_SMALL",
        { peopleCount: people },
      );
    }
    const bound = await tx.storeSubscription.update({
      where: { id: sub.id },
      data: { boundCircleId: circleId, boundAt: new Date() },
    });
    await tx.familyCircle.update({
      where: { id: circleId },
      data: { fundingMode: "sponsored" },
    });
    if (intentId) {
      await tx.sponsorshipIntent.update({
        where: { id: intentId },
        data: { consumedAt: new Date(), subscriptionId: sub.id },
      });
    }
    return bound;
  });
};

/**
 * The store has confirmed [newId] replaces [oldId] (an upgrade, or a
 * downgrade that has now taken effect). The new subscription takes over
 * the old one's group in one locked transaction; the old row is kept as
 * history and marked superseded so the group is never counted twice.
 * Capacity is not re-checked here: the store has already charged for the
 * new tier, and an over-capacity group only blocks new joins (R02).
 */
export const replaceSponsorship = async (
  oldId: string,
  newId: string,
  intentId?: string,
) =>
  prisma.$transaction(async (tx) => {
    const old = await tx.storeSubscription.findUnique({ where: { id: oldId } });
    if (!old?.boundCircleId) return null;
    await tx.$queryRaw`SELECT id FROM "FamilyCircle" WHERE id = ${old.boundCircleId} FOR UPDATE`;
    const fresh = await tx.storeSubscription.findUnique({ where: { id: oldId } });
    const next = await tx.storeSubscription.findUnique({ where: { id: newId } });
    if (!fresh || !next || fresh.supersededAt || next.boundCircleId) return null;
    if (fresh.userId !== next.userId || next.tier === "individual") return null;
    const now = new Date();
    const bound = await tx.storeSubscription.update({
      where: { id: next.id },
      data: { boundCircleId: fresh.boundCircleId, boundAt: now, tierChangedAt: now },
    });
    await tx.storeSubscription.update({
      where: { id: fresh.id },
      data: {
        supersededAt: now,
        supersededById: next.id,
        pendingProductId: null,
        pendingTier: null,
        pendingRequestedAt: null,
      },
    });
    await tx.familyCircle.update({
      where: { id: fresh.boundCircleId! },
      data: { fundingMode: "sponsored" },
    });
    if (intentId) {
      await tx.sponsorshipIntent.update({
        where: { id: intentId },
        data: { consumedAt: now, subscriptionId: next.id },
      });
    }
    return bound;
  });

/**
 * Explicit, never automatic: returns a sponsored group to individual
 * funding (each person then needs Individual). Host only, and only when
 * no live sponsorship covers it.
 */
export const switchGroupToIndividualFunding = async (
  userId: string,
  circleId: string,
) => {
  const host = await prisma.familyMember.findFirst({
    where: { circleId, userId, role: "owner" },
    select: { id: true },
  });
  if (!host) throw new HttpError(403, "Only the group's host can change this.", "HOST_ONLY");
  const coverage = await getGroupCoverage(circleId);
  if (coverage.sponsorship?.live) {
    throw new HttpError(409, "This group's plan is still active.");
  }
  return prisma.familyCircle.update({
    where: { id: circleId },
    data: { fundingMode: "individual" },
  });
};

// ---------------------------------------------------------------------------
// Access summary for the app (GET /api/access)
// ---------------------------------------------------------------------------

export const getAccessSummary = async (userId: string) => {
  const personal = await getPersonalAccess(userId);
  const memberships = await prisma.familyMember.findMany({
    where: { userId },
    orderBy: { createdAt: "asc" },
    select: { circleId: true, role: true, circle: { select: { name: true } } },
  });
  const groups = [];
  for (const m of memberships) {
    const coverage = await getGroupCoverage(m.circleId);
    const access = await getConnectionAccess(userId, m.circleId);
    let coveredBy: string | null = null;
    if (coverage.sponsorship) {
      const payer = await prisma.user.findUnique({
        where: { id: coverage.sponsorship.payerUserId },
        select: { name: true },
      });
      coveredBy = payer?.name ?? null;
    }
    groups.push({
      circleId: m.circleId,
      name: m.circle.name,
      role: m.role,
      fundingMode: coverage.fundingMode,
      peopleCount: coverage.peopleCount,
      capacity: coverage.capacity,
      sponsorship: coverage.sponsorship
        ? {
            tier: coverage.sponsorship.tier,
            live: coverage.sponsorship.live,
            status: coverage.sponsorship.status,
            expiresAt: coverage.sponsorship.expiresAt,
            coveredBy,
            youPay: coverage.sponsorship.payerUserId === userId,
            pendingTier: coverage.sponsorship.pendingTier,
            // Only the payer needs these (store management and Android
            // replacement); nobody else sees another person's product.
            ...(coverage.sponsorship.payerUserId === userId
              ? {
                  productId: coverage.sponsorship.productId,
                  store: coverage.sponsorship.store,
                }
              : {}),
          }
        : null,
      connectionAccess: access,
    });
  }
  const unboundSponsorships = billingEnabled()
    ? (
        await prisma.storeSubscription.findMany({
          where: { userId, tier: { not: "individual" }, boundCircleId: null, supersededAt: null },
        })
      )
        .filter((s) => isSubscriptionLive(s))
        .map((s) => ({ id: s.id, tier: s.tier, expiresAt: s.expiresAt }))
    : [];
  return {
    billingEnabled: billingEnabled(),
    personal,
    groups,
    unboundSponsorships,
    computedAt: new Date(),
  };
};

// ---------------------------------------------------------------------------
// RevenueCat webhook
// ---------------------------------------------------------------------------

export interface RevenueCatEvent {
  id?: string;
  type?: string;
  app_id?: string;
  app_user_id?: string;
  original_app_user_id?: string;
  aliases?: string[] | null;
  product_id?: string | null;
  new_product_id?: string | null;
  original_transaction_id?: string | null;
  transaction_id?: string | null;
  period_type?: string | null;
  environment?: string | null;
  entitlement_ids?: string[] | null;
  event_timestamp_ms?: number | null;
  purchased_at_ms?: number | null;
  expiration_at_ms?: number | null;
  grace_period_expiration_at_ms?: number | null;
  cancel_reason?: string | null;
  store?: string | null;
  transferred_from?: string[] | null;
  transferred_to?: string[] | null;
}

export interface ApplyResult {
  action: "applied" | "duplicate" | "ignored";
  reason?: string;
}

/** Lifecycle status an event leaves the subscription in, or null. */
const statusForEvent = (
  event: RevenueCatEvent,
): StoreSubscriptionStatus | null => {
  switch (event.type) {
    case "INITIAL_PURCHASE":
    case "RENEWAL":
    case "UNCANCELLATION":
    case "SUBSCRIPTION_EXTENDED":
    case "TEMPORARY_ENTITLEMENT_GRANT":
    case "NON_RENEWING_PURCHASE":
      return "active";
    case "CANCELLATION":
      // A refund arrives as CANCELLATION with CUSTOMER_SUPPORT; everything
      // else only turns auto-renew off and access runs to expiry.
      return event.cancel_reason === "CUSTOMER_SUPPORT" ? "refunded" : "cancelled";
    case "BILLING_ISSUE":
      return "billingIssue";
    case "EXPIRATION":
      return "expired";
    default:
      return null; // TEST, TRANSFER (handled separately), SUBSCRIPTION_PAUSED...
  }
};

const expectedEnvironment = () =>
  (process.env.RC_EXPECTED_ENVIRONMENT ?? "").trim().toUpperCase();

const allowedAppIds = () =>
  (process.env.RC_APP_IDS ?? "")
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean);

/**
 * Applies one authenticated RevenueCat event. Idempotent on event.id,
 * ignores events older than the newest one already applied to the same
 * subscription, and never trusts a client-editable attribute for the group.
 */
export const applyRevenueCatEvent = async (
  event: RevenueCatEvent,
): Promise<ApplyResult> => {
  const type = event.type ?? "";
  const eventAt = event.event_timestamp_ms
    ? new Date(event.event_timestamp_ms)
    : new Date();

  if (event.id) {
    const seen = await prisma.revenueCatWebhookEvent.findUnique({
      where: { id: event.id },
    });
    if (seen?.processedAt) return { action: "duplicate" };
    if (!seen) {
      await prisma.revenueCatWebhookEvent.create({
        data: {
          id: event.id,
          type,
          appUserId: event.app_user_id ?? null,
          productId: event.product_id ?? null,
          eventAt,
        },
      });
    }
  }

  const finish = async (result: ApplyResult) => {
    if (event.id) {
      await prisma.revenueCatWebhookEvent.update({
        where: { id: event.id },
        data: {
          processedAt: new Date(),
          result: `${result.action}${result.reason ? `: ${result.reason}` : ""}`,
        },
      });
    }
    return result;
  };

  const env = expectedEnvironment();
  if (env && event.environment && event.environment.toUpperCase() !== env) {
    return finish({ action: "ignored", reason: `environment ${event.environment}` });
  }
  const apps = allowedAppIds();
  if (apps.length > 0 && event.app_id && !apps.includes(event.app_id)) {
    return finish({ action: "ignored", reason: `app ${event.app_id}` });
  }

  if (type === "TRANSFER") {
    return finish(await applyTransfer(event));
  }

  const userId = event.app_user_id || event.original_app_user_id || "";
  if (!userId || userId.startsWith("$RCAnonymousID:")) {
    return finish({ action: "ignored", reason: "anonymous or missing app_user_id" });
  }
  if (type === "PRODUCT_CHANGE") {
    const result = await recordPendingChange(event, userId, eventAt);
    if (result.action === "applied") await confirmPendingChanges(userId);
    return finish(result);
  }

  const status = statusForEvent(event);
  if (!status) return finish({ action: "ignored", reason: `event type ${type}` });

  const productId = event.product_id;
  const tier = tierForProduct(productId);
  if (!tier) {
    return finish({ action: "ignored", reason: `unmapped product ${productId ?? "?"}` });
  }
  const originalTransactionId =
    event.original_transaction_id || event.transaction_id;
  if (!originalTransactionId) {
    return finish({ action: "ignored", reason: "no transaction id" });
  }

  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { id: true },
  });
  if (!user) return finish({ action: "ignored", reason: "unknown user id" });

  const existing = await prisma.storeSubscription.findUnique({
    where: { originalTransactionId },
  });
  if (existing && existing.lastEventAt > eventAt) {
    return finish({ action: "ignored", reason: "older than the state already applied" });
  }
  if (existing && existing.userId !== user.id) {
    // Purchase ownership only moves through TRANSFER, never a stray event.
    return finish({ action: "ignored", reason: "transaction belongs to another user" });
  }
  if (existing && (existing.tier === "individual") !== (tier === "individual")) {
    // Never let one transaction switch between personal and sponsorship.
    return finish({ action: "ignored", reason: "tier family changed on one transaction" });
  }

  // A lifecycle event naming a different product on the same transaction is
  // the store confirming a change has taken effect (for example the RENEWAL
  // that starts a scheduled downgrade). Only then does the tier move.
  const tierChanged = Boolean(existing && existing.tier !== tier);
  const pendingConfirmed =
    existing && sameProduct(existing.pendingProductId, productId);

  const data = {
    tier,
    productId: productId!,
    store: event.store ?? existing?.store ?? null,
    environment: event.environment ?? existing?.environment ?? null,
    status,
    periodType: event.period_type ?? existing?.periodType ?? null,
    expiresAt: event.expiration_at_ms
      ? new Date(event.expiration_at_ms)
      : status === "expired" || status === "refunded"
        ? eventAt
        : (existing?.expiresAt ?? null),
    gracePeriodExpiresAt: event.grace_period_expiration_at_ms
      ? new Date(event.grace_period_expiration_at_ms)
      : null,
    lastEventAt: eventAt,
    ...(tierChanged ? { tierChangedAt: eventAt, changeConfirmedVia: "webhook" } : {}),
    ...(pendingConfirmed || status === "expired" || status === "refunded"
      ? { pendingProductId: null, pendingTier: null, pendingRequestedAt: null }
      : {}),
  };

  const sub = existing
    ? await prisma.storeSubscription.update({ where: { id: existing.id }, data })
    : await prisma.storeSubscription.create({
        data: { ...data, userId: user.id, originalTransactionId },
      });

  if (tierChanged && tier !== "individual") {
    await consumeReplaceIntents(sub.id, tier);
  }

  // A new group purchase either replaces the payer's current plan for a
  // group (upgrade, or a confirmed scheduled change that arrived as a new
  // store transaction), or binds to the payer's one open intent for that
  // tier. Anything ambiguous stays unbound and the payer chooses the group
  // in the app (never an arbitrary current group).
  if (tier !== "individual" && !sub.boundCircleId && isSubscriptionLive(sub)) {
    const replacement = await findReplacedSponsorship(user.id, sub.id, productId!, tier);
    if (replacement) {
      await replaceSponsorship(replacement.oldId, sub.id, replacement.intentId);
    } else {
      const intents = await prisma.sponsorshipIntent.findMany({
        where: {
          payerUserId: user.id,
          tier,
          consumedAt: null,
          replacesSubscriptionId: null,
          expiresAt: { gt: new Date(Date.now() - SPONSORSHIP_INTENT_TTL_MS) },
        },
      });
      if (intents.length === 1) {
        try {
          await bindSponsorship(sub.id, intents[0]!.circleId, user.id, intents[0]!.id);
        } catch (error) {
          console.warn(
            `[revenuecat] purchase ${sub.id} left unbound: ${(error as Error).message}`,
          );
        }
      }
    }
  }

  if (tier === "individual") await syncPersonalMirror(user.id);
  return finish({
    action: "applied",
    reason: `${tier} ${status}${tierChanged ? " (change confirmed)" : ""}`,
  });
};

/**
 * PRODUCT_CHANGE means a change was REQUESTED. The store may apply it now
 * (most upgrades) or at renewal (downgrades), so the active tier never
 * moves here: the request is kept as pending until a store event, or the
 * store's own subscriber record, shows the new product in effect.
 */
const recordPendingChange = async (
  event: RevenueCatEvent,
  userId: string,
  eventAt: Date,
): Promise<ApplyResult> => {
  const newTier = tierForProduct(event.new_product_id);
  if (!newTier) {
    return { action: "ignored", reason: `unmapped product ${event.new_product_id ?? "?"}` };
  }
  const txId = event.original_transaction_id || event.transaction_id;
  let row = txId
    ? await prisma.storeSubscription.findUnique({ where: { originalTransactionId: txId } })
    : null;
  if (!row) {
    // Google can report the change against the new purchase token: find
    // the payer's one current subscription for the old product instead.
    const candidates = (
      await prisma.storeSubscription.findMany({
        where: { userId, supersededAt: null },
      })
    ).filter((r) => sameProduct(r.productId, event.product_id) && isSubscriptionLive(r));
    row = candidates.length === 1 ? candidates[0]! : null;
  }
  if (!row) return { action: "ignored", reason: "product change for an unknown subscription" };
  if (row.userId !== userId) {
    return { action: "ignored", reason: "transaction belongs to another user" };
  }
  if ((row.tier === "individual") !== (newTier === "individual")) {
    return { action: "ignored", reason: "tier family changed on one transaction" };
  }
  if (row.lastEventAt > eventAt) {
    return { action: "ignored", reason: "older than the state already applied" };
  }
  const reverted = sameProduct(event.new_product_id, row.productId);
  await prisma.storeSubscription.update({
    where: { id: row.id },
    data: reverted
      ? { pendingProductId: null, pendingTier: null, pendingRequestedAt: null, lastEventAt: eventAt }
      : {
          pendingProductId: event.new_product_id!,
          pendingTier: newTier,
          pendingRequestedAt: eventAt,
          lastEventAt: eventAt,
        },
  });
  return {
    action: "applied",
    reason: reverted ? "pending change withdrawn" : `pending ${newTier} (not in effect yet)`,
  };
};

/**
 * Which of the payer's bound plans a NEW group transaction replaces: the
 * one named by an open upgrade intent, or the one whose pending change is
 * for this product. Exactly one candidate or none: never a guess.
 */
const findReplacedSponsorship = async (
  payerUserId: string,
  newSubId: string,
  productId: string,
  tier: PlanTier,
): Promise<{ oldId: string; intentId?: string | undefined } | null> => {
  const found = new Map<string, string | undefined>();
  const intents = await prisma.sponsorshipIntent.findMany({
    where: {
      payerUserId,
      tier,
      consumedAt: null,
      replacesSubscriptionId: { not: null },
      expiresAt: { gt: new Date(Date.now() - SPONSORSHIP_INTENT_TTL_MS) },
    },
  });
  for (const intent of intents) found.set(intent.replacesSubscriptionId!, intent.id);
  const rows = await prisma.storeSubscription.findMany({
    where: {
      userId: payerUserId,
      tier: { not: "individual" },
      boundCircleId: { not: null },
      supersededAt: null,
      id: { not: newSubId },
    },
  });
  for (const row of rows) {
    const pendingMatch = sameProduct(row.pendingProductId, productId);
    // Already switched from the store's subscriber record; this is the
    // same change arriving as its own transaction.
    const apiMatch =
      row.changeConfirmedVia === "revenuecat_api" && sameProduct(row.productId, productId);
    if ((pendingMatch || apiMatch) && !found.has(row.id)) found.set(row.id, undefined);
  }
  const live = [];
  for (const [oldId, intentId] of found) {
    const row = rows.find((r) => r.id === oldId);
    if (row) live.push({ oldId, intentId });
  }
  return live.length === 1 ? live[0]! : null;
};

/** A change confirmed on the same transaction fulfils its upgrade intent. */
const consumeReplaceIntents = async (subId: string, tier: PlanTier) => {
  await prisma.sponsorshipIntent.updateMany({
    where: { replacesSubscriptionId: subId, tier, consumedAt: null },
    data: { consumedAt: new Date() },
  });
};

type Fetch = typeof fetch;

export interface ReconcileResult {
  /** False when the store record could not be read (no key, or an error). */
  checked: boolean;
  /** Requested changes the store record shows in effect, now applied. */
  confirmedChanges: number;
  /** Active store purchases ALRT has no confirmed record of yet. */
  unrecorded: { productId: string; tier: PlanTier }[];
  error?: string;
}

/**
 * Reads the payer's subscriber record from RevenueCat's server API (never
 * from the app) to confirm pending changes and to spot purchases whose
 * webhook has not arrived. Optional: without REVENUECAT_SECRET_API_KEY it
 * reports checked=false and pending changes wait for the next store event.
 */
export const confirmPendingChanges = async (
  userId: string,
  fetchImpl: Fetch = fetch,
): Promise<ReconcileResult> => {
  const key = process.env.REVENUECAT_SECRET_API_KEY;
  const base = process.env.REVENUECAT_API_BASE ?? "https://api.revenuecat.com";
  if (!key) return { checked: false, confirmedChanges: 0, unrecorded: [] };
  let subscriptions: Record<string, any> = {};
  try {
    const res = await fetchImpl(`${base}/v1/subscribers/${encodeURIComponent(userId)}`, {
      headers: { Authorization: `Bearer ${key}`, Accept: "application/json" },
    });
    if (!res.ok) {
      return { checked: false, confirmedChanges: 0, unrecorded: [], error: `RevenueCat ${res.status}` };
    }
    const body = (await res.json()) as any;
    subscriptions = body?.subscriber?.subscriptions ?? {};
  } catch (error) {
    return { checked: false, confirmedChanges: 0, unrecorded: [], error: (error as Error).message };
  }

  const now = Date.now();
  const env = expectedEnvironment();
  const inEffect = (productId: string, since?: Date | null) => {
    const key = Object.keys(subscriptions).find((k) => sameProduct(k, productId));
    const entry = key ? subscriptions[key] : null;
    if (!entry || entry.refunded_at) return null;
    if (env === "PRODUCTION" && entry.is_sandbox === true) return null;
    if (env === "SANDBOX" && entry.is_sandbox === false) return null;
    const started = Date.parse(entry.purchase_date ?? "");
    const ends = entry.expires_date ? Date.parse(entry.expires_date) : null;
    if (!Number.isFinite(started) || started > now) return null;
    if (ends !== null && ends <= now) return null;
    // A purchase of this product from before the request is not the change.
    if (since && started < since.getTime() - 5 * 60 * 1000) return null;
    return { entry, ends };
  };

  let confirmedChanges = 0;
  const pending = await prisma.storeSubscription.findMany({
    where: { userId, supersededAt: null, pendingProductId: { not: null } },
  });
  for (const row of pending) {
    const hit = inEffect(row.pendingProductId!, row.pendingRequestedAt);
    if (!hit || !row.pendingTier) continue;
    const at = new Date();
    await prisma.storeSubscription.update({
      where: { id: row.id },
      data: {
        tier: row.pendingTier,
        productId: row.pendingProductId!,
        expiresAt: hit.ends !== null ? new Date(hit.ends) : row.expiresAt,
        tierChangedAt: at,
        changeConfirmedVia: "revenuecat_api",
        pendingProductId: null,
        pendingTier: null,
        pendingRequestedAt: null,
      },
    });
    await consumeReplaceIntents(row.id, row.pendingTier);
    confirmedChanges += 1;
  }

  const rows = await prisma.storeSubscription.findMany({
    where: { userId, supersededAt: null },
  });
  const unrecorded: ReconcileResult["unrecorded"] = [];
  for (const productId of Object.keys(subscriptions)) {
    const tier = tierForProduct(productId);
    if (!tier || !inEffect(productId)) continue;
    const known = rows.some((r) => sameProduct(r.productId, productId) && isSubscriptionLive(r));
    if (!known) unrecorded.push({ productId, tier });
  }
  if (confirmedChanges > 0) await syncPersonalMirror(userId);
  return { checked: true, confirmedChanges, unrecorded };
};

/** TRANSFER moves a store account's purchases between app users. */
const applyTransfer = async (event: RevenueCatEvent): Promise<ApplyResult> => {
  const from = (event.transferred_from ?? []).filter(
    (id) => !id.startsWith("$RCAnonymousID:"),
  );
  const to = (event.transferred_to ?? []).find(
    (id) => !id.startsWith("$RCAnonymousID:"),
  );
  if (!to || from.length === 0) {
    return { action: "ignored", reason: "transfer without known users" };
  }
  const target = await prisma.user.findUnique({ where: { id: to }, select: { id: true } });
  if (!target) return { action: "ignored", reason: "transfer to unknown user" };
  // Sponsorships keep their bound group (the group's coverage continues);
  // who pays for it now is the new account. Payer change policy is R02.
  await prisma.storeSubscription.updateMany({
    where: { userId: { in: from } },
    data: { userId: target.id },
  });
  for (const id of [...from, target.id]) await syncPersonalMirror(id);
  return { action: "applied", reason: `transfer to ${target.id}` };
};

/**
 * Keeps the compatibility mirrors in step with the canonical personal
 * entitlement: User.plan (old app builds) and Firestore
 * entitlements/{uid} (Ask ALRT). Both are written only from here, with a
 * version so a stale write can be told apart.
 */
export const syncPersonalMirror = async (userId: string) => {
  const personal = await getPersonalAccess(userId);
  const isIndividual = personal.plan === "individual" && personal.reason !== "billing_disabled";
  await prisma.user.updateMany({
    where: { id: userId },
    data: {
      plan: isIndividual ? FamilyPlan.plus : FamilyPlan.free,
      planExpiresAt: isIndividual ? personal.expiresAt : null,
      planUpdatedAt: new Date(),
    },
  });
  try {
    const { firebaseAdmin } = await import("../utils/firebase_admin_client.util.js");
    await firebaseAdmin
      .firestore()
      .collection("entitlements")
      .doc(userId)
      .set({
        individual: isIndividual,
        individualExpiresAt: personal.expiresAt ? personal.expiresAt.getTime() : null,
        askPerDay: isIndividual ? PERSONAL_LIMITS.individual.askPerDay : PERSONAL_LIMITS.free.askPerDay,
        // Legacy field for Ask ALRT builds that still read `plan`.
        plan: isIndividual ? "plus" : "free",
        source: "backend",
        version: Date.now(),
      });
  } catch (error) {
    console.warn(`[entitlements] Firestore mirror not updated for ${userId}: ${(error as Error).message}`);
  }
};

/** Whether a circle's sponsored grants are paused (sponsored + not live). */
export const isCirclePaused = async (circleId: string): Promise<boolean> => {
  if (!billingEnabled()) return false;
  return (await getGroupCoverage(circleId)).sponsorshipPaused;
};

/** Circles now always start individually funded; `plan` is legacy only. */
export const defaultCirclePlan = (): FamilyPlan =>
  billingEnabled() ? FamilyPlan.free : FamilyPlan.plus;
