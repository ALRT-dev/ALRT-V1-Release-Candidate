/**
 * Unit check of the Admin Portal rules for Ask ALRT answers and emergency
 * numbers. No server, no Firebase:
 *   `npx tsx src/scripts/verify_ask_alrt_admin_content.ts`
 */
import assert from "node:assert/strict";
import {
  BUILT_IN_ENTRIES,
  buildEmergencyRows,
  mergeEntryRows,
  readEmergencyDoc,
  validateEmergencyNumber,
  validateEntryFields,
} from "../utils/ask_alrt_content.util.js";
import { EMERGENCY_NUMBER_DEFAULTS } from "../constants/emergency_number_defaults.js";

const good = {
  triggers: ["how do i send an sos"],
  keywords: ["sos"],
  answer: "Open the SOS screen and hold the button for 3 seconds to send it.",
};

const cases: [string, () => void][] = [
  ["every built-in answer passes the locked copy rules", () => {
    for (const e of BUILT_IN_ENTRIES) {
      const r = validateEntryFields({ triggers: e.triggers, keywords: e.keywords, answer: e.answer });
      assert.equal(r.ok, true, `${e.id}: ${r.errors.join("; ")}`);
    }
  }],
  ["a valid answer is accepted and defaults to enabled", () => {
    const r = validateEntryFields(good);
    assert.equal(r.ok, true);
    assert.equal(r.value?.enabled, true);
  }],
  ["trims, collapses spaces and drops duplicate and blank phrases", () => {
    const r = validateEntryFields({ ...good, triggers: ["  a   b ", "a b", "", "  "], keywords: [] });
    assert.deepEqual(r.value?.triggers, ["a b"]);
  }],
  ["needs at least one trigger or keyword", () => {
    assert.equal(validateEntryFields({ ...good, triggers: [], keywords: [] }).ok, false);
    assert.equal(validateEntryFields({ ...good, triggers: [], keywords: ["sos"] }).ok, true);
  }],
  ["rejects en and em dashes", () => {
    assert.equal(validateEntryFields({ ...good, answer: good.answer + " – done" }).ok, false);
    assert.equal(validateEntryFields({ ...good, answer: good.answer + " — done" }).ok, false);
  }],
  ["rejects phone numbers but allows the short emergency numbers", () => {
    assert.equal(validateEntryFields({ ...good, answer: "Call 0412 345 678 for help with this." }).ok, false);
    assert.equal(validateEntryFields({ ...good, answer: "Call +61 8 9000 1234 for help with this." }).ok, false);
    assert.equal(validateEntryFields({ ...good, answer: "In Australia the emergency number is 000, in the US 911." }).ok, true);
  }],
  ["answer length limits", () => {
    assert.equal(validateEntryFields({ ...good, answer: "too short" }).ok, false);
    assert.equal(validateEntryFields({ ...good, answer: "x".repeat(1201) }).ok, false);
  }],
  ["merge: built-ins with no saved doc are 'built_in'", () => {
    const rows = mergeEntryRows([]);
    assert.equal(rows.length, BUILT_IN_ENTRIES.length);
    assert.ok(rows.every((r) => r.origin === "built_in" && r.hasBuiltIn));
  }],
  ["merge: a saved doc with a built-in id is 'customised' and wins", () => {
    const rows = mergeEntryRows([{ id: "send_sos", data: { triggers: ["x y"], keywords: [], answer: "New text for the SOS answer.", enabled: true } }]);
    const row = rows.find((r) => r.id === "send_sos");
    assert.equal(row?.origin, "customised");
    assert.equal(row?.answer, "New text for the SOS answer.");
  }],
  ["merge: a saved doc with a new id is 'custom'; enabled:false is kept", () => {
    const rows = mergeEntryRows([{ id: "my_new_one", data: { triggers: ["t t"], keywords: [], answer: "Some custom answer text here.", enabled: false } }]);
    const row = rows.find((r) => r.id === "my_new_one");
    assert.equal(row?.origin, "custom");
    assert.equal(row?.hasBuiltIn, false);
    assert.equal(row?.enabled, false);
  }],
  ["emergency number: valid input is normalised", () => {
    const r = validateEmergencyNumber({ iso: " jp ", number: " 110 ", name: " Japan " });
    assert.deepEqual(r.value, { iso: "JP", number: "110", name: "Japan" });
  }],
  ["emergency number: rejects bad code, symbols, long numbers, blank name", () => {
    assert.equal(validateEmergencyNumber({ iso: "JPN", number: "110", name: "Japan" }).ok, false);
    assert.equal(validateEmergencyNumber({ iso: "JP", number: "1-1-0", name: "Japan" }).ok, false);
    assert.equal(validateEmergencyNumber({ iso: "JP", number: "1", name: "Japan" }).ok, false);
    assert.equal(validateEmergencyNumber({ iso: "JP", number: "1234567", name: "Japan" }).ok, false);
    assert.equal(validateEmergencyNumber({ iso: "JP", number: "110", name: " " }).ok, false);
  }],
  ["emergency rows: starting list shows as default, a saved edit wins", () => {
    const saved = readEmergencyDoc({ numbers: { NZ: "112", XX: "123" }, names: { NZ: "New Zealand" } });
    const rows = buildEmergencyRows(EMERGENCY_NUMBER_DEFAULTS, saved);
    const nz = rows.find((r) => r.iso === "NZ");
    assert.equal(nz?.number, "112");
    assert.equal(nz?.isDefault, false);
    assert.equal(nz?.defaultNumber, "111");
    const au = rows.find((r) => r.iso === "AU");
    assert.equal(au?.number, "000");
    assert.equal(au?.isDefault, true);
    assert.equal(rows.find((r) => r.iso === "XX")?.number, "123");
  }],
  ["emergency doc: bad rows are dropped", () => {
    const d = readEmergencyDoc({ numbers: { jp: "110", USA: "911", GB: 999, FR: "1-12" }, names: { jp: "Japan", FR: "" } });
    assert.deepEqual(d.numbers, { JP: "110" });
    assert.deepEqual(d.names, { JP: "Japan" });
  }],
  ["starting list has unique two-letter codes and digit-only numbers", () => {
    const seen = new Set<string>();
    for (const d of EMERGENCY_NUMBER_DEFAULTS) {
      assert.match(d.iso, /^[A-Z]{2}$/);
      assert.match(d.number, /^[0-9]{2,6}$/);
      assert.ok(!seen.has(d.iso), `duplicate ${d.iso}`);
      seen.add(d.iso);
    }
  }],
];

let failed = 0;
for (const [label, fn] of cases) {
  try {
    fn();
    console.log(`  ok - ${label}`);
  } catch (error) {
    failed += 1;
    console.log(`  FAIL - ${label}: ${(error as Error).message}`);
  }
}
console.log(`\n${cases.length - failed} passed, ${failed} failed`);
process.exit(failed ? 1 : 0);
