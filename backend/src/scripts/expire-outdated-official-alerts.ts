#!/usr/bin/env tsx
/**
 * One-off clean-up for alerts already stored (owner, 17 November 2026).
 *
 * New ingestion runs apply the agency-time rule (utils/alert_currency.util.ts)
 * as each alert is read. This applies the same rule once to every official
 * alert that is visible now, so an old item such as the March 2026 DBCA park
 * closure goes straight away instead of waiting for its feed to list it again.
 *
 * Dry run by default: it lists what it would remove and changes nothing.
 *   dotenv -e .env.dev -- tsx src/scripts/expire-outdated-official-alerts.ts
 *   dotenv -e .env.dev -- tsx src/scripts/expire-outdated-official-alerts.ts --apply
 *
 * --apply only sets expiresAt (to the time the alert went stale). Nothing is
 * deleted, and community reports are never touched.
 */
import prisma from "../utils/prisma_client.util.js";
import { alertCurrency } from "../utils/alert_currency.util.js";

const apply = process.argv.includes("--apply");
const now = new Date();

const visible = await prisma.hazard.findMany({
  where: {
    reportedById: null,
    sourceId: { not: null },
    OR: [{ expiresAt: null }, { expiresAt: { gt: now } }],
  },
  select: {
    id: true, title: true, description: true, nativeWarningLevel: true,
    sourceId: true, occurredAt: true, createdAt: true, contentDetails: true,
  },
});

let stale = 0;
for (const hazard of visible) {
  // The stored record is both "existing" and the current words, so the clock
  // is the agency's stated time, the recorded last change, or first sighting.
  const currency = alertCurrency({
    title: hazard.title ?? "",
    description: hazard.description ?? "",
    nativeLevel: hazard.nativeWarningLevel ?? null,
    sourceId: hazard.sourceId,
    occurredAt: hazard.occurredAt,
    existing: {
      title: hazard.title, description: hazard.description,
      nativeWarningLevel: hazard.nativeWarningLevel ?? null,
      createdAt: hazard.createdAt, contentDetails: hazard.contentDetails,
    },
    now,
  });
  if (currency.staleAt.getTime() > now.getTime()) continue;
  stale += 1;
  console.log(
    `${apply ? "Removing" : "Would remove"} [${hazard.sourceId}] last agency change ${currency.changedAt.toISOString()}: ${hazard.title}`,
  );
  if (apply) {
    await prisma.hazard.update({ where: { id: hazard.id }, data: { expiresAt: currency.staleAt } });
  }
}

console.log(`${visible.length} official alerts visible; ${stale} outdated${apply ? " and removed" : " (dry run, nothing changed)"}.`);
await prisma.$disconnect();
