/**
 * Seeds the default severity label configuration into the database.
 * Safe to run multiple times (upsert). Run once after deploying this migration.
 *
 *   NODE_ENV=test npx dotenv -e .env.test -- npx tsx src/scripts/seed_severity_labels_config.ts
 */
import { PrismaClient, ConfigurationKey } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  const value = {
    emergency: "Emergency Warning",
    watchAndAct: "Watch and Act",
    advice: "Advice",
    default: "Alert",
  };
  await prisma.configuration.upsert({
    where: { key: ConfigurationKey.severityLabels },
    update: { value, updatedAt: new Date() },
    create: {
      key: ConfigurationKey.severityLabels,
      title: "Severity Labels",
      description:
        "The words shown next to each severity band. Changing these updates all alert displays immediately — no rebuild needed.",
      value,
    },
  });
  console.log("Severity labels config seeded:", value);
}

main().catch(console.error).finally(() => prisma.$disconnect());
