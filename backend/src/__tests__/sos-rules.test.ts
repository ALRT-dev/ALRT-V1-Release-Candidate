/**
 * SOS business rules (family.service):
 *
 *  - extendSos: each extension adds an hour, but the SOS can never run past
 *    4 hours from its createdAt (409, code MAX_DURATION).
 *  - resolveSos: the sender OR the group host (role "owner") can end an SOS;
 *    anyone else gets 403. endedByMemberId records who ended it and the push
 *    copy names them factually (never "safe" or "resolved").
 *  - createScheduledCheckIn: an IANA timezone or the phone's utcOffsetMinutes
 *    is required (no Brisbane default); offsets resolve to Etc/GMT zones.
 */
import { describe, it, expect, vi, beforeEach } from "vitest";

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

vi.mock("@prisma/client", () => ({}));

vi.mock("../utils/prisma_client.util.js", () => ({
  default: {
    familySosEvent: {
      findUnique: vi.fn(),
      update: vi.fn(),
    },
    familyMember: {
      findFirst: vi.fn(),
      findMany: vi.fn(),
    },
    familyLocationPing: {
      deleteMany: vi.fn(async () => ({ count: 0 })),
    },
    familyScheduledCheckIn: {
      count: vi.fn(async () => 0),
      upsert: vi.fn(),
    },
    user: {
      findUnique: vi.fn(),
    },
  },
}));

vi.mock("../services/google_map.service.js", () => ({
  convertLatLngToAddress: vi.fn(),
}));
vi.mock("../services/socket.service.js", () => ({
  sendSocketEventToUsers: vi.fn(),
}));
vi.mock("../services/notification.service.js", () => ({
  claimHazardPushRecipients: vi.fn(),
  sendPushNotificationToUser: vi.fn(async () => undefined),
}));
vi.mock("../services/xp_ledger.service.js", () => ({
  awardFamilyJoined: vi.fn(),
  awardSavedPlace: vi.fn(),
}));
vi.mock("../services/entitlement.service.js", () => ({
  assertConnectionAccess: vi.fn(),
  assertSponsoredCapacity: vi.fn(),
  defaultCirclePlan: vi.fn(),
  getConnectionAccess: vi.fn(),
  getGroupCoverage: vi.fn(),
}));

// ---------------------------------------------------------------------------
// Imports (after mocks)
// ---------------------------------------------------------------------------

import prisma from "../utils/prisma_client.util.js";
import { sendPushNotificationToUser } from "../services/notification.service.js";
import {
  extendSos,
  resolveSos,
  createScheduledCheckIn,
  zoneFromOffset,
  SOS_MAX_DURATION_MS,
  SOS_TOTAL_CAP_MS,
} from "../services/family.service.js";

const HOUR = 60 * 60 * 1000;
const CIRCLE = "circle-1";
const SENDER_USER = "user-sender";
const SENDER_MEMBER = "member-sender";
const HOST_USER = "user-host";
const HOST_MEMBER = "member-host";
const OTHER_USER = "user-other";
const OTHER_MEMBER = "member-other";

const sosRow = (overrides: Record<string, unknown> = {}) => ({
  id: "sos-1",
  circleId: CIRCLE,
  memberId: SENDER_MEMBER,
  status: "active",
  createdAt: new Date(Date.now() - 10 * 60 * 1000),
  liveUntil: null,
  audienceRestricted: false,
  recipientUserIds: [],
  member: {
    id: SENDER_MEMBER,
    userId: SENDER_USER,
    nickname: "Sam",
    user: { id: SENDER_USER, name: "Sam Sender" },
  },
  ...overrides,
});

const membershipRow = (id: string, userId: string, role: string) => ({
  id,
  userId,
  circleId: CIRCLE,
  role,
  nickname: null,
  circle: { id: CIRCLE },
});

beforeEach(() => {
  vi.clearAllMocks();
  (prisma.familyMember.findMany as any).mockResolvedValue([
    { userId: SENDER_USER },
    { userId: HOST_USER },
    { userId: OTHER_USER },
  ]);
  (prisma.familySosEvent.update as any).mockImplementation(async ({ data }: any) => ({
    ...sosRow(),
    ...data,
    member: { id: SENDER_MEMBER, userId: SENDER_USER, nickname: "Sam" },
    responses: [],
  }));
});

// ---------------------------------------------------------------------------
// extendSos
// ---------------------------------------------------------------------------

describe("extendSos: 4-hour total cap", () => {
  it("exports a 1-hour step and a 4-hour ceiling", () => {
    expect(SOS_MAX_DURATION_MS).toBe(HOUR);
    expect(SOS_TOTAL_CAP_MS).toBe(4 * HOUR);
  });

  it("extends by an hour while the result stays within 4 hours of the start", async () => {
    (prisma.familySosEvent.findUnique as any).mockResolvedValue(
      sosRow({
        createdAt: new Date(Date.now() - 2 * HOUR),
        liveUntil: new Date(Date.now() + 20 * 60 * 1000),
        member: { userId: SENDER_USER },
      }),
    );

    await extendSos(SENDER_USER, "sos-1");

    expect(prisma.familySosEvent.update).toHaveBeenCalledOnce();
    const liveUntil = (prisma.familySosEvent.update as any).mock.calls[0][0].data.liveUntil as Date;
    expect(liveUntil.getTime()).toBeGreaterThan(Date.now() + HOUR - 5000);
  });

  it("refuses with 409 MAX_DURATION when the extension would pass createdAt + 4h", async () => {
    (prisma.familySosEvent.findUnique as any).mockResolvedValue(
      sosRow({
        createdAt: new Date(Date.now() - 3.5 * HOUR),
        liveUntil: new Date(Date.now() + 20 * 60 * 1000),
        member: { userId: SENDER_USER },
      }),
    );

    await expect(extendSos(SENDER_USER, "sos-1")).rejects.toMatchObject({
      statusCode: 409,
      code: "MAX_DURATION",
      message: "SOS can run for 4 hours at most.",
    });
    expect(prisma.familySosEvent.update).not.toHaveBeenCalled();
  });
});

// ---------------------------------------------------------------------------
// resolveSos
// ---------------------------------------------------------------------------

describe("resolveSos: who may end an SOS", () => {
  it("lets the sender end it and says '<Name> ended their SOS.'", async () => {
    (prisma.familySosEvent.findUnique as any).mockResolvedValue(sosRow());
    (prisma.familyMember.findFirst as any).mockResolvedValue(
      membershipRow(SENDER_MEMBER, SENDER_USER, "adult"),
    );

    await resolveSos(SENDER_USER, "sos-1");

    const update = (prisma.familySosEvent.update as any).mock.calls[0][0];
    expect(update.data.endedByMemberId).toBe(SENDER_MEMBER);
    const push = (sendPushNotificationToUser as any).mock.calls[0][0];
    expect(push.title).toBe("SOS ended");
    expect(push.body).toBe("Sam ended their SOS.");
  });

  it("lets the group host end it, records the host and says who ended whose SOS", async () => {
    (prisma.familySosEvent.findUnique as any).mockResolvedValue(sosRow());
    (prisma.familyMember.findFirst as any).mockResolvedValue({
      ...membershipRow(HOST_MEMBER, HOST_USER, "owner"),
      nickname: "Harriet",
    });

    await resolveSos(HOST_USER, "sos-1");

    const update = (prisma.familySosEvent.update as any).mock.calls[0][0];
    expect(update.data.status).toBe("resolved");
    expect(update.data.endedByMemberId).toBe(HOST_MEMBER);
    // Location wiped on end, as always.
    expect(update.data.latitude).toBeNull();
    expect(update.data.longitude).toBeNull();

    const bodies = (sendPushNotificationToUser as any).mock.calls.map((c: any[]) => c[0].body);
    expect(bodies.length).toBeGreaterThan(0);
    for (const body of bodies) {
      expect(body).toBe("Harriet ended Sam's SOS.");
      expect(body.toLowerCase()).not.toContain("safe");
      expect(body.toLowerCase()).not.toContain("resolved");
    }
    // The host is not told about their own action.
    const targets = (sendPushNotificationToUser as any).mock.calls.map((c: any[]) => c[0].userId);
    expect(targets).not.toContain(HOST_USER);
  });

  it("refuses anyone who is neither the sender nor the host (403)", async () => {
    (prisma.familySosEvent.findUnique as any).mockResolvedValue(sosRow());
    (prisma.familyMember.findFirst as any).mockResolvedValue(
      membershipRow(OTHER_MEMBER, OTHER_USER, "adult"),
    );

    await expect(resolveSos(OTHER_USER, "sos-1")).rejects.toMatchObject({ statusCode: 403 });
    expect(prisma.familySosEvent.update).not.toHaveBeenCalled();
  });
});

// ---------------------------------------------------------------------------
// createScheduledCheckIn
// ---------------------------------------------------------------------------

describe("createScheduledCheckIn: timezone or utcOffsetMinutes is required", () => {
  const storedTimezone = (): string =>
    (prisma.familyScheduledCheckIn.upsert as any).mock.calls[0][0].create.timezone;

  beforeEach(() => {
    vi.clearAllMocks();
    (prisma.familyMember.findFirst as any).mockResolvedValue(
      membershipRow(SENDER_MEMBER, SENDER_USER, "adult"),
    );
    (prisma.familyScheduledCheckIn.upsert as any).mockResolvedValue({ id: "sched-1" });
  });

  it("returns 400 when timezone is missing instead of defaulting to Brisbane", async () => {
    await expect(
      createScheduledCheckIn(SENDER_USER, { timeOfDay: "08:00" }),
    ).rejects.toMatchObject({
      statusCode: 400,
      message: expect.stringContaining("timezone is required"),
    });
    expect(prisma.familyScheduledCheckIn.upsert).not.toHaveBeenCalled();
  });

  it("returns 400 for an invalid timezone", async () => {
    await expect(
      createScheduledCheckIn(SENDER_USER, { timeOfDay: "08:00", timezone: "Not/AZone" }),
    ).rejects.toMatchObject({ statusCode: 400 });
  });

  it("stores the schedule when a valid IANA timezone is given", async () => {
    await createScheduledCheckIn(SENDER_USER, { timeOfDay: "08:00", timezone: "Australia/Perth" });
    expect(prisma.familyScheduledCheckIn.upsert).toHaveBeenCalledOnce();
    expect(storedTimezone()).toBe("Australia/Perth");
  });

  it("returns 400 when neither timezone nor utcOffsetMinutes is given", async () => {
    await expect(
      createScheduledCheckIn(SENDER_USER, { timeOfDay: "08:00", utcOffsetMinutes: undefined }),
    ).rejects.toMatchObject({
      statusCode: 400,
      message: expect.stringContaining("timezone is required"),
    });
    expect(prisma.familyScheduledCheckIn.upsert).not.toHaveBeenCalled();
  });

  it("maps a +480 minute offset to Etc/GMT-8 (inverted POSIX sign)", async () => {
    await createScheduledCheckIn(SENDER_USER, { timeOfDay: "08:00", utcOffsetMinutes: 480 });
    expect(storedTimezone()).toBe("Etc/GMT-8");
  });

  it("maps a -300 minute offset to Etc/GMT+5", async () => {
    await createScheduledCheckIn(SENDER_USER, { timeOfDay: "08:00", utcOffsetMinutes: -300 });
    expect(storedTimezone()).toBe("Etc/GMT+5");
  });

  it("maps a 0 minute offset to Etc/GMT", async () => {
    await createScheduledCheckIn(SENDER_USER, { timeOfDay: "08:00", utcOffsetMinutes: 0 });
    expect(storedTimezone()).toBe("Etc/GMT");
  });

  it("maps a +570 minute offset to a zone Intl accepts, else the nearest Etc hour", async () => {
    await createScheduledCheckIn(SENDER_USER, { timeOfDay: "08:00", utcOffsetMinutes: 570 });
    const tz = storedTimezone();
    expect(["+09:30", "Etc/GMT-10"]).toContain(tz);
    expect(() => Intl.DateTimeFormat(undefined, { timeZone: tz })).not.toThrow();
  });

  it("prefers a supplied timezone over the offset", async () => {
    await createScheduledCheckIn(SENDER_USER, {
      timeOfDay: "08:00",
      timezone: "Australia/Perth",
      utcOffsetMinutes: -300,
    });
    expect(storedTimezone()).toBe("Australia/Perth");
  });
});

describe("zoneFromOffset", () => {
  it("returns Etc zones with the inverted sign for whole hours", () => {
    expect(zoneFromOffset(480)).toBe("Etc/GMT-8");
    expect(zoneFromOffset(-300)).toBe("Etc/GMT+5");
    expect(zoneFromOffset(0)).toBe("Etc/GMT");
  });

  it("returns undefined for a missing or out-of-range offset", () => {
    expect(zoneFromOffset(undefined)).toBeUndefined();
    expect(zoneFromOffset(900)).toBeUndefined();
    expect(zoneFromOffset(12.5)).toBeUndefined();
  });
});
