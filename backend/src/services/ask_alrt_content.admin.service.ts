import { firebaseAdmin } from "../utils/firebase_admin_client.util.js";
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
  type FirestoreEntryDoc,
} from "../utils/ask_alrt_content.util.js";

/**
 * Admin Portal editing for the two things the Ask ALRT Cloud Function reads
 * from Firestore (ALRT-dev/askalrt, unchanged contract):
 *
 *   askAlrtEntries/{id}                  the pre-written answer library
 *   askAlrtConfig/emergencyNumbers       { numbers: {ISO: "000"}, names: {ISO: "Name"} }
 *
 * Both are server-only for clients (askalrt/firestore.rules); this service
 * writes through the Admin SDK. The function caches each for 5 minutes, so an
 * edit is live within about 5 minutes with no release.
 */
const ENTRIES = "askAlrtEntries";
const CONFIG = "askAlrtConfig";
const EMERGENCY_DOC = "emergencyNumbers";

const db = () => firebaseAdmin.firestore();

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
  const snap = await db().collection(ENTRIES).get();
  const docs: FirestoreEntryDoc[] = snap.docs.map((d) => ({ id: d.id, data: d.data() }));
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
  await db()
    .collection(ENTRIES)
    .doc(id)
    .set({
      triggers: checked.value.triggers,
      keywords: checked.value.keywords,
      answer: checked.value.answer,
      enabled: checked.value.enabled,
      updatedAt: new Date().toISOString(),
      updatedBy: adminLabel,
    });
  const after = await getAskAlrtEntry(id);
  if (!after) throw new HttpError(500, "Could not read the saved answer back");
  return { before, after };
};

/**
 * Removes the Firestore doc. A custom answer disappears; a built-in answer
 * returns to the app's bundled text. Use enabled=false (a save) to hide a
 * built-in answer instead.
 */
export const deleteAskAlrtEntry = async (id: string): Promise<{ before: AskAlrtEntryRow | null; revertedToBuiltIn: boolean }> => {
  assertEntryId(id);
  const before = await getAskAlrtEntry(id);
  if (!before || before.origin === "built_in") {
    throw new HttpError(404, "Nothing saved for this answer, so there is nothing to remove");
  }
  await db().collection(ENTRIES).doc(id).delete();
  return { before, revertedToBuiltIn: BUILT_IN_IDS.has(id) };
};

// --- Emergency numbers --------------------------------------------------

const emergencyRef = () => db().collection(CONFIG).doc(EMERGENCY_DOC);

export const listEmergencyNumbers = async (): Promise<EmergencyNumberRow[]> => {
  const snap = await emergencyRef().get();
  const saved = readEmergencyDoc(snap.exists ? snap.data() : undefined);
  return buildEmergencyRows(EMERGENCY_NUMBER_DEFAULTS, saved);
};

export const saveEmergencyNumber = async (
  input: { iso?: unknown; number?: unknown; name?: unknown },
  adminLabel: string,
): Promise<{ before: EmergencyNumberRow | null; after: EmergencyNumberRow }> => {
  const checked = validateEmergencyNumber(input);
  if (!checked.ok || !checked.value) return fail(checked.errors);
  const { iso, number, name } = checked.value;

  const beforeRows = await listEmergencyNumbers();
  const before = beforeRows.find((r) => r.iso === iso) ?? null;

  await emergencyRef().set(
    {
      numbers: { [iso]: number },
      names: { [iso]: name },
      updatedAt: new Date().toISOString(),
      updatedBy: adminLabel,
    },
    { merge: true },
  );
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
  const remove = firebaseAdmin.firestore.FieldValue.delete();
  await emergencyRef().set(
    {
      numbers: { [iso]: remove },
      names: { [iso]: remove },
      updatedAt: new Date().toISOString(),
      updatedBy: adminLabel,
    },
    { merge: true },
  );
  return { before };
};

/**
 * Saves every starting-list country that has no saved edit yet, so the Ask
 * ALRT assistant (which ships only eight countries) knows all of them. Never
 * overwrites a number an admin already saved.
 */
export const importEmergencyDefaults = async (adminLabel: string): Promise<{ added: number }> => {
  const snap = await emergencyRef().get();
  const saved = readEmergencyDoc(snap.exists ? snap.data() : undefined);
  const numbers: Record<string, string> = {};
  const names: Record<string, string> = {};
  for (const def of EMERGENCY_NUMBER_DEFAULTS) {
    if (saved.numbers[def.iso] !== undefined) continue;
    numbers[def.iso] = def.number;
    names[def.iso] = saved.names[def.iso] ?? def.name;
  }
  const added = Object.keys(numbers).length;
  if (added === 0) return { added: 0 };
  await emergencyRef().set(
    { numbers, names, updatedAt: new Date().toISOString(), updatedBy: adminLabel },
    { merge: true },
  );
  return { added };
};
