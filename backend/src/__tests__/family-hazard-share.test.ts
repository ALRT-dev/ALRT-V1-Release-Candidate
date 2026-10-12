/**
 * "Send to my group" (family.service shareHazardWithCircle):
 *
 *  - a user who is not a member of the named circle gets 403;
 *  - an alert that does not exist, or is not visible (accepted or from an
 *    official source), gets 404 and nothing is pushed;
 *  - on success every OTHER member of the circle is pushed (never the
 *    sender), with the sender's name in the title and the alert title in
 *    the body, and `sent` is the recipient count;
 *  - the optional note rides on a second line of the body;
 *  - the payload never carries coordinates, and nothing is written.
 */
import { describe, it, expect, vi, beforeEach } from "vitest";

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

vi.mock("@prisma/client", () => ({}));

vi.mock("../utils/prisma_client.util.js", () => ({
  default: {
    familyMember: {
      findFirst: vi.fn(),
      findMany: vi.fn(),
      findUnique: vi.fn(),
    },
    hazard: {
      findFirst: vi.fn(),
    },
    familyCheckIn: {
      create: vi.fn(),
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
import { sendSocketEventToUsers } from "../services/socket.service.js";
import { shareHazardWithCircle } from "../services/family.service.js";
import { PushNotificationType } from "../models/push_notification_types.js";
import { SocketEvent } from "../models/socket_event_types.js";

const CIRCLE = "circle-1";
const HAZARD = "hazard-1";
const SENDER_USER = "user-sender";
const SENDER_MEMBER = "member-sender";
const OTHER_USER_A = "user-a";
const OTHER_USER_B = "user-b";

const membershipRow = () => ({
  id: SENDER_MEMBER,
  userId: SENDER_USER,
  circleId: CIRCLE,
  role: "member",
  nickname: null,
  circle: { id: CIRCLE },
});

const senderIdentity = () => ({
  id: SENDER_MEMBER,
  userId: SENDER_USER,
  circleId: CIRCLE,
  nickname: "Sam",
  photoUrl: null,
  colorHex: null,
  role: "member",
  sharingLevel: "precise",
  user: { id: SENDER_USER, name: "Sam Sender", profilePictureUrl: null },
});

const pushMock = sendPushNotificationToUser as unknown as ReturnType<typeof vi.fn>;
const socketMock = sendSocketEventToUsers as unknown as ReturnType<typeof vi.fn>;

beforeEach(() => {
  vi.clearAllMocks();
  (prisma.familyMember.findFirst as any).mockResolvedValue(membershipRow());
  (prisma.familyMember.findUnique as any).mockResolvedValue(senderIdentity());
  // getCircleUserIds is called with the sender excluded; the mock returns
  // what the real query would: only the other members.
  (prisma.familyMember.findMany as any).mockResolvedValue([
    { userId: OTHER_USER_A },
    { userId: OTHER_USER_B },
  ]);
  (prisma.hazard.findFirst as any).mockResolvedValue({
    id: HAZARD,
    title: "Bushfire Watch and Act",
  });
});

describe("shareHazardWithCircle", () => {
  it("refuses a non-member with 403 and pushes nothing", async () => {
    (prisma.familyMember.findFirst as any).mockResolvedValue(null);

    await expect(
      shareHazardWithCircle(SENDER_USER, HAZARD, { circleId: "not-mine" }),
    ).rejects.toMatchObject({ statusCode: 403 });

    expect(prisma.hazard.findFirst).not.toHaveBeenCalled();
    expect(pushMock).not.toHaveBeenCalled();
    expect(socketMock).not.toHaveBeenCalled();
  });

  it("refuses an unknown or non-visible alert with 404 and pushes nothing", async () => {
    (prisma.hazard.findFirst as any).mockResolvedValue(null);

    await expect(
      shareHazardWithCircle(SENDER_USER, "missing", { circleId: CIRCLE }),
    ).rejects.toMatchObject({ statusCode: 404 });

    // Only accepted or official (sourceId set) alerts are looked up.
    const where = (prisma.hazard.findFirst as any).mock.calls[0][0].where;
    expect(where.id).toBe("missing");
    expect(where.OR).toEqual(
      expect.arrayContaining([
        { reviewStatus: "accepted" },
        { sourceId: { not: null } },
      ]),
    );
    expect(pushMock).not.toHaveBeenCalled();
    expect(socketMock).not.toHaveBeenCalled();
  });

  it("pushes to every other member, never the sender, and reports the count", async () => {
    const result = await shareHazardWithCircle(SENDER_USER, HAZARD, {
      circleId: CIRCLE,
    });

    expect(result).toEqual({ sent: 2 });

    // Recipients are selected like a check-in's: the circle minus the sender.
    const memberQuery = (prisma.familyMember.findMany as any).mock.calls[0][0];
    expect(memberQuery.where.circleId).toBe(CIRCLE);
    expect(memberQuery.where.id.notIn).toEqual([SENDER_MEMBER]);

    expect(pushMock).toHaveBeenCalledTimes(2);
    const pushedTo = pushMock.mock.calls.map((c: any[]) => c[0].userId).sort();
    expect(pushedTo).toEqual([OTHER_USER_A, OTHER_USER_B]);
    expect(pushedTo).not.toContain(SENDER_USER);

    for (const call of pushMock.mock.calls) {
      const args = call[0];
      expect(args.title).toBe("Sam sent you an alert");
      expect(args.body).toBe("Bushfire Watch and Act");
      expect(args.type).toBe(PushNotificationType.familyHazardShare);
      expect(args.data).toEqual({
        notificationType: "familyHazardShare",
        hazardId: HAZARD,
        circleId: CIRCLE,
      });
      // Never a location.
      expect(JSON.stringify(args)).not.toMatch(/latitude|longitude/);
    }

    // Matching socket event to the same people only.
    expect(socketMock).toHaveBeenCalledTimes(1);
    const socketArgs = socketMock.mock.calls[0]![0];
    expect(socketArgs.event).toBe(SocketEvent.familyHazardShare);
    expect([...socketArgs.userIds].sort()).toEqual([OTHER_USER_A, OTHER_USER_B]);
    expect(socketArgs.data.hazardId).toBe(HAZARD);
    expect(JSON.stringify(socketArgs)).not.toMatch(/latitude|longitude/);

    // Nothing is recorded: a share is not a check-in.
    expect(prisma.familyCheckIn.create).not.toHaveBeenCalled();
  });

  it("puts the note on a second line of the body when present", async () => {
    await shareHazardWithCircle(SENDER_USER, HAZARD, {
      circleId: CIRCLE,
      message: "  Heading home now, check the road closures  ",
    });

    expect(pushMock).toHaveBeenCalledTimes(2);
    for (const call of pushMock.mock.calls) {
      expect(call[0].body).toBe(
        "Bushfire Watch and Act\nHeading home now, check the road closures",
      );
    }
    expect(socketMock.mock.calls[0]![0].data.message).toBe(
      "Heading home now, check the road closures",
    );
  });

  it("returns sent: 0 and pushes nothing when the sender is alone", async () => {
    (prisma.familyMember.findMany as any).mockResolvedValue([]);

    const result = await shareHazardWithCircle(SENDER_USER, HAZARD, {
      circleId: CIRCLE,
    });

    expect(result).toEqual({ sent: 0 });
    expect(pushMock).not.toHaveBeenCalled();
    expect(socketMock).not.toHaveBeenCalled();
  });
});
