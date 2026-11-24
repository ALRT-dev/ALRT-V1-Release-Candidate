import { describe, expect, it } from "vitest";
import { followEvent, isEnded, latestUpdateOf, levelOf } from "../utils/follow_rules.util.js";

describe("server-side Follow (D7)", () => {
  const now = new Date("2026-11-16T10:00:00Z");
  it("pushes once when the agency level changes", () => {
    expect(followEvent("Advice", { title: "Bushfire, Gidgegannup", level: "Watch and Act", ended: false }))
      .toEqual({ kind: "level", title: "Alert updated", body: "Bushfire, Gidgegannup is now Watch and Act.", level: "Watch and Act" });
    expect(followEvent("Watch and Act", { title: "x", level: "watch and act", ended: false })).toEqual({ kind: "none" });
  });
  it("pushes when the alert ends, by expiry or the agency's own words", () => {
    expect(isEnded({ expiresAt: new Date("2026-11-16T09:00:00Z") }, now)).toBe(true);
    expect(isEnded({ nativeWarningLevel: "No longer a threat" }, now)).toBe(true);
    expect(isEnded({ nativeWarningLevel: "Emergency Warning", expiresAt: new Date("2026-11-17") }, now)).toBe(false);
    expect(followEvent("Advice", { title: "Flood", level: "Advice", ended: true }).kind).toBe("ended");
  });
  it("uses only the agency's own level, never ALRT's band", () => {
    expect(levelOf({ nativeWarningLevel: " Advice " })).toBe("Advice");
    expect(levelOf({ nativeWarningLevel: null })).toBeNull();
    expect(followEvent(null, { title: "Crash", level: null, ended: false }).kind).toBe("none");
  });
  it("pushes for every new agency update once followed (owner, 24 Nov 2026)", () => {
    const update = { summary: "Location: Melaleuca → Bullsbrook.", detectedAt: "2026-11-24T08:00:00.000Z" };
    expect(followEvent("Advice", { title: "Bushfire in Melaleuca", level: "Advice", ended: false, update }, ""))
      .toEqual({ kind: "update", title: "Alert updated", body: "Bushfire in Melaleuca: Location: Melaleuca → Bullsbrook.", detectedAt: update.detectedAt });
    // Already told about this update: nothing.
    expect(followEvent("Advice", { title: "x", level: "Advice", ended: false, update }, update.detectedAt).kind).toBe("none");
    // Alerts without an agency level still push on updates.
    expect(followEvent(null, { title: "Crash", level: null, ended: false, update }, "").kind).toBe("update");
  });
  it("gives a row from before update pushes a silent baseline, not a push", () => {
    const update = { summary: "Source text changed.", detectedAt: "2026-11-20T00:00:00.000Z" };
    expect(followEvent("Advice", { title: "x", level: "Advice", ended: false, update }, null).kind).toBe("none");
  });
  it("sends one push, not two, when a level change arrives with its update", () => {
    const update = { summary: "Agency level: Watch and Act.", detectedAt: "2026-11-24T08:00:00.000Z" };
    expect(followEvent("Advice", { title: "Fire", level: "Watch and Act", ended: false, update }, "").kind).toBe("level");
  });
  it("reads only a well-formed latest update", () => {
    expect(latestUpdateOf({ sourceUpdate: { summary: "a", detectedAt: "b" } })).toEqual({ summary: "a", detectedAt: "b" });
    expect(latestUpdateOf({ sourceUpdate: { summary: 1 } })).toBeNull();
    expect(latestUpdateOf(null)).toBeNull();
  });
});
