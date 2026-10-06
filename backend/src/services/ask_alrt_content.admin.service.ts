import prisma from "../utils/prisma_client.util.js";
import { HttpError } from "../models/http_error.js";
import { EMERGENCY_NUMBER_DEFAULTS } from "../constants/emergency_number_defaults.js";
import {
  BUILT_IN_IDS,
  ENTRY_ID_RE,
  buildEmergencyRows,
  mergeEntryRows,
  readEmergencyDoc,
  validateEmergencyNumber,
  validateEntryFields,
  type AskAlrtEntryRow,
  type EmergencyNumberRow,
  type SavedEntryDoc,
} from "../utils/ask_alrt_content.util.js";
import { clearAskAlrtCache } from "./ask_alrt.service.js";

/**
 * Admin Portal editing for the two things Ask ALRT reads from the database:
 *
 *   AskAlrtEntry                       the pre-written answer library
 *   AskAlrtConfig key "emergencyNumbers"  { numbers: {ISO: "000"}, names: {ISO: "Name"} }
 *
 * An edit is live straight away (the assistant's cache is cleared on save).
 */
const EMERGENCY_KEY = "emergencyNumbers";

const assertEntryId = (id: string): void => {
  if (!ENTRY_ID_RE.test(id)) {
    throw new HttpError(400, "Id must be 2 to 60 characters: lower case letters, digits and underscores");
  }
};

const fail = (errors: string[]): never => {
  throw new HttpError(400, errors.join(". "));
};

// --- Answer library -----------------------------------------------------

export const listAskAlrtEntries = async (): Promise<AskAlrtEntryRow[]> => {
  const rows = await prisma.askAlrtEntry.findMany();
  const docs: SavedEntryDoc[] = rows.map((r) => ({
    id: r.id,
    data: {
      triggers: r.triggers,
      keywords: r.keywords,
      answer: r.answer,
      enabled: r.enabled,
      updatedAt: r.updatedAt.toISOString(),
      updatedBy: r.updatedBy,
    },
  }));
  return mergeEntryRows(docs);
};

export const getAskAlrtEntry = async (id: string): Promise<AskAlrtEntryRow | null> => {
  const rows = await listAskAlrtEntries();
  return rows.find((r) => r.id === id) ?? null;
};

export const saveAskAlrtEntry = async (
  id: string,
  input: { triggers?: unknown; keywords?: unknown; answer?: unknown; enabled?: unknown },
  adminLabel: string,
): Promise<{ before: AskAlrtEntryRow | null; after: AskAlrtEntryRow }> => {
  assertEntryId(id);
  const checked = validateEntryFields(input);
  if (!checked.ok || !checked.value) return fail(checked.errors);

  const before = await getAskAlrtEntry(id);
  const fields = {
    triggers: checked.value.triggers,
    keywords: checked.value.keywords,
    answer: checked.value.answer,
    enabled: checked.value.enabled,
    updatedBy: adminLabel,
  };
  await prisma.askAlrtEntry.upsert({ where: { id }, create: { id, ...fields }, update: fields });
  clearAskAlrtCache();
  const after = await getAskAlrtEntry(id);
  if (!after) throw new HttpError(500, "Could not read the saved answer back");
  return { before, after };
};

/**
 * Removes the saved row. A custom answer disappears; a built-in answer
 * returns to the app's bundled text. Use enabled=false (a save) to hide a
 * built-in answer instead.
 */
export const deleteAskAlrtEntry = async (id: string): Promise<{ before: AskAlrtEntryRow | null; revertedToBuiltIn: boolean }> => {
  assertEntryId(id);
  const before = await getAskAlrtEntry(id);
  if (!before || before.origin === "built_in") {
    throw new HttpError(404, "Nothing saved for this answer, so there is nothing to remove");
  }
  await prisma.askAlrtEntry.delete({ where: { id } });
  clearAskAlrtCache();
  return { before, revertedToBuiltIn: BUILT_IN_IDS.has(id) };
};

// --- Emergency numbers --------------------------------------------------

type EmergencyDoc = { numbers: Record<string, string>; names: Record<string, string> };

const readEmergency = async (): Promise<EmergencyDoc> => {
  const row = await prisma.askAlrtConfig.findUnique({ where: { key: EMERGENCY_KEY } });
  return readEmergencyDoc(row?.value);
};

const writeEmergency = async (doc: EmergencyDoc, adminLabel: string): Promise<void> => {
  await prisma.askAlrtConfig.upsert({
    where: { key: EMERGENCY_KEY },
    create: { key: EMERGENCY_KEY, value: doc, updatedBy: adminLabel },
    update: { value: doc, updatedBy: adminLabel },
  });
  clearAskAlrtCache();
};

export const listEmergencyNumbers = async (): Promise<EmergencyNumberRow[]> =>
  buildEmergencyRows(EMERGENCY_NUMBER_DEFAULTS, await readEmergency());

export const saveEmergencyNumber = async (
  input: { iso?: unknown; number?: unknown; name?: unknown },
  adminLabel: string,
): Promise<{ before: EmergencyNumberRow | null; after: EmergencyNumberRow }> => {
  const checked = validateEmergencyNumber(input);
  if (!checked.ok || !checked.value) return fail(checked.errors);
  const { iso, number, name } = checked.value;

  const before = (await listEmergencyNumbers()).find((r) => r.iso === iso) ?? null;
  const saved = await readEmergency();
  saved.numbers[iso] = number;
  saved.names[iso] = name;
  await writeEmergency(saved, adminLabel);
  const after = (await listEmergencyNumbers()).find((r) => r.iso === iso);
  if (!after) throw new HttpError(500, "Could not read the saved number back");
  return { before, after };
};

/** Drops a saved edit. A country in the starting list returns to its starting number. */
export const removeEmergencyNumber = async (
  isoInput: string,
  adminLabel: string,
): Promise<{ before: EmergencyNumberRow }> => {
  const iso = isoInput.trim().toUpperCase();
  if (!/^[A-Z]{2}$/.test(iso)) throw new HttpError(400, "Country code must be two letters, for example AU");
  const before = (await listEmergencyNumbers()).find((r) => r.iso === iso);
  if (!before || before.isDefault) {
    throw new HttpError(404, "No saved edit for this country, so there is nothing to remove");
  }
  const saved = await readEmergency();
  delete saved.numbers[iso];
  delete saved.names[iso];
  await writeEmergency(saved, adminLabel);
  return { before };
};

/**
 * Saves every starting-list country that has no saved edit yet. Never
 * overwrites a number an admin already saved.
 */
export const importEmergencyDefaults = async (adminLabel: string): Promise<{ added: number }> => {
  const saved = await readEmergency();
  let added = 0;
  for (const def of EMERGENCY_NUMBER_DEFAULTS) {
    if (saved.numbers[def.iso] !== undefined) continue;
    saved.numbers[def.iso] = def.number;
    saved.names[def.iso] = saved.names[def.iso] ?? def.name;
    added += 1;
  }
  if (added === 0) return { added: 0 };
  await writeEmergency(saved, adminLabel);
  return { added };
};
