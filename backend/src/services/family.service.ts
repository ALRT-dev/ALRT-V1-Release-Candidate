import crypto from "crypto";
import type {
  FamilyCheckInStatus,
  FamilyMember,
  FamilyPlaceIcon,
  FamilyRole,
  FamilyScheduledCheckInMode,
  FamilySharingLevel,
  FamilySosResponseType,
} from "@prisma/client";
import prisma from "../utils/prisma_client.util.js";
import { convertLatLngToAddress } from "./google_map.service.js";
import { HttpError } from "../models/http_error.js";
import { SocketEvent } from "../models/socket_event_types.js";
import { PushNotificationType } from "../models/push_notification_types.js";
import { sendSocketEventToUsers } from "./socket.service.js";
import {
  claimHazardPushRecipients,
  sendPushNotificationToUser,
} from "./notification.service.js";
import {
  awardFamilyJoined,
  awardSavedPlace,
  touchActivityStreak,
} from "./xp_ledger.service.js";
import {
  assertConnectionAccess,
  assertSponsoredCapacity,
  defaultCirclePlan,
  getConnectionAccess,
  getGroupCoverage,
  type ConnectionAccess,
  type GroupCoverage,
} from "./entitlement.service.js";

const INVITE_CODE_ALPHABET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789"; // no 0/O/1/I/L
const DEFAULT_MAX_MEMBERS = 10;

// ---------------------------------------------------------------------------
// Geo helpers
// ---------------------------------------------------------------------------

/** Great-circle distance between two points in kilometres. */
export const haversineKm = (
  lat1: number,
  lng1: number,
  lat2: number,
  lng2: number,
): number => {
  const toRad = (deg: number) => (deg * Math.PI) / 180;
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(a));
};

/**
 * Reduces a full reverse-geocoded address to a short suburb-level label,
 * e.g. "123 Macquarie Dr, Eleebana NSW 2282, Australia" -> "Eleebana".
 */
export const toSuburbLabel = (formattedAddress: string): string => {
  const parts = formattedAddress.split(",").map((p) => p.trim());
  const locality = parts.length >= 2 ? parts[1]! : parts[0]!;
  // Strip trailing state + postcode ("Eleebana NSW 2282" -> "Eleebana")
  return locality.replace(/\s+[A-Z]{2,3}\s+\d{4}$/, "").trim() || locality;
};

// ---------------------------------------------------------------------------
// Membership lookups & serialization
// ---------------------------------------------------------------------------

/**
 * Returns the user's family membership (with circle), or null.
 *
 * With [circleId] the membership in that specific circle is returned;
 * without it the user's first (oldest) membership is the default, which
 * keeps every single-circle client working unchanged.
 */
export const getMembershipForUser = async (
  userId: string,
  circleId?: string,
) => {
  return prisma.familyMember.findFirst({
    where: { userId, ...(circleId && { circleId }) },
    orderBy: { createdAt: "asc" },
    include: { circle: true },
  });
};

/** Returns the user's membership or throws 404 if they have no circle. */
export const requireMembership = async (userId: string, circleId?: string) => {
  const membership = await getMembershipForUser(userId, circleId);
  if (!membership) {
    throw new HttpError(
      404,
      circleId
        ? "You are not a member of this circle"
        : "You are not part of a family circle yet",
    );
  }
  return membership;
};

type MemberWithUser = FamilyMember & {
  user: { id: string; name: string | null; profilePictureUrl: string | null };
};

/**
 * Identity-only projection of a member for payloads where a member "rides
 * along" (check-ins, scheduled check-ins, SOS events and responses). It
 * deliberately carries no location, battery, movement or place fields, so a
 * nested member row can never bypass serializeMember's sharing-level and
 * expiry filtering. Everything the app's FamilyMemberSnippet parser reads
 * (id, nickname, user.id/name/profilePictureUrl) is here.
 */
const memberIdentitySelect = {
  id: true,
  userId: true,
  circleId: true,
  nickname: true,
  photoUrl: true,
  colorHex: true,
  role: true,
  sharingLevel: true,
  user: { select: { id: true, name: true, profilePictureUrl: true } },
} as const;

/** How long a check-in's own coordinates stay readable (matches SNAPSHOT_TTL). */
const CHECK_IN_LOCATION_TTL_MS = 60 * 60 * 1000;

/**
 * Serializes a member for other circle members, honouring the member's own
 * sharing level. `forSelf` bypasses filtering so users always see their own
 * full state.
 */
export const serializeMember = (
  member: MemberWithUser,
  { forSelf = false }: { forSelf?: boolean } = {},
) => {
  const base = {
    id: member.id,
    userId: member.userId,
    name: member.nickname || member.user.name || "Family member",
    profilePictureUrl: member.photoUrl || member.user.profilePictureUrl,
    colorHex: member.colorHex,
    role: member.role,
    sharingLevel: member.sharingLevel,
    lastCheckInAt: member.lastCheckInAt,
    createdAt: member.createdAt,
  };

  // Snapshots expire: past their TTL they are hidden from everyone,
  // including the member themself (the app re-shares on demand).
  const snapshotIsLive =
    member.locationExpiresAt != null && member.locationExpiresAt > new Date();

  const shareLocation =
    snapshotIsLive &&
    (forSelf ||
      member.sharingLevel === "precise" ||
      member.sharingLevel === "approximate");
  const sharePreciseCoords =
    snapshotIsLive && (forSelf || member.sharingLevel === "precise");

  return {
    ...base,
    latitude: sharePreciseCoords ? member.latitude : null,
    longitude: sharePreciseCoords ? member.longitude : null,
    locationLabel: shareLocation ? member.locationLabel : null,
    locationUpdatedAt: shareLocation ? member.locationUpdatedAt : null,
    locationExpiresAt: shareLocation ? member.locationExpiresAt : null,
    locationSharedVia: shareLocation ? member.locationSharedVia : null,
    batteryLevel: shareLocation ? member.batteryLevel : null,
    isMoving: shareLocation ? member.isMoving : false,
    currentPlaceId: shareLocation ? member.currentPlaceId : null,
  };
};

// ---------------------------------------------------------------------------
// Circle notifications (push + socket to every member except excluded)
// ---------------------------------------------------------------------------

export const getCircleUserIds = async (
  circleId: string,
  excludeMemberIds: string[] = [],
  onlyMemberIds?: string[],
): Promise<string[]> => {
  const members = await prisma.familyMember.findMany({
    where: {
      circleId,
      id: {
        notIn: excludeMemberIds,
        ...(onlyMemberIds ? { in: onlyMemberIds } : {}),
      },
    },
    select: { userId: true },
  });
  return members.map((m) => m.userId);
};

/** Socket + push to an explicit set of users (e.g. one SOS's audience). */
const notifyUsers = async ({
  userIds,
  title,
  body,
  data,
  type,
  socketEvent,
  socketData,
}: {
  userIds: string[];
  title: string;
  body: string;
  data: object;
  type: PushNotificationType;
  socketEvent: SocketEvent;
  socketData: any;
}) => {
  const unique = [...new Set(userIds)];
  if (unique.length === 0) return;
  sendSocketEventToUsers({ userIds: unique, event: socketEvent, data: socketData });
  await Promise.allSettled(
    unique.map((userId) =>
      sendPushNotificationToUser({ userId, title, body, data, type }),
    ),
  );
};

export const notifyCircle = async ({
  circleId,
  excludeMemberIds = [],
  onlyMemberIds,
  title,
  body,
  data,
  type,
  urgent,
  collapseKey,
  hazardEvent,
  socketEvent,
  socketData,
}: {
  circleId: string;
  excludeMemberIds?: string[];
  /** When set, only these members (still minus excludeMemberIds) hear it. */
  onlyMemberIds?: string[];
  title?: string;
  body?: string;
  data?: object;
  type?: PushNotificationType;
  /** Urgent channel on Android, time-sensitive on iOS (SOS, needs help). */
  urgent?: boolean;
  /** Tray key so a repeated copy of one event replaces, never stacks. */
  collapseKey?: string;
  /**
   * For pushes about a public hazard: one push per person per hazard
   * event across this and the saved-area path (see
   * claimHazardPushRecipients). The socket event still reaches everyone.
   */
  hazardEvent?: { hazardId: string; eventKey: string };
  socketEvent?: SocketEvent;
  socketData?: any;
}) => {
  const userIds = await getCircleUserIds(
    circleId,
    excludeMemberIds,
    onlyMemberIds,
  );
  if (userIds.length === 0) return;

  if (socketEvent) {
    sendSocketEventToUsers({
      userIds,
      event: socketEvent,
      data: socketData ?? data ?? {},
    });
  }

  if (title && body && type) {
    const pushUserIds = hazardEvent
      ? await claimHazardPushRecipients(
          hazardEvent.hazardId,
          hazardEvent.eventKey,
          userIds,
        )
      : userIds;
    await Promise.allSettled(
      pushUserIds.map((userId) =>
        sendPushNotificationToUser({
          userId,
          title,
          body,
          data: data ?? {},
          type,
          ...(urgent !== undefined && { urgent }),
          ...(collapseKey && { collapseKey }),
        }),
      ),
    );
  }
};

// ---------------------------------------------------------------------------
// Circle CRUD
// ---------------------------------------------------------------------------

// V1 access model (master spec 28 Sep 2026) replaces the old seat model
// (8 seats across 4 owned circles, guests free). There is no commercial
// limit on how many groups anyone joins or hosts, and no seats: a
// sponsored group counts every person in it against its own 6/20/50
// capacity (entitlement.service), and an individually funded group needs
// each active participant to hold Individual. What remains here is a
// purely technical anti-abuse ceiling on groups one account can create,
// set far above any real use so it never acts as a plan limit.
const MAX_CREATED_CIRCLES_ABUSE_CEILING = 100;

/** An ask to check in is "open" for this long; after that it is history. */
const CHECK_IN_ASK_FRESH_MS = 24 * 60 * 60 * 1000;

/**
 * Days a circle without a host keeps everything working before host-only
 * administration (invites, circle settings) locks. Core safety — SOS,
 * check-ins, journeys, the member list — is never gated on this, at any
 * point: only who can invite people or change circle rules is affected,
 * and only once this window has passed.
 */
const HOST_TRANSITION_GRACE_DAYS = 7;

export interface HostTransitionState {
  /** True once the circle has no current host. */
  active: boolean;
  /**
   * Only `owner_left` is produced now. `entitlement_lapsed` stays in the
   * type for old app builds: under the V1 model a host's personal plan
   * lapsing pauses only that person's own paid participation, never the
   * group or its hosting.
   */
  reason: "owner_left" | "entitlement_lapsed" | null;
  /** When the transition began, for display — null when not active. */
  startedAt: Date | null;
  /** Display name of the departed/lapsed host, when known. */
  hostName: string | null;
  /** Days left before host-admin actions lock — 0 once locked. */
  daysLeft: number;
  /** True once HOST_TRANSITION_GRACE_DAYS has passed unresolved. */
  locked: boolean;
}

const NOT_IN_TRANSITION: HostTransitionState = {
  active: false,
  reason: null,
  startedAt: null,
  hostName: null,
  daysLeft: HOST_TRANSITION_GRACE_DAYS,
  locked: false,
};

/**
 * The circle's host-transition state, computed fresh every time rather than
 * trusted from a stale flag — this is the single source of truth used by
 * the hub banner, take-over eligibility, and the host-admin lock.
 *
 * A circle ends up here when the owner left the circle or their account
 * was deleted. `hostTransitionStartedAt`/`hostTransitionHostName` on the
 * circle record are the only trace of this, since the owner's FamilyMember
 * row is gone. Billing never starts a host transition (V1 access model).
 */
export const getHostTransitionState = async (
  circleId: string,
): Promise<HostTransitionState> => {
  const circle = await prisma.familyCircle.findUnique({
    where: { id: circleId },
    select: {
      hostTransitionStartedAt: true,
      hostTransitionHostName: true,
    },
  });
  if (!circle) return NOT_IN_TRANSITION;

  const host = await prisma.familyMember.findFirst({
    where: { circleId, role: "owner" },
    select: { id: true },
  });

  let startedAt: Date | null = null;
  let reason: HostTransitionState["reason"] = null;
  let hostName: string | null = null;

  if (circle.hostTransitionStartedAt) {
    startedAt = circle.hostTransitionStartedAt;
    reason = "owner_left";
    hostName = circle.hostTransitionHostName;
  } else if (!host) {
    // No owner row and no recorded start time — data predating this
    // feature, or a direct DB edit. Anchor to now rather than leaving the
    // transition permanently undated.
    startedAt = new Date();
    reason = "owner_left";
  }

  if (!startedAt) return NOT_IN_TRANSITION;

  const elapsedDays =
    (Date.now() - startedAt.getTime()) / (24 * 60 * 60 * 1000);
  return {
    active: true,
    reason,
    startedAt,
    hostName,
    daysLeft: Math.max(0, Math.ceil(HOST_TRANSITION_GRACE_DAYS - elapsedDays)),
    locked: elapsedDays > HOST_TRANSITION_GRACE_DAYS,
  };
};

/** Starts the host-transition window if it isn't already running. */
const ensureHostTransitionStarted = async (
  circleId: string,
  hostName: string | null,
) => {
  await prisma.familyCircle.updateMany({
    where: { id: circleId, hostTransitionStartedAt: null },
    data: { hostTransitionStartedAt: new Date(), hostTransitionHostName: hostName },
  });
};

/** Throws when the circle's host-transition window has run out unresolved. */
export const assertHostAdminNotLocked = async (circleId: string) => {
  const state = await getHostTransitionState(circleId);
  if (state.locked) {
    throw new HttpError(
      403,
      "This circle needs a new host before invites or circle settings can " +
        "change. SOS, check-ins and journeys still work for everyone.",
    );
  }
};

export const createCircle = async (userId: string, name: string) => {
  // V1: creating a group is free. A group starts individually funded (each
  // participant needs Individual for the connection features) and its host
  // can later cover it with a Family/Group plan, which needs the group to
  // exist first so it can be chosen before checkout. The paid gates are on
  // the features themselves (assertConnectionAccess), per person.
  const createdCircles = await prisma.familyCircle.count({
    where: { createdById: userId },
  });
  if (createdCircles >= MAX_CREATED_CIRCLES_ABUSE_CEILING) {
    throw new HttpError(
      429,
      "You've created a lot of groups. Remove one you no longer use, or contact support.",
    );
  }

  return prisma.familyCircle.create({
    data: {
      name,
      createdById: userId,
      fundingMode: "individual",
      // Legacy field kept for old app builds; access is computed by
      // entitlement.service, never read from here.
      plan: defaultCirclePlan(),
      maxMembers: DEFAULT_MAX_MEMBERS,
      members: {
        create: { userId, role: "owner" },
      },
    },
    include: { members: true },
  });
};

/** The user's circles with their role and member counts, oldest first. */
export const listCirclesForUser = async (userId: string) => {
  const memberships = await prisma.familyMember.findMany({
    where: { userId },
    orderBy: { createdAt: "asc" },
    include: {
      circle: { include: { _count: { select: { members: true } } } },
    },
  });

  // V1 access model: per-group funding, capacity and this person's own
  // connection access, so the hub can say who covers which group.
  const coverageByCircle = new Map<string, GroupCoverage>();
  const accessByCircle = new Map<string, ConnectionAccess>();
  for (const m of memberships) {
    coverageByCircle.set(m.circleId, await getGroupCoverage(m.circleId));
    accessByCircle.set(m.circleId, await getConnectionAccess(userId, m.circleId));
  }

  // One-glance state per group, so the hub can say "2 of 3 · waiting on
  // Amy" or "SOS live · Tom" for groups that are NOT open, not just the
  // one whose members are loaded. Names and times only - never a location
  // (backend/CLAUDE.md: location leaves a phone only by the owner's
  // action, and this list is read constantly).
  const circleIds = memberships.map((m) => m.circleId);
  const dayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
  const myMemberIds = memberships.map((m) => m.id);
  const [allMembers, openAsks, activeSos] = await Promise.all([
    prisma.familyMember.findMany({
      where: { circleId: { in: circleIds } },
      select: {
        circleId: true,
        nickname: true,
        lastCheckInAt: true,
        user: { select: { name: true } },
      },
      orderBy: { createdAt: "asc" },
    }),
    // Asks from the last day that could be waiting on me, so the hub can
    // say "Weekend Crew · 1 request" for a circle that is not open.
    // Who asked and when only.
    prisma.familyCheckInRequest.findMany({
      where: {
        circleId: { in: circleIds },
        createdAt: { gt: dayAgo },
        requestedById: { notIn: myMemberIds },
        OR: [
          { targetMemberIds: { isEmpty: true } },
          { targetMemberIds: { hasSome: myMemberIds } },
        ],
      },
      select: { circleId: true, createdAt: true, targetMemberIds: true },
    }),
    prisma.familySosEvent.findMany({
      where: { circleId: { in: circleIds }, status: "active", ...sosVisibleTo(userId) },
      select: {
        id: true,
        circleId: true,
        memberId: true,
        createdAt: true,
        member: {
          select: { nickname: true, user: { select: { name: true } } },
        },
      },
      orderBy: { createdAt: "desc" },
    }),
  ]);
  const checkedInByCircle = new Map<string, number>();
  const waitingOnByCircle = new Map<string, string[]>();
  for (const m of allMembers) {
    const name = m.nickname || m.user.name || "Family member";
    const checkedIn = !!m.lastCheckInAt && m.lastCheckInAt > dayAgo;
    if (checkedIn) {
      checkedInByCircle.set(
        m.circleId,
        (checkedInByCircle.get(m.circleId) ?? 0) + 1,
      );
    } else {
      waitingOnByCircle.set(m.circleId, [
        ...(waitingOnByCircle.get(m.circleId) ?? []),
        name,
      ]);
    }
  }
  // An ask is still owed when I have not checked in since it was made.
  const pendingAsksByCircle = new Map<string, number>();
  for (const membership of memberships) {
    const mine = openAsks.filter(
      (ask) =>
        ask.circleId === membership.circleId &&
        (ask.targetMemberIds.length === 0 ||
          ask.targetMemberIds.includes(membership.id)) &&
        (!membership.lastCheckInAt || membership.lastCheckInAt < ask.createdAt),
    );
    pendingAsksByCircle.set(membership.circleId, mine.length);
  }
  const sosByCircle = new Map<
    string,
    { id: string; memberId: string; memberName: string; createdAt: Date }
  >();
  for (const sos of activeSos) {
    // Newest first, so the first one seen per circle is the latest.
    if (sosByCircle.has(sos.circleId)) continue;
    sosByCircle.set(sos.circleId, {
      id: sos.id,
      memberId: sos.memberId,
      memberName: sos.member.nickname || sos.member.user.name || "Family member",
      createdAt: sos.createdAt,
    });
  }

  return memberships.map((membership) => ({
    circleId: membership.circleId,
    name: membership.circle.name,
    plan: membership.circle.plan,
    themeColor: membership.circle.themeColor,
    photoUrl: membership.circle.photoUrl,
    role: membership.role,
    myMemberId: membership.id,
    memberCount: membership.circle._count.members,
    // Deprecated (old seat model): now simply the number of people.
    seatCount: membership.circle._count.members,
    fundingMode: coverageByCircle.get(membership.circleId)?.fundingMode ?? "individual",
    capacity: coverageByCircle.get(membership.circleId)?.capacity ?? null,
    sponsorshipLive: coverageByCircle.get(membership.circleId)?.sponsorship?.live ?? false,
    connectionAccess: accessByCircle.get(membership.circleId) ?? null,
    isOwned: membership.circle.createdById === userId,
    joinedAt: membership.createdAt,
    checkedInCount: checkedInByCircle.get(membership.circleId) ?? 0,
    waitingOn: waitingOnByCircle.get(membership.circleId) ?? [],
    pendingCheckInRequests: pendingAsksByCircle.get(membership.circleId) ?? 0,
    activeSos: sosByCircle.get(membership.circleId) ?? null,
  }));
};

/** Full circle payload for the family hub screen. */
export const getCircleForUser = async (userId: string, circleId?: string) => {
  const membership = await getMembershipForUser(userId, circleId);
  if (!membership) return null;

  const circle = await prisma.familyCircle.findUnique({
    where: { id: membership.circleId },
    include: {
      members: {
        include: {
          user: {
            select: { id: true, name: true, profilePictureUrl: true },
          },
        },
        orderBy: { createdAt: "asc" },
      },
      places: {
        include: { notificationPrefs: true },
        orderBy: { createdAt: "asc" },
      },
      sosEvents: {
        where: { status: "active", ...sosVisibleTo(userId) },
        include: {
          member: { select: memberIdentitySelect },
          responses: { include: { member: { select: memberIdentitySelect } } },
        },
        orderBy: { createdAt: "desc" },
      },
    },
  });
  if (!circle) return null;

  // The asks that concern THIS member: aimed at everyone, aimed at them,
  // or sent by them (their own tracker). An ask aimed only at someone
  // else is not theirs to see or answer. Every ask from the last day is
  // returned, newest first, so that when Amy and Tom both ask, the hub
  // can name both and one check-in can be seen to answer both; the
  // newest also travels as latestCheckInRequest for older app builds.
  const checkInRequests = await prisma.familyCheckInRequest.findMany({
    where: {
      circleId: circle.id,
      createdAt: { gt: new Date(Date.now() - CHECK_IN_ASK_FRESH_MS) },
      OR: [
        { targetMemberIds: { isEmpty: true } },
        { targetMemberIds: { has: membership.id } },
        { requestedById: membership.id },
      ],
    },
    orderBy: { createdAt: "desc" },
    take: 20,
    include: {
      checkIns: { select: { memberId: true } },
      // Who asked, by name only - never their location (see requestCheckIn).
      requestedBy: {
        select: {
          id: true,
          nickname: true,
          user: { select: { id: true, name: true, profilePictureUrl: true } },
        },
      },
    },
  });
  const latestRequest = checkInRequests[0] ?? null;

  const hostTransition = await getHostTransitionState(circle.id);

  return {
    id: circle.id,
    name: circle.name,
    plan: circle.plan,
    themeColor: circle.themeColor,
    photoUrl: circle.photoUrl,
    hostTransitionActive: hostTransition.active,
    hostTransitionReason: hostTransition.reason,
    hostTransitionHostName: hostTransition.hostName,
    hostTransitionDaysLeft: hostTransition.daysLeft,
    hostTransitionLocked: hostTransition.locked,
    maxMembers: circle.maxMembers,
    anyoneCanRequestSnapshot: circle.anyoneCanRequestSnapshot,
    sosToWholeGroup: circle.sosToWholeGroup,
    journeysSnapPointsOnly: circle.journeysSnapPointsOnly,
    myMemberId: membership.id,
    members: circle.members.map((m) =>
      serializeMember(m, { forSelf: m.userId === userId }),
    ),
    places: circle.places,
    activeSosEvents: circle.sosEvents,
    latestCheckInRequest: latestRequest,
    checkInRequests,
    createdAt: circle.createdAt,
  };
};

export const updateCircle = async (
  userId: string,
  input: {
    name?: string | undefined;
    themeColor?: string | null | undefined;
    anyoneCanRequestSnapshot?: boolean | undefined;
    sosToWholeGroup?: boolean | undefined;
    journeysSnapPointsOnly?: boolean | undefined;
  },
  circleId?: string,
) => {
  const membership = await requireMembership(userId, circleId);
  if (membership.role !== "owner") {
    throw new HttpError(403, "Only the circle owner can edit the circle");
  }
  await assertHostAdminNotLocked(membership.circleId);
  const circle = await prisma.familyCircle.update({
    where: { id: membership.circleId },
    data: {
      ...(input.name !== undefined && { name: input.name }),
      ...(input.themeColor !== undefined && { themeColor: input.themeColor }),
      ...(input.anyoneCanRequestSnapshot !== undefined && {
        anyoneCanRequestSnapshot: input.anyoneCanRequestSnapshot,
      }),
      ...(input.sosToWholeGroup !== undefined && {
        sosToWholeGroup: input.sosToWholeGroup,
      }),
      ...(input.journeysSnapPointsOnly !== undefined && {
        journeysSnapPointsOnly: input.journeysSnapPointsOnly,
      }),
    },
  });
  await notifyCircle({
    circleId: circle.id,
    socketEvent: SocketEvent.familyCircleUpdate,
    socketData: { circleId: circle.id },
  });
  return circle;
};

export const deleteCircle = async (userId: string, circleId?: string) => {
  const membership = await requireMembership(userId, circleId);
  if (membership.role !== "owner") {
    throw new HttpError(403, "Only the circle owner can delete the circle");
  }
  const userIds = await getCircleUserIds(membership.circleId);
  const memberRows = await prisma.familyMember.findMany({
    where: { circleId: membership.circleId },
    select: { id: true },
  });
  await prisma.familyCircle.delete({ where: { id: membership.circleId } });

  pruneMembersFromSosLists(memberRows.map((m) => m.id)).catch((error) =>
    console.error("SOS list prune failed on circle delete:", error),
  );

  sendSocketEventToUsers({
    userIds,
    event: SocketEvent.familyCircleUpdate,
    data: { circleId: membership.circleId, deleted: true },
  });
};

/**
 * What leaving did, so the app can say the right thing: "left" (others
 * remain), "deleted" (the leaver was the last member, so the circle is
 * gone), "hostTransition" (the host left; the 7-day window started).
 */
export type LeaveCircleOutcome = "left" | "deleted" | "hostTransition";

export const leaveCircle = async (
  userId: string,
  circleId?: string,
): Promise<{ outcome: LeaveCircleOutcome; circleId: string }> => {
  const membership = await requireMembership(userId, circleId);

  const otherMembers = await prisma.familyMember.count({
    where: { circleId: membership.circleId, id: { not: membership.id } },
  });
  if (otherMembers === 0) {
    // Last member out, host or not (a member can be the last one left after
    // the host walked out into a host transition): the circle goes with
    // them, so no memberless circle is left behind. The leaver's other
    // devices are told the same way deleteCircle tells everyone.
    await prisma.familyCircle.delete({ where: { id: membership.circleId } });
    pruneMembersFromSosLists([membership.id]).catch((error) =>
      console.error("SOS list prune failed on last-member leave:", error),
    );
    sendSocketEventToUsers({
      userIds: [userId],
      event: SocketEvent.familyCircleUpdate,
      data: { circleId: membership.circleId, deleted: true },
    });
    return { outcome: "deleted", circleId: membership.circleId };
  }

  if (membership.role === "owner") {

    // Leaving without naming a successor starts the 7-day host-transition
    // window instead of blocking: the circle and everyone already in it
    // keep SOS, check-ins and journeys, and an eligible member can take
    // over hosting at any point during (or after) that window.
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { name: true },
    });
    const hostName = membership.nickname || user?.name || null;
    await prisma.familyMember.delete({ where: { id: membership.id } });
    await ensureHostTransitionStarted(membership.circleId, hostName);

    pruneMembersFromSosLists(
      [membership.id],
      membership.nickname ?? undefined,
    ).catch((error) => console.error("SOS list prune failed on leave:", error));

    await notifyCircle({
      circleId: membership.circleId,
      title: "Family circle update",
      body: `${hostName || "Your host"} left as host. Choose a new host ` +
        `within ${HOST_TRANSITION_GRACE_DAYS} days.`,
      type: PushNotificationType.familyCircleUpdate,
      socketEvent: SocketEvent.familyCircleUpdate,
      socketData: { circleId: membership.circleId },
    });
    return { outcome: "hostTransition", circleId: membership.circleId };
  }

  await prisma.familyMember.delete({ where: { id: membership.id } });

  // §28: the leaver comes off every SOS list, owners get told.
  pruneMembersFromSosLists(
    [membership.id],
    membership.nickname ?? undefined,
  ).catch((error) => console.error("SOS list prune failed on leave:", error));

  const leaverName = membership.nickname || "A family member";
  await notifyCircle({
    circleId: membership.circleId,
    title: "Family circle update",
    body: `${leaverName} left your family circle`,
    type: PushNotificationType.familyCircleUpdate,
    socketEvent: SocketEvent.familyCircleUpdate,
    socketData: { circleId: membership.circleId },
  });
  return { outcome: "left", circleId: membership.circleId };
};

// ---------------------------------------------------------------------------
// Ownership transfer (locked spec §29 TRANSFER)
// ---------------------------------------------------------------------------

/**
 * Why a member cannot host the circle, or `null` when they can.
 *
 * V1: hosting is an administrative role, not a paid one. Paying for a
 * sponsored group stays with the purchase's payer whoever hosts (payer
 * departure and reassignment are open decision R02), and an individually
 * funded group needs no one to pay for the group as a whole. So the only
 * bar left is the role: children and legacy guests don't host.
 */
const transferIneligibilityReason = async (
  _candidateUserId: string,
  candidateRole?: FamilyRole,
): Promise<string | null> => {
  if (candidateRole === "guest") return "Guests can't host";
  if (candidateRole === "child") return "Children can't host";
  return null;
};

/**
 * Members the owner could hand the circle to, each with eligibility.
 * Ineligible members are returned greyed with a reason, never hidden (§29).
 */
export const listTransferCandidates = async (
  userId: string,
  circleId?: string,
) => {
  const membership = await requireMembership(userId, circleId);
  if (membership.role !== "owner") {
    throw new HttpError(403, "Only the circle owner can transfer ownership");
  }

  const members = await prisma.familyMember.findMany({
    where: { circleId: membership.circleId },
    include: {
      user: { select: { id: true, name: true, profilePictureUrl: true } },
    },
    orderBy: { createdAt: "asc" },
  });
  const memberCount = members.length;

  const candidates = [];
  for (const member of members) {
    if (member.id === membership.id) continue;
    const reason = await transferIneligibilityReason(member.userId, member.role);
    candidates.push({
      memberId: member.id,
      name: member.nickname || member.user.name || "Family member",
      profilePictureUrl: member.photoUrl || member.user.profilePictureUrl,
      role: member.role,
      eligible: reason === null,
      reason,
    });
  }
  return { circleId: membership.circleId, memberCount, candidates };
};

/**
 * §29 TRANSFER: seats move to the new host, features continue
 * uninterrupted, and the prior host stays on as an adult member (they may
 * leave immediately after if they wish).
 */
export const transferOwnership = async (
  userId: string,
  newOwnerMemberId: string,
  circleId?: string,
) => {
  const membership = await requireMembership(userId, circleId);
  if (membership.role !== "owner") {
    throw new HttpError(403, "Only the circle owner can transfer ownership");
  }
  if (newOwnerMemberId === membership.id) {
    throw new HttpError(400, "You already own this circle");
  }

  const newOwnerMember = await prisma.familyMember.findFirst({
    where: { id: newOwnerMemberId, circleId: membership.circleId },
    include: { user: { select: { id: true, name: true } } },
  });
  if (!newOwnerMember) {
    throw new HttpError(404, "Member not found in this circle");
  }

  const reason = await transferIneligibilityReason(
    newOwnerMember.userId,
    newOwnerMember.role,
  );
  if (reason) {
    throw new HttpError(
      400,
      `This member can't take over the circle: ${reason}`,
    );
  }

  const [circle] = await prisma.$transaction([
    prisma.familyCircle.update({
      where: { id: membership.circleId },
      data: {
        createdById: newOwnerMember.userId,
        hostTransitionStartedAt: null,
        hostTransitionHostName: null,
      },
    }),
    prisma.familyMember.update({
      where: { id: newOwnerMember.id },
      data: { role: "owner" },
    }),
    prisma.familyMember.update({
      where: { id: membership.id },
      data: { role: "adult" },
    }),
  ]);

  const newOwnerName =
    newOwnerMember.nickname || newOwnerMember.user.name || "a member";
  await notifyCircle({
    circleId: circle.id,
    title: circle.name,
    body: `${newOwnerName} is now hosting this circle`,
    type: PushNotificationType.familyCircleUpdate,
    socketEvent: SocketEvent.familyCircleUpdate,
    socketData: { circleId: circle.id },
  });
  return circle;
};

/**
 * Takeover: when a circle is in a host transition — its host's ALRT+
 * lapsed, or the host left/deleted their account — an eligible member can
 * take over hosting without the previous host acting. The bar is the same
 * as a §29 transfer — active subscription, a free circle slot, and enough
 * free seats to absorb every membership. If the previous host is still a
 * member (the entitlement-lapsed case), they stay on as an ordinary
 * member; if they already left or were deleted, there is nobody to demote.
 *
 * Only a circle in transition can be taken over; a live circle changes
 * hands through the host-initiated transfer, never out from under an
 * active host.
 */
export const takeOverCircle = async (userId: string, circleId?: string) => {
  const membership = await requireMembership(userId, circleId);
  if (membership.role === "owner") {
    throw new HttpError(400, "You already host this circle");
  }
  if (membership.role === "guest") {
    throw new HttpError(403, "Guests can't host");
  }

  const transition = await getHostTransitionState(membership.circleId);
  if (!transition.active) {
    throw new HttpError(
      400,
      "This circle isn't in a host transition. Ask the host to hand it over instead",
    );
  }

  const host = await prisma.familyMember.findFirst({
    where: { circleId: membership.circleId, role: "owner" },
  });

  const reason = await transferIneligibilityReason(userId, membership.role);
  if (reason) {
    throw new HttpError(400, `You can't take over this circle: ${reason}`);
  }

  const circleUpdate = prisma.familyCircle.update({
    where: { id: membership.circleId },
    data: {
      createdById: userId,
      hostTransitionStartedAt: null,
      hostTransitionHostName: null,
    },
  });
  const newOwnerUpdate = prisma.familyMember.update({
    where: { id: membership.id },
    data: { role: "owner" },
  });

  const [circle] = host
    ? await prisma.$transaction([
        circleUpdate,
        newOwnerUpdate,
        prisma.familyMember.update({
          where: { id: host.id },
          data: { role: "adult" },
        }),
      ])
    : await prisma.$transaction([circleUpdate, newOwnerUpdate]);

  const newHostName =
    membership.nickname ||
    (await prisma.user.findUnique({
      where: { id: userId },
      select: { name: true },
    }))?.name ||
    "a member";
  await notifyCircle({
    circleId: circle.id,
    title: circle.name,
    body: `${newHostName} is now hosting this circle`,
    type: PushNotificationType.familyCircleUpdate,
    socketEvent: SocketEvent.familyCircleUpdate,
    socketData: { circleId: circle.id },
  });
  return circle;
};

/**
 * Everyone the caller could put on an SOS list: each circle they belong to,
 * with its members. Names are the ones those circles already show their
 * members — nothing crosses a circle boundary that wasn't visible inside it.
 */
export const listSosRecipients = async (userId: string) => {
  const memberships = await prisma.familyMember.findMany({
    where: { userId },
    orderBy: { createdAt: "asc" },
    include: {
      circle: {
        include: {
          members: {
            include: {
              user: {
                select: { id: true, name: true, profilePictureUrl: true },
              },
            },
            orderBy: { createdAt: "asc" },
          },
        },
      },
    },
  });

  return memberships.map((membership) => ({
    circleId: membership.circleId,
    name: membership.circle.name,
    themeColor: membership.circle.themeColor,
    photoUrl: membership.circle.photoUrl,
    members: membership.circle.members
      .filter((member) => member.userId !== userId)
      .map((member) => ({
        memberId: member.id,
        name: member.nickname || member.user.name || "Family member",
        profilePictureUrl: member.photoUrl || member.user.profilePictureUrl,
        role: member.role,
      })),
  }));
};

export const removeMember = async (userId: string, memberId: string) => {
  // Anchor on the target so the right circle's ownership is checked even
  // when the caller belongs to several circles.
  const target = await prisma.familyMember.findUnique({
    where: { id: memberId },
  });
  if (!target) {
    throw new HttpError(404, "Member not found in your circle");
  }

  const membership = await requireMembership(userId, target.circleId);
  if (membership.role !== "owner") {
    throw new HttpError(403, "Only the circle owner can remove members");
  }
  if (membership.id === memberId) {
    throw new HttpError(400, "Use leave/delete instead of removing yourself");
  }

  await prisma.familyMember.delete({ where: { id: target.id } });

  // §28: departed members leave every SOS list, owners get told.
  pruneMembersFromSosLists([target.id], target.nickname ?? undefined).catch(
    (error) => console.error("SOS list prune failed on remove:", error),
  );

  sendSocketEventToUsers({
    userIds: [target.userId],
    event: SocketEvent.familyCircleUpdate,
    data: { circleId: membership.circleId, removed: true },
  });
  const removedName = target.nickname || "A family member";
  await notifyCircle({
    circleId: membership.circleId,
    title: "Family circle update",
    body: `${removedName} was removed from your family circle`,
    type: PushNotificationType.familyCircleUpdate,
    socketEvent: SocketEvent.familyCircleUpdate,
    socketData: { circleId: membership.circleId },
  });
};

export const updateOwnMember = async (
  userId: string,
  input: {
    nickname?: string | undefined;
    sharingLevel?: FamilySharingLevel | undefined;
    colorHex?: string | null | undefined;
  },
  circleId?: string,
) => {
  const membership = await requireMembership(userId, circleId);

  const data: Record<string, unknown> = {};
  if (input.nickname !== undefined) data.nickname = input.nickname;
  if (input.colorHex !== undefined) data.colorHex = input.colorHex;
  if (input.sharingLevel !== undefined) {
    data.sharingLevel = input.sharingLevel;
    // Turning sharing off clears the stored live location immediately.
    if (input.sharingLevel === "off") {
      data.latitude = null;
      data.longitude = null;
      data.locationLabel = null;
      data.locationUpdatedAt = null;
      data.batteryLevel = null;
      data.isMoving = false;
      data.currentPlaceId = null;
    }
  }

  const updated = await prisma.familyMember.update({
    where: { id: membership.id },
    data,
  });

  await notifyCircle({
    circleId: membership.circleId,
    socketEvent: SocketEvent.familyCircleUpdate,
    socketData: { circleId: membership.circleId },
  });

  return updated;
};

/**
 * Stores an uploaded group picture for the circle itself.
 *
 * Owner-only, like every other circle setting: the picture is how the whole
 * group is recognised on the hub, the switcher and the home-screen widget,
 * so one person sets it rather than the last member to upload winning.
 */
export const updateCirclePhoto = async (
  userId: string,
  photoUrl: string,
  circleId?: string,
) => {
  const membership = await requireMembership(userId, circleId);
  if (membership.role !== "owner") {
    throw new HttpError(403, "Only the circle owner can change the group picture");
  }

  const previous = membership.circle.photoUrl;
  const circle = await prisma.familyCircle.update({
    where: { id: membership.circleId },
    data: { photoUrl },
  });

  await notifyCircle({
    circleId: circle.id,
    socketEvent: SocketEvent.familyCircleUpdate,
    socketData: { circleId: circle.id },
  });

  return { circle, previousPhotoUrl: previous };
};

/**
 * Clears the group picture, dropping the circle back to its initial and
 * theme colour. Returns the old URL so the caller can delete the object.
 */
export const removeCirclePhoto = async (userId: string, circleId?: string) => {
  const membership = await requireMembership(userId, circleId);
  if (membership.role !== "owner") {
    throw new HttpError(403, "Only the circle owner can change the group picture");
  }

  const previous = membership.circle.photoUrl;
  const circle = await prisma.familyCircle.update({
    where: { id: membership.circleId },
    data: { photoUrl: null },
  });

  await notifyCircle({
    circleId: circle.id,
    socketEvent: SocketEvent.familyCircleUpdate,
    socketData: { circleId: circle.id },
  });

  return { circle, previousPhotoUrl: previous };
};

/** Stores an uploaded circle photo for the calling member. */
export const updateOwnMemberPhoto = async (
  userId: string,
  photoUrl: string,
  circleId?: string,
) => {
  const membership = await requireMembership(userId, circleId);
  const previous = membership.photoUrl;

  const updated = await prisma.familyMember.update({
    where: { id: membership.id },
    data: { photoUrl },
  });

  await notifyCircle({
    circleId: membership.circleId,
    socketEvent: SocketEvent.familyCircleUpdate,
    socketData: { circleId: membership.circleId },
  });

  return { updated, previousPhotoUrl: previous };
};

// ---------------------------------------------------------------------------
// Invites
// ---------------------------------------------------------------------------

const generateInviteCode = (): string => {
  let code = "";
  const bytes = crypto.randomBytes(5);
  for (const b of bytes) {
    code += INVITE_CODE_ALPHABET[b % INVITE_CODE_ALPHABET.length];
  }
  return `ALRT-${code}`;
};

export const createInvite = async (
  userId: string,
  circleId?: string,
  isGuestInvite = false,
) => {
  const membership = await requireMembership(userId, circleId);
  if (membership.role === "child") {
    throw new HttpError(403, "Children cannot create invites");
  }
  if (membership.role === "guest") {
    throw new HttpError(403, "Guests cannot create invites");
  }
  // V1 retires consumer guests: no new guest invites.
  if (isGuestInvite) {
    throw new HttpError(
      400,
      "Guest invites are no longer available. Invite them as a member instead.",
    );
  }
  // Only the host invites. In a sponsored group each joiner uses part of
  // the plan's capacity, which is checked again when they join.
  if (membership.role !== "owner") {
    throw new HttpError(
      403,
      "Only the group owner can invite people to this group",
    );
  }
  await assertHostAdminNotLocked(membership.circleId);

  // Retry on the (unlikely) unique-code collision.
  for (let attempt = 0; attempt < 5; attempt++) {
    try {
      return await prisma.familyInvite.create({
        data: {
          circleId: membership.circleId,
          code: generateInviteCode(),
          createdById: membership.id,
          isGuestInvite,
          expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
        },
      });
    } catch (error: any) {
      if (error?.code !== "P2002") throw error;
    }
  }
  throw new HttpError(500, "Could not generate an invite code. Try again.");
};

export const listInvites = async (userId: string, circleId?: string) => {
  const membership = await requireMembership(userId, circleId);
  return prisma.familyInvite.findMany({
    where: {
      circleId: membership.circleId,
      isRevoked: false,
      OR: [{ expiresAt: null }, { expiresAt: { gt: new Date() } }],
    },
    orderBy: { createdAt: "desc" },
  });
};

export const revokeInvite = async (userId: string, inviteId: string) => {
  const invite = await prisma.familyInvite.findUnique({
    where: { id: inviteId },
  });
  if (!invite) throw new HttpError(404, "Invite not found");

  const membership = await requireMembership(userId, invite.circleId);
  if (membership.role === "child") {
    throw new HttpError(403, "Children cannot revoke invites");
  }
  return prisma.familyInvite.update({
    where: { id: invite.id },
    data: { isRevoked: true },
  });
};

export const joinCircleWithCode = async (userId: string, code: string) => {
  const invite = await prisma.familyInvite.findUnique({
    where: { code: code.trim().toUpperCase() },
    include: { circle: { include: { members: true } } },
  });

  // One reason per failure, so the joiner (and the scanner UI) can say
  // exactly what went wrong instead of one blanket "invalid or expired".
  // All 404: none of these codes can be joined, and the distinction is
  // useful to the person holding the code, not to an attacker guessing
  // codes (the alphabet gives ~10^9 codes and joins are rate-limited).
  if (!invite) {
    throw new HttpError(
      404,
      "That code doesn't match any family circle. Check it and try again.",
    );
  }
  if (invite.isRevoked) {
    throw new HttpError(
      404,
      "This invite code was revoked by the host. Ask them for a new one.",
    );
  }
  if (invite.expiresAt && invite.expiresAt < new Date()) {
    throw new HttpError(
      404,
      "This invite code has expired. Ask the host for a new one.",
    );
  }
  if (invite.useCount >= invite.maxUses) {
    throw new HttpError(
      404,
      "This invite code has already been used the maximum number of times. Ask the host for a new one.",
    );
  }

  // V1 retires consumer guests: an old guest code is not redeemed as a
  // full member (that would widen what it grants) nor as a guest.
  if (invite.isGuestInvite) {
    throw new HttpError(
      404,
      "This guest invite is no longer valid. Ask the host for a new invite.",
    );
  }

  if (invite.circle.members.some((m) => m.userId === userId)) {
    throw new HttpError(400, "You are already a member of this circle");
  }

  // Joining is free for the joiner. Everything that depends on the current
  // headcount runs inside one transaction holding the circle row lock, so
  // two simultaneous joins (or a replayed invite) can't both take the last
  // place. The (circleId, userId) unique index stops duplicate rows.
  const member = await prisma.$transaction(async (tx) => {
    await tx.$queryRaw`SELECT id FROM "FamilyCircle" WHERE id = ${invite.circleId} FOR UPDATE`;
    const fresh = await tx.familyInvite.findUnique({ where: { id: invite.id } });
    if (!fresh || fresh.isRevoked || fresh.useCount >= fresh.maxUses) {
      throw new HttpError(404, "This invite code can no longer be used. Ask the host for a new one.");
    }
    // Sponsored groups: every person counts against the plan's 6/20/50,
    // which replaces the record's own size limit (a Group 50 must reach
    // 50). Other groups keep the technical maxMembers limit; their real
    // capacity is open decision R01.
    const coverage = await assertSponsoredCapacity(invite.circleId, 1, tx);
    const sponsoredCapacity =
      coverage.fundingMode === "sponsored" ? coverage.capacity : null;
    if (sponsoredCapacity === null) {
      const people = await tx.familyMember.count({ where: { circleId: invite.circleId } });
      if (people >= invite.circle.maxMembers) {
        throw new HttpError(400, "This group is full", "GROUP_FULL", {
          capacity: invite.circle.maxMembers,
          sponsored: false,
        });
      }
    }
    const already = await tx.familyMember.findFirst({
      where: { circleId: invite.circleId, userId },
      select: { id: true },
    });
    if (already) throw new HttpError(400, "You are already a member of this circle");
    const created = await tx.familyMember.create({
      data: { circleId: invite.circleId, userId, role: "adult" },
      include: {
        user: { select: { id: true, name: true, profilePictureUrl: true } },
      },
    });
    await tx.familyInvite.update({
      where: { id: invite.id },
      data: { useCount: { increment: 1 } },
    });
    return created;
  });

  await notifyCircle({
    circleId: invite.circleId,
    excludeMemberIds: [member!.id],
    title: invite.circle.name,
    body: `${member!.user.name || "A new member"} joined your family circle`,
    data: { circleId: invite.circleId },
    type: PushNotificationType.familyCircleUpdate,
    socketEvent: SocketEvent.familyCircleUpdate,
    socketData: { circleId: invite.circleId },
  });

  // Points & Badge Logic v1.1: joining a family group earns 10, once.
  await awardFamilyJoined(userId, invite.circleId);

  return member!;
};

// ---------------------------------------------------------------------------
// Check-ins
// ---------------------------------------------------------------------------

export const createCheckIn = async (
  userId: string,
  input: {
    status?: FamilyCheckInStatus | undefined;
    message?: string | undefined;
    latitude?: number | undefined;
    longitude?: number | undefined;
    requestId?: string | undefined;
    hazardId?: string | undefined;
  },
  circleId?: string,
) => {
  const membership = await requireMembership(userId, circleId);
  await assertConnectionAccess(userId, membership.circleId);
  // "safe" is the stored value of an ordinary check-in (enum kept for
  // existing rows); it is never shown or pushed as a claim of safety.
  const status: FamilyCheckInStatus = input.status ?? "safe";

  // An alert link is only stored when it names a real, published alert
  // (the id has no foreign key). Anything else is refused rather than
  // written verbatim, so what the circle later sees as "near <alert>" is
  // always an alert that exists.
  if (input.hazardId) {
    const hazard = await prisma.hazard.findFirst({
      where: { id: input.hazardId, reviewStatus: "accepted" },
      select: { id: true },
    });
    if (!hazard) throw new HttpError(400, "That alert does not exist");
  }

  // The member's saved sharing level is a ceiling (Option A, approved):
  // a check-in carries precise coordinates only for "precise" members.
  // "approximate" members surface a suburb label through the member
  // snapshot instead (see checkInController); "alertsOnly" and "off"
  // never put coordinates on a check-in, whatever the client sent.
  const coordinates =
    input.latitude !== undefined &&
    input.longitude !== undefined &&
    membership.sharingLevel === "precise"
      ? { latitude: input.latitude, longitude: input.longitude }
      : {};

  const checkIn = await prisma.$transaction(async (tx) => {
    const created = await tx.familyCheckIn.create({
      data: {
        circleId: membership.circleId,
        memberId: membership.id,
        status,
        ...(input.message && { message: input.message }),
        ...coordinates,
        ...(input.requestId && { requestId: input.requestId }),
        ...(input.hazardId && { hazardId: input.hazardId }),
      },
      include: { member: { select: memberIdentitySelect } },
    });
    await tx.familyMember.update({
      where: { id: membership.id },
      data: { lastCheckInAt: created.createdAt },
    });
    return created;
  });

  // Checking in counts as daily activity for the streak (no XP awarded —
  // safety actions never earn points, streaks only gate the report bonus).
  touchActivityStreak(userId).catch((error) =>
    console.error("Streak touch failed on check-in:", error),
  );

  const memberName =
    checkIn.member.nickname || checkIn.member.user.name || "A family member";
  const isHelp = status === "needsHelp";

  // A check-in is factual: it says the person checked in, never that they
  // are safe (master spec §11).
  await notifyCircle({
    circleId: membership.circleId,
    excludeMemberIds: [membership.id],
    title: isHelp ? `${memberName} needs help` : `${memberName} checked in`,
    // The member's own message stays inside the app: a lock-screen
    // preview is not the place for free text about someone's situation.
    body: isHelp ? "Reach out now. Open ALRT for details." : "Open ALRT to see their check-in.",
    data: { circleId: membership.circleId, checkInId: checkIn.id },
    type: PushNotificationType.familyCheckIn,
    urgent: isHelp,
    socketEvent: SocketEvent.familyCheckIn,
    socketData: checkIn,
  });

  return checkIn;
};

export const requestCheckIn = async (
  userId: string,
  input: {
    message?: string | undefined;
    hazardId?: string | undefined;
    memberIds?: string[] | undefined;
  },
  circleId?: string,
) => {
  const membership = await requireMembership(userId, circleId);
  // "Check on" is a covered connection feature (V1 access model).
  await assertConnectionAccess(userId, membership.circleId);

  // Targets: only real members of THIS circle, never the requester
  // (nobody is waiting on themself), de-duplicated. An ask that names
  // nobody valid is a mistake, not a broadcast - refuse it rather than
  // quietly asking everyone.
  const requestedIds = Array.from(new Set(input.memberIds ?? [])).filter(
    (id) => id !== membership.id,
  );
  let targetMemberIds: string[] = [];
  if (input.memberIds && input.memberIds.length > 0) {
    const targets = await prisma.familyMember.findMany({
      where: { circleId: membership.circleId, id: { in: requestedIds } },
      select: { id: true },
    });
    targetMemberIds = targets.map((t) => t.id);
    if (targetMemberIds.length === 0) {
      throw new HttpError(400, "None of those people are in this circle");
    }
    if (targetMemberIds.length !== requestedIds.length) {
      throw new HttpError(400, "Some of those people are not in this circle");
    }
  }

  const request = await prisma.familyCheckInRequest.create({
    data: {
      circleId: membership.circleId,
      requestedById: membership.id,
      targetMemberIds,
      ...(input.message && { message: input.message }),
      ...(input.hazardId && { hazardId: input.hazardId }),
    },
    include: {
      // Only who asked, never where they are: this broadcasts to every
      // other circle member, and a check-in request never carries the
      // requester's location (see backend/CLAUDE.md — location leaves a
      // phone only by the owner's action).
      requestedBy: {
        select: {
          id: true,
          nickname: true,
          user: { select: { id: true, name: true, profilePictureUrl: true } },
        },
      },
    },
  });

  const requesterName =
    request.requestedBy.nickname ||
    request.requestedBy.user.name ||
    "A family member";

  const isTargeted = targetMemberIds.length > 0;
  await notifyCircle({
    circleId: membership.circleId,
    excludeMemberIds: [membership.id],
    // A targeted ask reaches its targets only: nobody else is asked, so
    // nobody else is told.
    ...(isTargeted ? { onlyMemberIds: targetMemberIds } : {}),
    title: "Check-in requested",
    body:
      input.message ||
      (isTargeted
        ? `${requesterName} asked you to check in.`
        : `${requesterName} asked everyone to check in.`),
    data: { circleId: membership.circleId, requestId: request.id },
    type: PushNotificationType.familyCheckInRequest,
    socketEvent: SocketEvent.familyCheckInRequest,
    socketData: request,
  });

  return request;
};

/**
 * Cancels an outstanding "ask everyone to check in" request. Only the
 * member who asked, or the circle owner, may cancel it. Deleting the row
 * is enough on its own: FamilyCheckIn.requestId is onDelete: SetNull, so
 * any check-in that already answered this request keeps its own record,
 * it just stops being attributed to a now-cancelled ask.
 */
export const cancelCheckInRequest = async (
  userId: string,
  requestId: string,
) => {
  const request = await prisma.familyCheckInRequest.findUnique({
    where: { id: requestId },
  });
  if (!request) {
    throw new HttpError(404, "Check-in request not found");
  }
  const membership = await requireMembership(userId, request.circleId);
  if (request.requestedById !== membership.id && membership.role !== "owner") {
    throw new HttpError(
      403,
      "Only the person who asked, or the circle owner, can cancel this request",
    );
  }
  await prisma.familyCheckInRequest.delete({ where: { id: requestId } });

  await notifyCircle({
    circleId: request.circleId,
    socketEvent: SocketEvent.familyCircleUpdate,
    socketData: { circleId: request.circleId },
  });

  return { cancelled: true };
};

export const listRecentCheckIns = async (
  userId: string,
  limit = 30,
  circleId?: string,
) => {
  const membership = await requireMembership(userId, circleId);
  const rows = await prisma.familyCheckIn.findMany({
    where: { circleId: membership.circleId },
    orderBy: { createdAt: "desc" },
    take: Math.min(limit, 100),
    include: { member: { select: memberIdentitySelect } },
  });
  // Read-time TTL: a check-in's coordinates are a one-hour snapshot, the
  // same promise the member snapshot makes. Enforced here so it never
  // depends on the purge sweep (which only runs where scheduled jobs are on).
  const hourAgo = new Date(Date.now() - CHECK_IN_LOCATION_TTL_MS);
  const stripped = rows.map((row) =>
    row.createdAt < hourAgo && (row.latitude != null || row.longitude != null)
      ? { ...row, latitude: null, longitude: null }
      : row,
  );
  return withHazardTitles(stripped);
};

/**
 * The alert a check-in was made from, by title, so the circle can read
 * "near <alert>" and open it. Looked up here because the link is an id
 * without a foreign key; an alert since removed simply has no title.
 */
const withHazardTitles = async <T extends { hazardId: string | null }>(
  rows: T[],
): Promise<(T & { hazard: { id: string; title: string } | null })[]> => {
  const ids = [...new Set(rows.map((r) => r.hazardId).filter((id): id is string => !!id))];
  const hazards = ids.length
    ? await prisma.hazard.findMany({
        where: { id: { in: ids } },
        select: { id: true, title: true },
      })
    : [];
  const byId = new Map(hazards.map((h) => [h.id, h]));
  return rows.map((row) => ({
    ...row,
    hazard: row.hazardId ? (byId.get(row.hazardId) ?? null) : null,
  }));
};

// ---------------------------------------------------------------------------
// Scheduled check-ins: a member's Daily reminder to check in (never a check-in).
// timeOfDay is Australia/Brisbane local time (fixed UTC+10, no DST in QLD).
// ---------------------------------------------------------------------------

const BRISBANE_UTC_OFFSET_MS = 10 * 60 * 60 * 1000;
const MAX_SCHEDULED_CHECK_INS_PER_MEMBER = 3;

const scheduledCheckInInclude = {
  member: { select: memberIdentitySelect },
} as const;

export const createScheduledCheckIn = async (
  userId: string,
  input: { timeOfDay: string; mode?: FamilyScheduledCheckInMode | undefined },
  circleId?: string,
) => {
  const membership = await requireMembership(userId, circleId);

  const count = await prisma.familyScheduledCheckIn.count({
    where: { memberId: membership.id },
  });
  if (count >= MAX_SCHEDULED_CHECK_INS_PER_MEMBER) {
    throw new HttpError(
      400,
      `You can have at most ${MAX_SCHEDULED_CHECK_INS_PER_MEMBER} scheduled check-ins`,
    );
  }

  return prisma.familyScheduledCheckIn.upsert({
    where: {
      memberId_timeOfDay: {
        memberId: membership.id,
        timeOfDay: input.timeOfDay,
      },
    },
    create: {
      circleId: membership.circleId,
      memberId: membership.id,
      timeOfDay: input.timeOfDay,
      mode: input.mode ?? "prompted",
    },
    update: { mode: input.mode ?? "prompted" },
    include: scheduledCheckInInclude,
  });
};

export const listScheduledCheckIns = async (
  userId: string,
  circleId?: string,
) => {
  const membership = await requireMembership(userId, circleId);
  return prisma.familyScheduledCheckIn.findMany({
    where: { circleId: membership.circleId },
    orderBy: { timeOfDay: "asc" },
    include: scheduledCheckInInclude,
  });
};

export const deleteScheduledCheckIn = async (
  userId: string,
  scheduledCheckInId: string,
) => {
  const schedule = await prisma.familyScheduledCheckIn.findUnique({
    where: { id: scheduledCheckInId },
  });
  if (!schedule) {
    throw new HttpError(404, "Scheduled check-in not found");
  }
  const membership = await requireMembership(userId, schedule.circleId);
  if (schedule.memberId !== membership.id && membership.role !== "owner") {
    throw new HttpError(
      403,
      "Only the member or the circle owner can remove this schedule",
    );
  }
  await prisma.familyScheduledCheckIn.delete({
    where: { id: scheduledCheckInId },
  });
  return { deleted: true };
};

/**
 * Fires every schedule whose timeOfDay matches the current Brisbane minute
 * and hasn't fired yet today. Called by the scheduler once a minute.
 */
export const fireDueScheduledCheckIns = async () => {
  const now = new Date();
  const brisbaneNow = new Date(now.getTime() + BRISBANE_UTC_OFFSET_MS);
  const hhmm = `${String(brisbaneNow.getUTCHours()).padStart(2, "0")}:${String(
    brisbaneNow.getUTCMinutes(),
  ).padStart(2, "0")}`;

  const brisbaneDayStart = new Date(brisbaneNow);
  brisbaneDayStart.setUTCHours(0, 0, 0, 0);
  const dayStartUtc = new Date(
    brisbaneDayStart.getTime() - BRISBANE_UTC_OFFSET_MS,
  );

  const due = await prisma.familyScheduledCheckIn.findMany({
    where: {
      timeOfDay: hhmm,
      OR: [{ lastFiredAt: null }, { lastFiredAt: { lt: dayStartUtc } }],
    },
    include: scheduledCheckInInclude,
  });

  for (const schedule of due) {
    // Paused access skips the schedule without consuming it: lastFiredAt
    // stays untouched, so it resumes the day access does. Access is per
    // person per group (V1): a sponsored group whose plan lapsed, or an
    // individually funded group where this person has no Individual.
    const access = await getConnectionAccess(
      schedule.member.userId,
      schedule.circleId,
    );
    if (!access.allowed) continue;

    // Claim the schedule first so a crash mid-fire can't double-notify.
    await prisma.familyScheduledCheckIn.update({
      where: { id: schedule.id },
      data: { lastFiredAt: now },
    });

    try {
      // Daily is a reminder in both modes (master spec §11, R07 open).
      // A scheduled job never posts a check-in for someone: that would
      // tell the group something the person never did. The "automatic"
      // mode value is kept for existing rows until R07 is decided.
      await sendPushNotificationToUser({
        userId: schedule.member.userId,
        title: "Daily check-in",
        body: "It's time for your check-in. Open ALRT to check in.",
        data: {
          circleId: schedule.circleId,
          scheduledCheckInId: schedule.id,
        },
        type: PushNotificationType.familyScheduledCheckInPrompt,
      });
    } catch (error) {
      console.error(
        `Scheduled check-in ${schedule.id} failed to fire:`,
        error,
      );
    }
  }

  return due.length;
};

// ---------------------------------------------------------------------------
// Saved places
// ---------------------------------------------------------------------------

export const listPlaces = async (userId: string, circleId?: string) => {
  const membership = await requireMembership(userId, circleId);
  return prisma.familySavedPlace.findMany({
    where: { circleId: membership.circleId },
    include: { notificationPrefs: true },
    orderBy: { createdAt: "asc" },
  });
};

export const createPlace = async (
  userId: string,
  input: {
    name: string;
    icon?: FamilyPlaceIcon | undefined;
    latitude: number;
    longitude: number;
    radiusMeters?: number | undefined;
    address?: string | undefined;
  },
  circleId?: string,
) => {
  const membership = await requireMembership(userId, circleId);
  if (membership.role === "child") {
    throw new HttpError(403, "Children cannot manage places");
  }

  const place = await prisma.familySavedPlace.create({
    data: {
      circleId: membership.circleId,
      name: input.name,
      icon: input.icon ?? "other",
      latitude: input.latitude,
      longitude: input.longitude,
      radiusMeters: input.radiusMeters ?? 300,
      ...(input.address && { address: input.address }),
      createdById: membership.id,
    },
    include: { notificationPrefs: true },
  });

  await notifyCircle({
    circleId: membership.circleId,
    socketEvent: SocketEvent.familyCircleUpdate,
    socketData: { circleId: membership.circleId },
  });

  // Points & Badge Logic v1.1: a saved place earns 5, per place.
  await awardSavedPlace(userId, place.id);

  return place;
};

export const updatePlace = async (
  userId: string,
  placeId: string,
  input: {
    name?: string | undefined;
    icon?: FamilyPlaceIcon | undefined;
    latitude?: number | undefined;
    longitude?: number | undefined;
    radiusMeters?: number | undefined;
    address?: string | undefined;
  },
) => {
  const place = await prisma.familySavedPlace.findUnique({
    where: { id: placeId },
  });
  if (!place) throw new HttpError(404, "Place not found");

  const membership = await requireMembership(userId, place.circleId);
  if (membership.role === "child") {
    throw new HttpError(403, "Children cannot manage places");
  }

  const updated = await prisma.familySavedPlace.update({
    where: { id: place.id },
    data: {
      ...(input.name !== undefined && { name: input.name }),
      ...(input.icon !== undefined && { icon: input.icon }),
      ...(input.latitude !== undefined && { latitude: input.latitude }),
      ...(input.longitude !== undefined && { longitude: input.longitude }),
      ...(input.radiusMeters !== undefined && {
        radiusMeters: input.radiusMeters,
      }),
      ...(input.address !== undefined && { address: input.address }),
    },
    include: { notificationPrefs: true },
  });

  await notifyCircle({
    circleId: membership.circleId,
    socketEvent: SocketEvent.familyCircleUpdate,
    socketData: { circleId: membership.circleId },
  });

  return updated;
};

export const deletePlace = async (userId: string, placeId: string) => {
  const place = await prisma.familySavedPlace.findUnique({
    where: { id: placeId },
  });
  if (!place) throw new HttpError(404, "Place not found");

  const membership = await requireMembership(userId, place.circleId);
  if (membership.role === "child") {
    throw new HttpError(403, "Children cannot manage places");
  }

  await prisma.familySavedPlace.delete({ where: { id: place.id } });
  await notifyCircle({
    circleId: membership.circleId,
    socketEvent: SocketEvent.familyCircleUpdate,
    socketData: { circleId: membership.circleId },
  });
};

export const updatePlaceNotificationPref = async (
  userId: string,
  placeId: string,
  input: {
    subjectMemberId: string;
    notifyArrivals: boolean;
    notifyDepartures: boolean;
  },
) => {
  const place = await prisma.familySavedPlace.findUnique({
    where: { id: placeId },
  });
  if (!place) throw new HttpError(404, "Place not found");

  const membership = await requireMembership(userId, place.circleId);

  const subject = await prisma.familyMember.findFirst({
    where: { id: input.subjectMemberId, circleId: membership.circleId },
  });
  if (!subject) throw new HttpError(404, "Member not found in your circle");

  return prisma.familyPlaceNotificationPref.upsert({
    where: {
      placeId_subjectMemberId: {
        placeId: place.id,
        subjectMemberId: subject.id,
      },
    },
    create: {
      placeId: place.id,
      subjectMemberId: subject.id,
      notifyArrivals: input.notifyArrivals,
      notifyDepartures: input.notifyDepartures,
    },
    update: {
      notifyArrivals: input.notifyArrivals,
      notifyDepartures: input.notifyDepartures,
    },
  });
};

// ---------------------------------------------------------------------------
// SOS recipient presets (locked spec §28) — named lists owned by the
// SENDER, configured in advance, never during an emergency. A list may mix
// members across the owner's circles.
// ---------------------------------------------------------------------------

const MAX_SOS_LISTS = 4;

export const listSosLists = async (userId: string) => {
  await requireMembership(userId);
  return prisma.familySosList.findMany({
    where: { ownerUserId: userId },
    orderBy: { createdAt: "asc" },
  });
};

/** Every recipient must be a member of one of the owner's circles. */
const assertSosListMembersValid = async (
  userId: string,
  memberIds: string[],
) => {
  if (memberIds.length === 0) return;
  const myCircles = await prisma.familyMember.findMany({
    where: { userId },
    select: { circleId: true },
  });
  const validCount = await prisma.familyMember.count({
    where: {
      id: { in: memberIds },
      circleId: { in: myCircles.map((m) => m.circleId) },
    },
  });
  if (validCount !== memberIds.length) {
    throw new HttpError(400, "Every recipient must be in one of your circles");
  }
};

export const createSosList = async (
  userId: string,
  input: {
    name: string;
    memberIds: string[];
    isDefault?: boolean | undefined;
  },
) => {
  await requireMembership(userId);

  const existing = await prisma.familySosList.count({
    where: { ownerUserId: userId },
  });
  if (existing >= MAX_SOS_LISTS) {
    throw new HttpError(
      400,
      `You can have at most ${MAX_SOS_LISTS} SOS lists`,
    );
  }

  const memberIds = [...new Set(input.memberIds)];
  await assertSosListMembersValid(userId, memberIds);

  // The first list becomes the default automatically.
  const isDefault = input.isDefault ?? existing === 0;

  return prisma.$transaction(async (tx) => {
    if (isDefault) {
      await tx.familySosList.updateMany({
        where: { ownerUserId: userId },
        data: { isDefault: false },
      });
    }
    return tx.familySosList.create({
      data: { ownerUserId: userId, name: input.name, memberIds, isDefault },
    });
  });
};

export const updateSosList = async (
  userId: string,
  sosListId: string,
  input: {
    name?: string | undefined;
    memberIds?: string[] | undefined;
    isDefault?: boolean | undefined;
  },
) => {
  const list = await prisma.familySosList.findFirst({
    where: { id: sosListId, ownerUserId: userId },
  });
  if (!list) throw new HttpError(404, "SOS list not found");

  const memberIds =
    input.memberIds === undefined ? undefined : [...new Set(input.memberIds)];
  if (memberIds !== undefined) {
    await assertSosListMembersValid(userId, memberIds);
  }

  return prisma.$transaction(async (tx) => {
    if (input.isDefault === true) {
      await tx.familySosList.updateMany({
        where: { ownerUserId: userId, id: { not: list.id } },
        data: { isDefault: false },
      });
    }
    return tx.familySosList.update({
      where: { id: list.id },
      data: {
        ...(input.name !== undefined && { name: input.name }),
        ...(memberIds !== undefined && { memberIds }),
        ...(input.isDefault !== undefined && { isDefault: input.isDefault }),
      },
    });
  });
};

export const deleteSosList = async (userId: string, sosListId: string) => {
  const list = await prisma.familySosList.findFirst({
    where: { id: sosListId, ownerUserId: userId },
  });
  if (!list) throw new HttpError(404, "SOS list not found");
  await prisma.familySosList.delete({ where: { id: list.id } });
  return { deleted: true };
};

/**
 * Removes departed members from every SOS list referencing them and tells
 * each list owner — lists never silently misrepresent their size (§28).
 */
export const pruneMembersFromSosLists = async (
  memberIds: string[],
  departedName?: string,
) => {
  if (memberIds.length === 0) return;
  const lists = await prisma.familySosList.findMany({
    where: { memberIds: { hasSome: memberIds } },
  });

  for (const list of lists) {
    const remaining = list.memberIds.filter((id) => !memberIds.includes(id));
    await prisma.familySosList.update({
      where: { id: list.id },
      data: { memberIds: remaining },
    });
    await sendPushNotificationToUser({
      userId: list.ownerUserId,
      title: 'SOS list updated',
      body:
        `${departedName ?? 'A member'} left a circle and was removed from ` +
        `"${list.name}". It now reaches ${remaining.length} ` +
        `${remaining.length === 1 ? 'person' : 'people'}.`,
      data: { sosListId: list.id },
      type: PushNotificationType.familyCircleUpdate,
    });
  }
};

// ---------------------------------------------------------------------------
// SOS
// ---------------------------------------------------------------------------

export type SosLocationMode = "none" | "once" | "live";
export type SosLocationPrecision = "precise" | "approximate";

/** How old a point may be and still be shown as where someone is now. */
export const SOS_POINT_MAX_AGE_MS = 2 * 60 * 1000;

export interface SosAudienceCandidate {
  memberId: string;
  userId: string;
  name: string;
  eligible: boolean;
  /** Why not eligible: needs ALRT + here, or the group's plan ended. */
  reason: "needs_individual" | "sponsorship_paused" | null;
  /** No device registered: the SOS reaches them in the app, but a push
   * notification may not arrive. Eligibility is never a delivery promise. */
  deliveryLimited: boolean;
}

export interface SosAudience {
  preset: {
    id: string;
    name: string;
    /** ok | outdated (names people who have left) | otherGroup | empty */
    state: "ok" | "outdated" | "otherGroup" | "empty";
    removedCount: number;
    otherGroupCount: number;
  } | null;
  candidates: SosAudienceCandidate[];
}

/**
 * Who an SOS from [membership] would reach right now, with or without a
 * preset. The SAME function backs the preview and the send, so what the
 * sender is shown is what the send enforces, re-checked at activation.
 */
export const resolveSosAudience = async (
  userId: string,
  membership: { id: string; circleId: string },
  sosListId?: string,
): Promise<SosAudience> => {
  let preset: SosAudience["preset"] = null;
  let memberIds: string[] | null = null;
  if (sosListId) {
    const list = await prisma.familySosList.findFirst({
      where: { id: sosListId, ownerUserId: userId },
    });
    if (!list) throw new HttpError(404, "SOS list not found");
    const listed = await prisma.familyMember.findMany({
      where: { id: { in: list.memberIds } },
      select: { id: true, circleId: true },
    });
    const otherGroupCount = listed.filter((m) => m.circleId !== membership.circleId).length;
    const removedCount = list.memberIds.length - listed.length;
    const inGroup = listed.filter((m) => m.circleId === membership.circleId && m.id !== membership.id);
    preset = {
      id: list.id,
      name: list.name,
      state:
        otherGroupCount > 0
          ? "otherGroup"
          : inGroup.length === 0
            ? "empty"
            : removedCount > 0
              ? "outdated"
              : "ok",
      removedCount,
      otherGroupCount,
    };
    memberIds = inGroup.map((m) => m.id);
  }
  const members = await prisma.familyMember.findMany({
    where: {
      circleId: membership.circleId,
      id: memberIds ? { in: memberIds } : { not: membership.id },
    },
    orderBy: { createdAt: "asc" },
    select: {
      id: true,
      userId: true,
      nickname: true,
      user: { select: { name: true, _count: { select: { devices: true } } } },
    },
  });
  const candidates: SosAudienceCandidate[] = [];
  const seen = new Set<string>();
  for (const m of members) {
    if (m.userId === userId || seen.has(m.userId)) continue;
    seen.add(m.userId);
    const access = await getConnectionAccess(m.userId, membership.circleId);
    candidates.push({
      memberId: m.id,
      userId: m.userId,
      name: m.nickname || m.user.name || "Family member",
      eligible: access.allowed,
      reason: access.allowed
        ? null
        : access.reason === "sponsorship_paused"
          ? "sponsorship_paused"
          : "needs_individual",
      deliveryLimited: m.user._count.devices === 0,
    });
  }
  return { preset, candidates };
};

/**
 * GET /api/family/sos/preview: exactly who an SOS would reach now, and
 * why anyone is left out. Never a delivery promise.
 */
export const previewSos = async (
  userId: string,
  sosListId?: string,
  circleId?: string,
) => {
  const membership = await requireMembership(userId, circleId);
  const access = await getConnectionAccess(userId, membership.circleId);
  const audience = await resolveSosAudience(userId, membership, sosListId);
  const eligible = audience.candidates.filter((c) => c.eligible);
  const state = !access.allowed
    ? "senderNoAccess"
    : audience.preset && (audience.preset.state === "otherGroup" || audience.preset.state === "empty")
      ? "presetInvalid"
      : audience.candidates.length === 0
        ? "noPeople"
        : eligible.length === 0
          ? "noneEligible"
          : "ok";
  return {
    circleId: membership.circleId,
    state,
    senderAccess: access,
    preset: audience.preset,
    recipients: eligible.map((c) => ({
      memberId: c.memberId,
      name: c.name,
      deliveryLimited: c.deliveryLimited,
    })),
    excluded: audience.candidates
      .filter((c) => !c.eligible)
      .map((c) => ({ memberId: c.memberId, name: c.name, reason: c.reason })),
  };
};

/** The explicit per-SOS location mode, from the new field or the old pair. */
export const sosLocationModeOf = (input: {
  locationMode?: SosLocationMode | undefined;
  isLive: boolean;
  latitude?: number | undefined;
  longitude?: number | undefined;
}): SosLocationMode => {
  if (input.locationMode) return input.locationMode;
  if (input.isLive) return "live";
  return input.latitude !== undefined && input.longitude !== undefined ? "once" : "none";
};

/**
 * The precision a point is delivered at: what the sender asked for, never
 * finer than their own sharing setting (precise only for "precise").
 */
export const sosPrecisionFor = (
  sharingLevel: string,
  requested?: SosLocationPrecision,
): SosLocationPrecision =>
  sharingLevel === "precise" && requested !== "approximate" ? "precise" : "approximate";

const suburbLabelFor = async (latitude: number, longitude: number) => {
  try {
    const address = await convertLatLngToAddress(latitude, longitude);
    return address ? toSuburbLabel(address) : null;
  } catch {
    return null;
  }
};

export const triggerSos = async (
  userId: string,
  input: {
    latitude?: number | undefined;
    longitude?: number | undefined;
    sosListId?: string | undefined;
    isLive: boolean;
    locationMode?: SosLocationMode | undefined;
    locationPrecision?: SosLocationPrecision | undefined;
    locationCapturedAt?: string | undefined;
    locationAccuracyM?: number | undefined;
  },
  circleId?: string,
) => {
  // Everything is validated BEFORE any location write, notification or
  // broadcast: membership, access, the preset, at least one eligible
  // recipient and the location choice. A refused SOS changes nothing and
  // tells nobody; its point is never stored.
  const membership = await requireMembership(userId, circleId);
  // SOS is a covered connection feature (V1 access model), per person and
  // per group. Ending an SOS is never gated.
  await assertConnectionAccess(userId, membership.circleId);

  const mode = sosLocationModeOf(input);
  if ((mode === "live") !== input.isLive) {
    throw new HttpError(400, "isLive must match the location choice");
  }
  const hasPoint =
    mode !== "none" && input.latitude !== undefined && input.longitude !== undefined;
  let capturedAt: Date | null = null;
  if (hasPoint && input.locationCapturedAt) {
    capturedAt = new Date(input.locationCapturedAt);
    if (Number.isNaN(capturedAt.getTime()) || capturedAt.getTime() > Date.now() + 60_000) {
      throw new HttpError(400, "The location time is not valid");
    }
  }

  // The audience (master spec §12): with a preset, exactly that list's
  // members; without one, everyone else in this group. Either way only
  // people in THIS group who currently have access here. A preset naming
  // someone in another group is refused, not widened or quietly trimmed.
  const audience = await resolveSosAudience(userId, membership, input.sosListId);
  const listName = audience.preset?.name ?? null;
  if (audience.preset?.state === "otherGroup") {
    throw new HttpError(
      422,
      `"${audience.preset.name}" includes people from another group. Edit it so it only names people in this group, or send to everyone in this group.`,
      "SOS_PRESET_OTHER_GROUP",
      { sosListId: audience.preset.id },
    );
  }
  const recipientUserIds = audience.candidates.filter((c) => c.eligible).map((c) => c.userId);
  if (recipientUserIds.length === 0) {
    const presetEmpty = audience.preset?.state === "empty";
    throw new HttpError(
      422,
      presetEmpty
        ? `No one on "${listName}" is in this group any more. Edit the list first. If you are in immediate danger, call your local emergency number.`
        : audience.candidates.length === 0
          ? "Add someone first. You need at least one other person to send an SOS. If you are in immediate danger, call your local emergency number."
          : listName
            ? `No one on "${listName}" can receive an SOS right now. Edit the list first. If you are in immediate danger, call your local emergency number.`
            : "No one in this group can receive an SOS right now. If you are in immediate danger, call your local emergency number.",
      "NO_SOS_RECIPIENTS",
      {
        hasCandidates: audience.candidates.length > 0,
        ...(audience.preset && { sosListId: audience.preset.id, presetState: audience.preset.state }),
      },
    );
  }

  // --- validated: side effects start here ---------------------------------

  // A member has at most one active SOS: the previous one is replaced.
  await prisma.familySosEvent.updateMany({
    where: { memberId: membership.id, status: "active" },
    data: {
      status: "cancelled",
      resolvedAt: new Date(),
      endedByMemberId: membership.id,
      latitude: null,
      longitude: null,
      locationLabel: null,
    },
  });

  // Location comes only from this SOS itself, at the precision allowed,
  // and stays inside this SOS's audience: it never writes the group's
  // snapshot channel. "approximate" keeps a suburb label and discards the
  // coordinates. No point sent means no location (never a stored one).
  const precision = sosPrecisionFor(membership.sharingLevel, input.locationPrecision);
  const label = hasPoint ? await suburbLabelFor(input.latitude!, input.longitude!) : null;
  const sos = await prisma.familySosEvent.create({
    data: {
      circleId: membership.circleId,
      memberId: membership.id,
      isLive: input.isLive,
      recipientUserIds,
      audienceRestricted: true,
      locationMode: mode,
      ...(hasPoint && {
        locationPrecision: precision,
        locationCapturedAt: capturedAt ?? new Date(),
        ...(input.locationAccuracyM !== undefined && { locationAccuracyM: input.locationAccuracyM }),
        ...(label && { locationLabel: label }),
        ...(precision === "precise" && { latitude: input.latitude!, longitude: input.longitude! }),
      }),
    },
    include: {
      member: { select: memberIdentitySelect },
      responses: true,
    },
  });
  if (hasPoint && precision === "precise") {
    await prisma.familyLocationPing.create({
      data: {
        memberId: membership.id,
        sosEventId: sos.id,
        latitude: input.latitude!,
        longitude: input.longitude!,
        ...(input.locationAccuracyM !== undefined && { accuracy: input.locationAccuracyM }),
      },
    });
  }

  const memberName =
    sos.member.nickname || sos.member.user.name || "A family member";
  const title = `🆘 ${memberName} triggered SOS`;
  // No suburb on the lock screen: where they are is inside the app, for
  // the audience only, after a tap.
  const body = "Open ALRT to see their SOS and respond.";
  const data = {
    circleId: membership.circleId,
    sosEventId: sos.id,
    ...(listName && { sosListName: listName }),
  };

  // Only the stored audience is told, by socket and push. A queued push is
  // not a delivery: the app shows "seen" only from an explicit response.
  sendSocketEventToUsers({
    userIds: [userId, ...recipientUserIds],
    event: SocketEvent.familySos,
    data: sos,
  });
  await Promise.allSettled(
    recipientUserIds.map((recipientUserId) =>
      sendPushNotificationToUser({
        userId: recipientUserId,
        title,
        body,
        data,
        type: PushNotificationType.familySos,
        urgent: true,
      }),
    ),
  );

  return sos;
};

/**
 * One live point for the sender's own running SOS. Goes to that SOS's
 * audience only (socket + the SOS row + its trail) and never to the
 * group's snapshot channel. Only a live SOS takes points, only while it
 * runs (4-hour cap), only fresh points, at the SOS's precision.
 */
export const recordSosLocation = async (
  userId: string,
  sosEventId: string,
  input: {
    latitude: number;
    longitude: number;
    accuracy?: number | undefined;
    capturedAt?: string | undefined;
  },
) => {
  const sos = await prisma.familySosEvent.findUnique({
    where: { id: sosEventId },
    include: { member: { select: { userId: true, sharingLevel: true } } },
  });
  if (!sos || sos.member.userId !== userId) throw new HttpError(404, "SOS event not found");
  if (sos.status !== "active" || sos.createdAt.getTime() <= Date.now() - SOS_MAX_DURATION_MS) {
    throw new HttpError(409, "This SOS has ended, so live sharing has stopped");
  }
  const live = sos.locationMode ? sos.locationMode === "live" : sos.isLive;
  if (!live) {
    throw new HttpError(409, "Live location was not chosen for this SOS");
  }
  const capturedAt = input.capturedAt ? new Date(input.capturedAt) : new Date();
  if (
    Number.isNaN(capturedAt.getTime()) ||
    capturedAt.getTime() > Date.now() + 60_000 ||
    capturedAt.getTime() < Date.now() - SOS_POINT_MAX_AGE_MS
  ) {
    throw new HttpError(400, "Live points must be current");
  }
  const precision =
    (sos.locationPrecision as SosLocationPrecision | null) ??
    sosPrecisionFor(sos.member.sharingLevel);
  const label = await suburbLabelFor(input.latitude, input.longitude);
  const updated = await prisma.familySosEvent.update({
    where: { id: sos.id },
    data: {
      locationPrecision: precision,
      locationCapturedAt: capturedAt,
      ...(input.accuracy !== undefined && { locationAccuracyM: input.accuracy }),
      ...(label && { locationLabel: label }),
      ...(precision === "precise" && { latitude: input.latitude, longitude: input.longitude }),
    },
    include: {
      member: { select: memberIdentitySelect },
      responses: { include: { member: { select: memberIdentitySelect } } },
    },
  });
  if (precision === "precise") {
    await prisma.familyLocationPing.create({
      data: {
        memberId: sos.memberId,
        sosEventId: sos.id,
        latitude: input.latitude,
        longitude: input.longitude,
        ...(input.accuracy !== undefined && { accuracy: input.accuracy }),
      },
    });
  }
  sendSocketEventToUsers({
    userIds: await sosAudienceUserIds(updated),
    event: SocketEvent.familySosLocation,
    data: {
      sosEventId: sos.id,
      latitude: updated.latitude,
      longitude: updated.longitude,
      locationLabel: updated.locationLabel,
      locationCapturedAt: updated.locationCapturedAt,
      locationPrecision: precision,
    },
  });
  return { accepted: true, precision };
};

/**
 * Prisma filter: SOS events [userId] may see. New events are visible to
 * their sender and stored recipients only; events from before the stored
 * audience existed keep their old whole-group visibility.
 */
const sosVisibleTo = (userId: string) => ({
  OR: [
    { audienceRestricted: false },
    { recipientUserIds: { has: userId } },
    { member: { userId } },
  ],
});

/** Throws 404 unless [userId] is the sender or in the stored audience. */
const assertSosAudience = (
  sos: { audienceRestricted: boolean; recipientUserIds: string[] },
  userId: string,
  senderUserId: string,
) => {
  if (!sos.audienceRestricted) return;
  if (userId === senderUserId || sos.recipientUserIds.includes(userId)) return;
  throw new HttpError(404, "SOS event not found");
};

/** Who is told about changes to this SOS (never the whole group by default). */
const sosAudienceUserIds = async (sos: {
  circleId: string;
  audienceRestricted: boolean;
  recipientUserIds: string[];
  member: { user: { id: string } } | { userId: string };
}) => {
  const senderId = "userId" in sos.member ? sos.member.userId : sos.member.user.id;
  if (sos.audienceRestricted) return [senderId, ...sos.recipientUserIds];
  return getCircleUserIds(sos.circleId);
};

export const respondToSos = async (
  userId: string,
  sosEventId: string,
  type: FamilySosResponseType,
) => {
  const sos = await prisma.familySosEvent.findUnique({
    where: { id: sosEventId },
    include: {
      member: {
        include: { user: { select: { id: true, name: true } } },
      },
    },
  });
  if (!sos) throw new HttpError(404, "SOS event not found");

  const membership = await requireMembership(userId, sos.circleId);
  assertSosAudience(sos, userId, sos.member.user.id);
  // Late acknowledgments are blocked: once an SOS has ended its response
  // list is a closed record, so history shows exactly who saw it while
  // it ran and nobody can add to it afterwards.
  if (sos.status !== "active") {
    throw new HttpError(
      400,
      "This SOS has ended, so it can no longer be acknowledged",
    );
  }
  if (sos.memberId === membership.id) {
    throw new HttpError(400, "You cannot respond to your own SOS");
  }

  const response = await prisma.familySosResponse.upsert({
    where: {
      sosEventId_memberId_type: {
        sosEventId: sos.id,
        memberId: membership.id,
        type,
      },
    },
    create: { sosEventId: sos.id, memberId: membership.id, type },
    update: {},
    include: { member: { select: memberIdentitySelect } },
  });

  const responderName =
    response.member.nickname ||
    response.member.user.name ||
    "A family member";
  const actionText =
    type === "onMyWay"
      ? `${responderName} is on their way`
      : type === "called"
        ? `${responderName} is calling for help`
        : `${responderName} has seen the SOS`;

  // The person IN SOS gets their own directed message — knowing who has
  // seen it and who is coming is the whole point of responding (product
  // owner 2026-08-07). Socket first so the open app updates instantly,
  // then the push for a pocketed phone.
  const ownerCopy =
    type === "onMyWay"
      ? `${responderName} is on their way to you`
      : type === "called"
        ? `${responderName} is calling for help for you`
        : `${responderName} has seen your SOS`;
  sendSocketEventToUsers({
    userIds: [sos.member.user.id],
    event: SocketEvent.familySosResponse,
    data: response,
  });
  await sendPushNotificationToUser({
    userId: sos.member.user.id,
    title: ownerCopy,
    body: "They can see your live location.",
    data: { circleId: membership.circleId, sosEventId: sos.id },
    type: PushNotificationType.familySosResponse,
  });

  // The rest of this SOS's audience (never people outside it) gets the
  // third-person update.
  const audience = await sosAudienceUserIds(sos);
  await notifyUsers({
    userIds: audience.filter((id) => id !== userId && id !== sos.member.user.id),
    title: "SOS update",
    body: actionText,
    data: { circleId: membership.circleId, sosEventId: sos.id },
    type: PushNotificationType.familySosResponse,
    socketEvent: SocketEvent.familySosResponse,
    socketData: response,
  });

  return response;
};

/**
 * The live trail behind an SOS, for circle members watching the map.
 *
 * Only points since the SOS started, only while the event exists: after
 * stand-down the rows are already deleted (locked spec), so this endpoint
 * cannot leak a wiped trail. Caller must be in the event's circle.
 */
export const getSosTrail = async (userId: string, sosEventId: string) => {
  const sos = await prisma.familySosEvent.findUnique({
    where: { id: sosEventId },
    select: {
      id: true,
      circleId: true,
      memberId: true,
      createdAt: true,
      status: true,
      audienceRestricted: true,
      recipientUserIds: true,
      member: { select: { userId: true } },
    },
  });
  if (!sos) throw new HttpError(404, "SOS event not found");

  const membership = await prisma.familyMember.findFirst({
    where: { userId, circleId: sos.circleId },
    select: { id: true },
  });
  if (!membership) {
    throw new HttpError(403, "You are not a member of this circle");
  }
  // Only the sender and the SOS's own audience see the trail.
  assertSosAudience(sos, userId, sos.member.userId);

  // Stand-down wipes the trail (locked spec), so a resolved SOS has no
  // trail to serve. Without this gate, a point shared AFTER stand-down
  // (an ordinary check-in) would come back dressed as trail data for an
  // event whose trail is supposed to be gone.
  if (sos.status !== "active") {
    return { sosEventId: sos.id, points: [] };
  }

  // New events: exactly the points shared into THIS SOS. Older events
  // keep the old definition (points since it started).
  const points = await prisma.familyLocationPing.findMany({
    where: sos.audienceRestricted
      ? { sosEventId: sos.id }
      : { memberId: sos.memberId, createdAt: { gte: sos.createdAt } },
    orderBy: { createdAt: "asc" },
    select: {
      latitude: true,
      longitude: true,
      isMoving: true,
      createdAt: true,
    },
  });
  return { sosEventId: sos.id, points };
};

export const resolveSos = async (userId: string, sosEventId: string) => {
  const sos = await prisma.familySosEvent.findUnique({
    where: { id: sosEventId },
    include: {
      member: { include: { user: { select: { id: true, name: true } } } },
    },
  });
  if (!sos) throw new HttpError(404, "SOS event not found");

  const membership = await requireMembership(userId, sos.circleId);
  assertSosAudience(sos, userId, sos.member.user.id);
  if (sos.status !== "active") return sos;

  // Who may end someone else's SOS is open decision R06; the existing rule
  // (the sender or the group host) stays, and the actual actor is recorded.
  const canResolve = sos.memberId === membership.id || membership.role === "owner";
  if (!canResolve) {
    throw new HttpError(
      403,
      "Only the person who sent the SOS or the group host can end it",
    );
  }

  // Ending also wipes the trigger position now, exactly as the 4-hour
  // auto-end already does (endLapsedSosEvents) - the ended row keeps
  // who/when/how long, never where. The stored status value stays
  // "resolved" for existing clients; it is never shown as "resolved".
  const resolved = await prisma.familySosEvent.update({
    where: { id: sos.id },
    data: {
      status: "resolved",
      resolvedAt: new Date(),
      endedByMemberId: membership.id,
      latitude: null,
      longitude: null,
      locationLabel: null,
    },
    // With the member, so every phone can still tell whose SOS ended
    // (the sender's own reads "Your SOS has ended", never a stranger's).
    include: {
      member: { select: memberIdentitySelect },
      responses: { include: { member: { select: memberIdentitySelect } } },
    },
  });

  // Stand-down wipes the trail (locked spec): every live-share point from
  // this event is deleted now, not archived, not left to the 24h prune.
  // History keeps only the time and duration.
  await prisma.familyLocationPing.deleteMany({
    where: { memberId: sos.memberId, createdAt: { gte: sos.createdAt } },
  });

  const memberName =
    sos.member.nickname || sos.member.user.name || "A family member";
  const endedBySender = sos.memberId === membership.id;
  let actorName = memberName;
  if (!endedBySender) {
    const actor = await prisma.user.findUnique({
      where: { id: userId },
      select: { name: true },
    });
    actorName = membership.nickname || actor?.name || "The group host";
  }

  // Factual ending wording (master spec §12): never "safe" or "resolved".
  const audience = await sosAudienceUserIds(sos);
  await notifyUsers({
    userIds: audience.filter((id) => id !== userId),
    title: "SOS ended",
    body: endedBySender
      ? `${memberName} ended their SOS.`
      : `${actorName} ended ${memberName}'s SOS.`,
    data: { circleId: membership.circleId, sosEventId: sos.id },
    type: PushNotificationType.familySosResolved,
    socketEvent: SocketEvent.familySosResolved,
    socketData: resolved,
  });
  // The sender's own other devices close their SOS screen too.
  sendSocketEventToUsers({
    userIds: [userId],
    event: SocketEvent.familySosResolved,
    data: resolved,
  });

  return resolved;
};

/**
 * Locked spec: SOS live share caps at 4 hours. An SOS that is never stood
 * down by hand must stand itself down, or a phone that goes quiet keeps
 * sharing a location forever: the 1-hour purge only touches events with a
 * `resolvedAt`, so an event left active is never swept at all.
 *
 * Same shape as endLapsedJourneys: mark it resolved, wipe the coordinates,
 * and delete the live-share trail the way a manual stand-down does. History
 * keeps only the time and the duration.
 */
export const SOS_MAX_DURATION_MS = 4 * 60 * 60 * 1000;

export const endLapsedSosEvents = async (): Promise<number> => {
  const cutoff = new Date(Date.now() - SOS_MAX_DURATION_MS);
  const lapsed = await prisma.familySosEvent.findMany({
    where: { status: "active", createdAt: { lte: cutoff } },
    include: {
      member: { select: memberIdentitySelect },
      responses: { include: { member: { select: memberIdentitySelect } } },
    },
  });
  if (lapsed.length === 0) return 0;

  const now = new Date();
  await prisma.familySosEvent.updateMany({
    where: { id: { in: lapsed.map((sos) => sos.id) } },
    data: {
      status: "resolved",
      resolvedAt: now,
      latitude: null,
      longitude: null,
      locationLabel: null,
    },
  });

  // Wipe each trail from the moment its own SOS started.
  await Promise.all(
    lapsed.map((sos) =>
      prisma.familyLocationPing.deleteMany({
        where: { memberId: sos.memberId, createdAt: { gte: sos.createdAt } },
      }),
    ),
  );

  // Tell the open screens (this SOS's audience only), so a receiver's map
  // stops showing a live dot.
  await Promise.allSettled(
    lapsed.map(async (sos) =>
      notifyUsers({
        userIds: await sosAudienceUserIds(sos),
        title: "SOS ended",
        // The app formats "This SOS expired at [time]" in local time from
        // resolvedAt; the push can't know the reader's time zone.
        body: "This SOS expired after 4 hours. Live sharing has stopped.",
        data: { circleId: sos.circleId, sosEventId: sos.id, expired: true },
        type: PushNotificationType.familySosResolved,
        socketEvent: SocketEvent.familySosResolved,
        // The whole row, as a manual stand-down sends: the app's parser
        // needs memberId, and a bare {id, status} was dropped unread, which
        // left the red SOS strip live on every phone until the next reload.
        socketData: {
          ...sos,
          status: "resolved",
          resolvedAt: now,
          latitude: null,
          longitude: null,
          locationLabel: null,
        },
      }),
    ),
  );

  return lapsed.length;
};

/**
 * Stood-down SOS events for the circle, newest first, with who acknowledged
 * each one and when. This is the retained SOS history: the event log (who
 * triggered it, when it started and ended, who saw it) survives stand-down;
 * the trigger location never does. The purge job wipes coordinates an hour
 * after stand-down, but that job only runs where the scheduler is armed
 * (NODE_ENV=prod), so history strips them on the way out regardless -
 * locked rule: history keeps only time and duration, never locations.
 * Bounded so a busy circle cannot pull its entire past in one call.
 */
export const SOS_HISTORY_DAYS = 30;
export const SOS_HISTORY_LIMIT = 20;

export const getSosHistory = async (userId: string, circleId?: string) => {
  const membership = await requireMembership(userId, circleId);
  const since = new Date(Date.now() - SOS_HISTORY_DAYS * 24 * 60 * 60 * 1000);
  const events = await prisma.familySosEvent.findMany({
    where: {
      circleId: membership.circleId,
      status: { not: "active" },
      createdAt: { gte: since },
      ...sosVisibleTo(userId),
    },
    include: {
      member: { select: memberIdentitySelect },
      responses: {
        include: { member: { select: memberIdentitySelect } },
        orderBy: { createdAt: "asc" },
      },
    },
    orderBy: [{ resolvedAt: "desc" }, { createdAt: "desc" }],
    take: SOS_HISTORY_LIMIT,
  });
  return events.map((event) => ({
    ...event,
    latitude: null,
    longitude: null,
    locationLabel: null,
  }));
};

/**
 * Live SOS events the user may see. With a circleId: that circle only.
 * Without one: every circle the user belongs to, so the red strip (which
 * covers "any of your groups") survives a reload while another circle's
 * SOS is live.
 */
export const getActiveSos = async (userId: string, circleId?: string) => {
  let circleIds: string[];
  if (circleId) {
    const membership = await requireMembership(userId, circleId);
    circleIds = [membership.circleId];
  } else {
    const memberships = await prisma.familyMember.findMany({
      where: { userId },
      select: { circleId: true },
    });
    if (memberships.length === 0) {
      throw new HttpError(404, "You are not part of a family circle yet");
    }
    circleIds = memberships.map((m) => m.circleId);
  }
  return prisma.familySosEvent.findMany({
    where: { circleId: { in: circleIds }, status: "active", ...sosVisibleTo(userId) },
    include: {
      member: { select: memberIdentitySelect },
      responses: {
        include: { member: { select: memberIdentitySelect } },
      },
    },
    orderBy: { createdAt: "desc" },
  });
};
