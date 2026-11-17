/**
 * One-off: load the guidance library on the TEST server and publish it, as the
 * owner asked on 17 Nov 2026. Steps, in order:
 *   1. import the existing stores plus the drafted guides, lines and answers
 *   2. approve the 16/17 Nov 2026 drafts (every approval runs the safety checks)
 *   3. send approved lines to Alert Templates and publish the templates
 *   4. publish each drafted guide to Learn from its approved sections
 *   5. run the daily assurance checks once
 *
 * Refuses to run against production. Run inside the TEST container:
 *   node dist/scripts/apply-guidance-library.js --confirm-test
 */
import prisma from "../utils/prisma_client.util.js";
import { approve, importExisting, publishGuide, sendToAlertTemplates } from "../services/guidance_library.service.js";
import { getTemplateRegistry, saveTemplateRegistry } from "../services/alert_templates.service.js";
import { runAssurance } from "../services/assurance.service.js";
import { DRAFT_GUIDES, NATIONAL_GUIDES } from "../data/guidance_drafts_20261116.js";

const PROD_MARKERS = ["alrt-app-db-dev", "082258816984"];

const main = async () => {
  if (!process.argv.includes("--confirm-test")) throw new Error("Pass --confirm-test to run on the TEST server.");
  const url = process.env.DATABASE_URL ?? "";
  if (PROD_MARKERS.some((m) => url.includes(m))) throw new Error("Refusing to run: this looks like the production database.");

  const admin = await prisma.admin.findFirst({ where: { role: "superAdmin", isActive: true }, orderBy: { createdAt: "asc" } as any });
  if (!admin) throw new Error("No active super admin found.");
  const out: Record<string, unknown> = { admin: admin.email.replace(/^(.).*(@.*)$/, "$1***$2") };

  out.import = await importExisting(admin.id);

  const pending = await (prisma as any).guidanceRecord.findMany({
    where: { status: "in_review", changeNote: { contains: "Nov 2026" } },
    select: { id: true, key: true },
  });
  const failed: { key: string; error: string }[] = [];
  let approved = 0;
  for (const r of pending) {
    try {
      await approve(r.id, admin.id, "Owner instruction 17 Nov 2026: approve drafts on TEST for review");
      approved += 1;
    } catch (e) {
      failed.push({ key: r.key, error: (e as Error).message });
    }
  }
  out.approve = { approved, failed };

  out.templatesDraft = await sendToAlertTemplates(admin.id);
  const registry = await getTemplateRegistry();
  await saveTemplateRegistry({
    revision: registry.revision, action: "publish", adminId: admin.id,
    reason: "Guidance library lines approved 17 Nov 2026 (TEST)",
  });
  out.templatesPublished = (await getTemplateRegistry()).published?.version ?? null;

  const guides: unknown[] = [];
  for (const g of [...DRAFT_GUIDES, ...NATIONAL_GUIDES]) {
    try {
      guides.push(await publishGuide(g.slug, g.jurisdiction, admin.id));
    } catch (e) {
      guides.push({ slug: g.slug, error: (e as Error).message });
    }
  }
  out.guides = guides;

  const report: any = await runAssurance({ trigger: "admin" });
  out.assurance = report?.summary ?? report?.status ?? "ran";

  console.log(JSON.stringify(out, null, 1));
};

main()
  .catch((e) => {
    console.error("FAILED:", (e as Error).message);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
