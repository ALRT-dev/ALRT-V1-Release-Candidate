import { createHmac } from "node:crypto";
import prisma from "../utils/prisma_client.util.js";
import { config } from "../utils/config.js";

/** Keyed one-way hash of a normalised email. It cannot be turned back into the address. */
const hashEmail = (email: string) =>
  createHmac("sha256", config.trialLedgerSecret || config.jwt.accessSecret)
    .update(email.trim().toLowerCase())
    .digest("hex");

/** Remembers that this person's email has started a free trial. Never throws. */
export const recordTrialStart = async (userId: string): Promise<void> => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { email: true },
    });
    if (!user?.email) return;
    const emailHash = hashEmail(user.email);
    await prisma.trialRecord.upsert({
      where: { emailHash },
      create: { emailHash },
      update: {},
    });
  } catch (error) {
    console.error("Trial record failed:", error);
  }
};

/** True when this person's email has not started a trial before. */
export const isTrialEligible = async (userId: string): Promise<boolean> => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { email: true },
    });
    if (!user?.email) return true;
    const found = await prisma.trialRecord.findUnique({
      where: { emailHash: hashEmail(user.email) },
      select: { id: true },
    });
    return !found;
  } catch (error) {
    console.error("Trial eligibility check failed:", error);
    return true;
  }
};
