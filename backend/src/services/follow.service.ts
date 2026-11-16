import prisma from "../utils/prisma_client.util.js";
import { HttpError } from "../models/http_error.js";
import { followEvent, isEnded, levelOf } from "../utils/follow_rules.util.js";
import { sendPushNotificationToUser } from "./notification.service.js";
import { PushNotificationType } from "../models/push_notification_types.js";

const db = prisma as any;
const MAX_FOLLOWS = 50;

export const followHazard = async (userId: string, hazardId: string) => {
  const hazard = await prisma.hazard.findUnique({ where: { id: hazardId }, select: { id: true, nativeWarningLevel: true } });
  if (!hazard) throw new HttpError(404, "Alert not found.");
  const count = await db.hazardFollow.count({ where: { userId } });
  if (count >= MAX_FOLLOWS) throw new HttpError(409, `You can follow up to ${MAX_FOLLOWS} alerts.`);
  await db.hazardFollow.upsert({
    where: { userId_hazardId: { userId, hazardId } },
    create: { userId, hazardId, lastLevel: levelOf(hazard) },
    update: {},
  });
  return { following: true };
};

export const unfollowHazard = async (userId: string, hazardId: string) => {
  await db.hazardFollow.deleteMany({ where: { userId, hazardId } });
  return { following: false };
};

export const listFollows = async (userId: string) =>
  (await db.hazardFollow.findMany({ where: { userId }, select: { hazardId: true, createdAt: true } })) as { hazardId: string; createdAt: Date }[];

/** Every 5 minutes: push followers when a level changes or an alert ends. */
export const notifyFollowers = async (now = new Date()) => {
  const follows: { userId: string; hazardId: string; lastLevel: string | null }[] = await db.hazardFollow.findMany({ take: 5000 });
  if (!follows.length) return { sent: 0 };
  const ids = [...new Set(follows.map((f) => f.hazardId))];
  const hazards = await prisma.hazard.findMany({
    where: { id: { in: ids } },
    select: { id: true, title: true, nativeWarningLevel: true, expiresAt: true },
  });
  const byId = new Map(hazards.map((h) => [h.id, h]));
  let sent = 0;
  for (const f of follows) {
    const h = byId.get(f.hazardId);
    const ended = !h || isEnded(h, now);
    const event = followEvent(f.lastLevel, { title: h?.title ?? "A followed alert", level: h ? levelOf(h) : null, ended });
    if (event.kind === "none") continue;
    await sendPushNotificationToUser({
      userId: f.userId, title: event.title, body: event.body,
      data: { hazardId: f.hazardId }, type: PushNotificationType.viewHazard, collapseKey: `follow-${f.hazardId}`,
    });
    sent += 1;
    if (event.kind === "ended") await db.hazardFollow.deleteMany({ where: { userId: f.userId, hazardId: f.hazardId } });
    else await db.hazardFollow.update({ where: { userId_hazardId: { userId: f.userId, hazardId: f.hazardId } }, data: { lastLevel: event.level } });
  }
  return { sent };
};
