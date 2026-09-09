/**
 * Alert filter / push matrix - which synthetic alerts the list endpoint
 * returns and which generate a push, under each selection. Real HTTP
 * against a running instance of this backend, real Postgres, Firebase
 * intercepted at `sendEachForMulticast` so nothing leaves this process.
 *
 * The seven alert kinds of the classification standard are created at a
 * unique location with a per-run tag in the title (so the list cache
 * never answers for an earlier run), then GET /api/hazards is called with
 * every selection and the push path is run for a user whose switches
 * mirror that selection. Expected values are asserted, and the resulting
 * table is printed so it can be pasted into the acceptance guide.
 *
 * What the server can and cannot do (stated, not hidden):
 *   - The API's five flags are awsEmergency, awsWatchAndAct, awsAdvice,
 *     officialNonAws, userReported; push has the same five switches.
 *   - Global humanitarian (GDACS) and ALRT Intel (shield source) are
 *     Official (non-AWS) to the server for BOTH listing and push. The
 *     app's two extra filter switches hide them on the phone (feed and
 *     map, build 45); there is no matching push switch (needs schema and
 *     approval). Those two rows therefore assert "Official" behaviour.
 *   - AWS info/unknown levels are shown and pushed under Advice.
 *
 * Run with:
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/verify_alert_filter_matrix.ts
 */

import assert from "node:assert/strict";
import {
  HazardReviewStatus,
  HazardSeverity,
  HazardSeverityBand,
  PrismaClient,
} from "@prisma/client";
import { firebaseAdmin } from "../utils/firebase_admin_client.util.js";

const BASE_URL = process.env.TEST_SERVER_URL || "http://localhost:4123";
const prisma = new PrismaClient();

let passed = 0;
const check = async (label: string, fn: () => Promise<void> | void) => {
  await fn();
  passed += 1;
  console.log(`  ok - ${label}`);
};

type CapturedMessage = { tokens: string[]; data?: Record<string, string> };
const captured: CapturedMessage[] = [];
Object.defineProperty(firebaseAdmin, "messaging", {
  value: () => ({
    sendEachForMulticast: async (message: CapturedMessage) => {
      captured.push(message);
      return { responses: [], successCount: 0, failureCount: 0 } as any;
    },
  }),
  writable: true,
  configurable: true,
});

const api = async (
  path: string,
  opts: { method?: string; token?: string; body?: unknown } = {},
) => {
  const res = await fetch(`${BASE_URL}${path}`, {
    method: opts.method ?? "GET",
    headers: {
      "Content-Type": "application/json",
      ...(opts.token ? { Authorization: `Bearer ${opts.token}` } : {}),
    },
    ...(opts.body !== undefined ? { body: JSON.stringify(opts.body) } : {}),
  });
  let json: unknown = null;
  try {
    json = await res.json();
  } catch {
    // no body
  }
  return { status: res.status, body: json as any };
};

const registerUser = async (label: string) => {
  const email = `filter-matrix-${label}-${crypto.randomUUID().slice(0, 8)}@test.local`;
  const res = await api("/api/auth/email-password/register", {
    method: "POST",
    body: { email, password: "TestPass123!Xx" },
  });
  assert.equal(res.status, 201, `register ${label}: ${JSON.stringify(res.body)}`);
  const token = res.body.accessToken as string;
  const me = await api("/api/user", { token });
  return { token, id: (me.body.data ?? me.body).id as string, label };
};

// A point nobody else's saved location covers.
const LAT = -62.4321;
const LNG = 103.4321;
const BOX = {
  northeastLat: LAT + 0.05,
  northeastLng: LNG + 0.05,
  southwestLat: LAT - 0.05,
  southwestLng: LNG - 0.05,
};

type Flags = {
  awsEmergency: boolean;
  awsWatchAndAct: boolean;
  awsAdvice: boolean;
  officialNonAws: boolean;
  userReported: boolean;
};
const ALL_ON: Flags = {
  awsEmergency: true,
  awsWatchAndAct: true,
  awsAdvice: true,
  officialNonAws: true,
  userReported: true,
};
const SELECTIONS: { name: string; flags: Flags }[] = [
  { name: "all on", flags: ALL_ON },
  { name: "Emergency off", flags: { ...ALL_ON, awsEmergency: false } },
  { name: "Watch & Act off", flags: { ...ALL_ON, awsWatchAndAct: false } },
  { name: "Advice off", flags: { ...ALL_ON, awsAdvice: false } },
  { name: "Official off", flags: { ...ALL_ON, officialNonAws: false } },
  { name: "Community off", flags: { ...ALL_ON, userReported: false } },
  {
    name: "Community only",
    flags: { awsEmergency: false, awsWatchAndAct: false, awsAdvice: false, officialNonAws: false, userReported: true },
  },
];

/** Which flag governs each alert kind, on the server, for list and push alike. */
type Kind = { key: string; label: string; governedBy: keyof Flags };
const KINDS: Kind[] = [
  { key: "awsEmergency", label: "AWS Emergency Warning", governedBy: "awsEmergency" },
  { key: "awsWatchAndAct", label: "AWS Watch & Act", governedBy: "awsWatchAndAct" },
  { key: "awsAdvice", label: "AWS Advice", governedBy: "awsAdvice" },
  { key: "awsInfo", label: "AWS Info level", governedBy: "awsAdvice" },
  { key: "official", label: "Official (state agency)", governedBy: "officialNonAws" },
  { key: "community", label: "Community report", governedBy: "userReported" },
  { key: "gdacs", label: "Global humanitarian (GDACS)", governedBy: "officialNonAws" },
  { key: "intel", label: "ALRT Intel (shield)", governedBy: "officialNonAws" },
];

/**
 * The list query intersects the PostGIS `geom` column. On a database where
 * that column is generated (the TEST migration) Postgres fills it; on a
 * plain column (a local db-push database) it is filled here, the way the
 * ingestion path does. A generated column refuses the update, which is
 * the signal that nothing needs doing.
 */
const fillGeom = async (id: string, lat: number, lng: number) => {
  const [meta] = await prisma.$queryRawUnsafe<{ generation_expression: string | null }[]>(
    `SELECT generation_expression FROM information_schema.columns WHERE table_name = 'Hazard' AND column_name = 'geom'`,
  );
  if (meta?.generation_expression) return;
  await prisma.$executeRawUnsafe(
    `UPDATE "Hazard" SET geom = ST_SetSRID(ST_MakePoint($1, $2), 4326) WHERE id = $3`,
    lng,
    lat,
    id,
  );
};

async function main() {
  console.log("Alert filter / push matrix (real HTTP, real DB, intercepted FCM)\n");

  const { sendPushNotificationAboutNewHazard } = await import("../services/notification.service.js");
  const { getAllMainHazardCategoryIds } = await import("../services/hazard_category.service.js");

  const mainIds = await getAllMainHazardCategoryIds();
  const categoryId = mainIds[0] as string;
  const tag = `filter-matrix-${crypto.randomUUID().slice(0, 8)}`;

  const viewer = await registerUser("viewer");
  const pushUser = await registerUser("push");
  const reporter = await registerUser("reporter");

  const officialSource = await prisma.hazardSource.findFirst({
    where: { id: { notIn: ["gdacsGlobal"] }, shape: { not: "shield" } },
    select: { id: true },
  });
  assert.ok(officialSource, "seed data must include an official source");
  const gdacs = await prisma.hazardSource.findUnique({ where: { id: "gdacsGlobal" }, select: { id: true } });
  assert.ok(gdacs, "seed data must include gdacsGlobal");

  const created = { hazards: [] as string[], sources: [] as string[], devices: [] as string[], subs: [] as string[], rows: [] as string[] };
  const hazardIdByKind = new Map<string, string>();

  try {
    const intelSource = await prisma.hazardSource.create({
      data: { id: `${tag}-intel`, name: `${tag} ALRT Intel`, url: "https://alrt.test/intel", shape: "shield" },
    });
    created.sources.push(intelSource.id);

    const make = async (kind: Kind, data: {
      severity: HazardSeverity; band: HazardSeverityBand; aws: boolean; sourceId?: string; reportedById?: string;
    }) => {
      const h = await prisma.hazard.create({
        data: {
          title: `${tag} ${kind.label}`,
          description: "filter matrix synthetic alert",
          categoryId,
          severity: data.severity,
          severityBand: data.band,
          isAwsCompliant: data.aws,
          sourceId: data.sourceId ?? null,
          reportedById: data.reportedById ?? null,
          reviewStatus: HazardReviewStatus.accepted,
          latitude: LAT,
          longitude: LNG,
        },
      });
      created.hazards.push(h.id);
      hazardIdByKind.set(kind.key, h.id);
      await fillGeom(h.id, LAT, LNG);
      return h;
    };
    const hazards = {
      awsEmergency: await make(KINDS[0]!, { severity: HazardSeverity.emergency, band: HazardSeverityBand.critical, aws: true, sourceId: officialSource.id }),
      awsWatchAndAct: await make(KINDS[1]!, { severity: HazardSeverity.watchAndAct, band: HazardSeverityBand.action, aws: true, sourceId: officialSource.id }),
      awsAdvice: await make(KINDS[2]!, { severity: HazardSeverity.advice, band: HazardSeverityBand.monitor, aws: true, sourceId: officialSource.id }),
      awsInfo: await make(KINDS[3]!, { severity: HazardSeverity.info, band: HazardSeverityBand.info, aws: true, sourceId: officialSource.id }),
      official: await make(KINDS[4]!, { severity: HazardSeverity.advice, band: HazardSeverityBand.monitor, aws: false, sourceId: officialSource.id }),
      community: await make(KINDS[5]!, { severity: HazardSeverity.unknown, band: HazardSeverityBand.info, aws: false, reportedById: reporter.id }),
      gdacs: await make(KINDS[6]!, { severity: HazardSeverity.info, band: HazardSeverityBand.info, aws: false, sourceId: gdacs.id }),
      intel: await make(KINDS[7]!, { severity: HazardSeverity.info, band: HazardSeverityBand.action, aws: false, sourceId: intelSource.id }),
    };

    // Push user: a device and a saved location covering the point.
    const token = `fake-fcm-${tag}`;
    created.devices.push((await prisma.userDevice.create({ data: { userId: pushUser.id, deviceToken: token, platform: "android" } })).id);
    created.subs.push((await prisma.locationSubscription.create({ data: { userId: pushUser.id, name: tag, ...BOX } })).id);

    const listUnder = async (flags: Flags) => {
      const q = new URLSearchParams({
        searchString: tag,
        northeastLat: String(BOX.northeastLat),
        northeastLng: String(BOX.northeastLng),
        southwestLat: String(BOX.southwestLat),
        southwestLng: String(BOX.southwestLng),
        pageSize: "100",
        ...Object.fromEntries(Object.entries(flags).map(([k, v]) => [k, String(v)])),
      });
      const res = await api(`/api/hazards?${q.toString()}`, { token: viewer.token });
      assert.equal(res.status, 200, JSON.stringify(res.body));
      const list: any[] = Array.isArray(res.body) ? res.body : (res.body.data ?? res.body.hazards ?? []);
      return new Set(list.map((h) => h.id as string));
    };
    const pushUnder = async (flags: Flags) => {
      const put = await api("/api/user/push-notification-settings", {
        method: "PUT",
        token: pushUser.token,
        body: { ...flags, subscribedCategoryIds: mainIds },
      });
      assert.equal(put.status, 200, JSON.stringify(put.body));
      const pushed = new Set<string>();
      for (const [key, hazard] of Object.entries(hazards)) {
        captured.length = 0;
        await sendPushNotificationAboutNewHazard(hazard);
        if (captured.some((m) => m.tokens.includes(token))) pushed.add(key);
      }
      return pushed;
    };
    created.rows.push(...(await prisma.userPushNotificationSetting.findMany({ where: { userId: pushUser.id }, select: { id: true } })).map((r) => r.id));

    const rows: string[] = [];
    rows.push(`| Alert kind | ${SELECTIONS.map((s) => s.name).join(" | ")} |`);
    rows.push(`|---|${SELECTIONS.map(() => "---").join("|")}|`);
    const cells = new Map<string, string[]>();
    for (const kind of KINDS) cells.set(kind.key, []);

    for (const selection of SELECTIONS) {
      const shown = await listUnder(selection.flags);
      const pushed = await pushUnder(selection.flags);
      for (const kind of KINDS) {
        const id = hazardIdByKind.get(kind.key)!;
        const expected = selection.flags[kind.governedBy];
        const isShown = shown.has(id);
        const isPushed = pushed.has(kind.key);
        cells.get(kind.key)!.push(`${isShown ? "shown" : "hidden"} / ${isPushed ? "push" : "no push"}`);
        await check(`${selection.name}: ${kind.label} is ${expected ? "shown and pushed" : "hidden and not pushed"}`, () => {
          assert.equal(isShown, expected, `list under ${selection.name}`);
          assert.equal(isPushed, expected, `push under ${selection.name}`);
        });
      }
    }
    for (const kind of KINDS) rows.push(`| ${kind.label} | ${cells.get(kind.key)!.join(" | ")} |`);

    console.log("\nServer matrix (list / push) for a user whose saved location covers the alert:\n");
    for (const r of rows) console.log(r);
    console.log(
      "\nApp-side only (not a server switch): the Global humanitarian and ALRT Intel filter switches hide those two rows on the map and in the feed; the push switch for them is Official.",
    );
  } finally {
    const rowIds = (await prisma.userPushNotificationSetting.findMany({ where: { userId: pushUser.id }, select: { id: true } })).map((r) => r.id);
    await prisma.hazard.deleteMany({ where: { id: { in: created.hazards } } });
    await prisma.hazardSource.deleteMany({ where: { id: { in: created.sources } } });
    await prisma.locationSubscription.deleteMany({ where: { id: { in: created.subs } } });
    await prisma.userDevice.deleteMany({ where: { id: { in: created.devices } } });
    await prisma.userPushNotificationSetting.deleteMany({ where: { id: { in: rowIds } } });
  }

  console.log(`\n${passed} checks passed.`);
}

main()
  .catch((error) => {
    console.error("\nFAILED:", error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
