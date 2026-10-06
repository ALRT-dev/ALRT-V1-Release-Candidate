/**
 * Read-only report of legacy guest records (V1 retires guests; master
 * spec §5). It changes NOTHING: no conversion, no permission change. Run
 * it against a database you are allowed to read, and use the output to
 * decide per group what should happen to each guest.
 *
 *   DATABASE_URL=... npx tsx src/scripts/inspect_guest_members.ts
 *   DATABASE_URL=... npx tsx src/scripts/inspect_guest_members.ts --json
 *
 * Output has no emails, phone numbers or locations: counts, group ids,
 * roles, dates and whether each guest has used the app recently.
 */
import { PrismaClient } from "@prisma/client";

// Its own client so it needs only DATABASE_URL, never the app's secrets.
const prisma = new PrismaClient();

const DAY = 24 * 60 * 60 * 1000;

const main = async () => {
  const asJson = process.argv.includes("--json");
  const now = Date.now();

  const guests = await prisma.familyMember.findMany({
    where: { role: "guest" },
    select: {
      id: true,
      userId: true,
      circleId: true,
      createdAt: true,
      lastCheckInAt: true,
      circle: {
        select: {
          fundingMode: true,
          _count: { select: { members: true } },
          members: { where: { role: "owner" }, select: { userId: true } },
        },
      },
    },
    orderBy: { createdAt: "asc" },
  });

  const openGuestCodes = await prisma.familyInvite.count({
    where: { isGuestInvite: true, isRevoked: false },
  });

  const rows = [];
  for (const g of guests) {
    const otherRoles = await prisma.familyMember.findMany({
      where: { userId: g.userId, id: { not: g.id } },
      select: { role: true },
    });
    const user = await prisma.user.findUnique({
      where: { id: g.userId },
      select: { updatedAt: true },
    });
    rows.push({
      memberId: g.id,
      circleId: g.circleId,
      joined: g.createdAt.toISOString().slice(0, 10),
      lastCheckIn: g.lastCheckInAt?.toISOString().slice(0, 10) ?? null,
      activeLast90Days: Boolean(
        (g.lastCheckInAt && now - g.lastCheckInAt.getTime() < 90 * DAY) ||
          (user?.updatedAt && now - user.updatedAt.getTime() < 90 * DAY),
      ),
      alsoMemberElsewhereAs: otherRoles.map((r) => r.role),
      groupFunding: g.circle.fundingMode,
      groupPeople: g.circle._count.members,
      groupHasHost: g.circle.members.length > 0,
    });
  }

  const byCircle = new Map<string, number>();
  for (const r of rows) byCircle.set(r.circleId, (byCircle.get(r.circleId) ?? 0) + 1);

  const summary = {
    generatedAt: new Date().toISOString(),
    guestRows: rows.length,
    distinctGuestUsers: new Set(guests.map((g) => g.userId)).size,
    groupsWithGuests: byCircle.size,
    activeLast90Days: rows.filter((r) => r.activeLast90Days).length,
    inSponsoredGroups: rows.filter((r) => r.groupFunding === "sponsored").length,
    inGroupsWithoutHost: rows.filter((r) => !r.groupHasHost).length,
    openGuestInviteCodes: openGuestCodes,
  };

  if (asJson) {
    console.log(JSON.stringify({ summary, rows }, null, 2));
  } else {
    console.log("Legacy guest records (read-only, nothing changed)");
    for (const [k, v] of Object.entries(summary)) console.log(`  ${k}: ${v}`);
    if (rows.length > 0) console.table(rows);
  }
};

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
