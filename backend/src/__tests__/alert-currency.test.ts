import { describe, expect, it } from "vitest";
import { alertCurrency, boundedExpiry, guardNonWarningCategory, statedIssueTime } from "../utils/alert_currency.util.js";

const now = new Date("2026-11-17T02:00:00Z"); // 10:00 am Perth
const PARK = "Time of issue:\n01:39 PM\nDate of issue:\n30 Mar 2026\nFACILITY OR PARK CLOSURE\nPark Closure for Nyinggulara National Park (Ex-Ningaloo) in the SHIRE OF EXMOUTH.\nThe park will be closed from 4.30pm on Wednesday 25 March until further notice.";
const STORM = "At 5:15am on Tuesday 17 November 2026, the Bureau of Meteorology advised severe thunderstorms have eased.";

describe("agency time", () => {
  it("reads DFES 'Date of issue' and 'Time of issue' in Perth time", () => {
    expect(statedIssueTime(PARK, now, "waDfes")?.toISOString()).toBe("2026-03-30T05:39:00.000Z");
  });
  it("reads 'At 5:15am on Tuesday 17 November 2026'", () => {
    expect(statedIssueTime(STORM, now, "waDfes")?.toISOString()).toBe("2026-11-16T21:15:00.000Z");
  });
  it("ignores a stated time in the future", () => {
    expect(statedIssueTime("Issued 9:00am Monday 30 November 2026", now, "waDfes")).toBeNull();
  });
});

describe("old and outdated alerts are not shown", () => {
  it("a park closure issued in March is stale in November, even when the feed republished it yesterday", () => {
    const c = alertCurrency({ title: "Facility or Park Closure", description: PARK, nativeLevel: null, sourceId: "waDfes",
      occurredAt: new Date("2026-11-16T00:00:00Z"), existing: null, now });
    expect(c.staleAt.getTime()).toBeLessThan(now.getTime());
    expect(c.shownAt.toISOString()).toBe("2026-03-30T05:39:00.000Z");
  });
  it("a republish with the same words never restarts the clock", () => {
    const existing = { title: "t", description: "Crews are on scene.", nativeWarningLevel: null,
      createdAt: new Date("2026-11-10T00:00:00Z"), contentDetails: { sourceChangedAt: "2026-11-12T00:00:00Z" } };
    const c = alertCurrency({ title: "t", description: "Crews are on scene.", nativeLevel: null, sourceId: "x",
      occurredAt: new Date("2026-11-17T01:00:00Z"), existing, now });
    expect(c.changedAt.toISOString()).toBe("2026-11-12T00:00:00.000Z");
    expect(c.staleAt.getTime()).toBeLessThan(now.getTime());
  });
  it("a real change by the agency restarts the clock", () => {
    const existing = { title: "t", description: "Crews are on scene.", nativeWarningLevel: "Advice",
      createdAt: new Date("2026-11-10T00:00:00Z"), contentDetails: { sourceChangedAt: "2026-11-12T00:00:00Z" } };
    const c = alertCurrency({ title: "t", description: "Crews are on scene.", nativeLevel: "Watch and Act", sourceId: "x",
      occurredAt: null, existing, now });
    expect(c.changedAt).toEqual(now);
  });
  it("a record stored before this rule counts from first sighting when the words are unchanged", () => {
    const existing = { title: "t", description: "Road closed.", nativeWarningLevel: null,
      createdAt: new Date("2026-10-01T00:00:00Z"), contentDetails: {} };
    const c = alertCurrency({ title: "t", description: "Road closed.", nativeLevel: null, sourceId: "x", occurredAt: now, existing, now });
    expect(c.staleAt.getTime()).toBeLessThan(now.getTime());
  });
  it("today's storm update is current, and expiry is the earlier of source expiry and three days", () => {
    const c = alertCurrency({ title: "Storm Advice", description: STORM, nativeLevel: "Advice", sourceId: "waDfes", occurredAt: null, existing: null, now });
    expect(c.staleAt.getTime()).toBeGreaterThan(now.getTime());
    const soon = new Date(now.getTime() + 60 * 60 * 1000);
    expect(boundedExpiry(soon, c)).toEqual(soon);
    expect(boundedExpiry(new Date("2027-01-01T00:00:00Z"), c)).toEqual(c.staleAt);
  });
});

describe("wrong icon guard", () => {
  const cyclone = { id: "cyclone", name: "Cyclone", keywords: ["cyclone"] };
  const other = { id: "other", name: "Other", keywords: [] as string[] };
  const names = (c: typeof cyclone, t: string) => [c.name, ...c.keywords].some(w => t.toLowerCase().includes(w.toLowerCase()));
  it("a park closure is not a Cyclone alert because its body mentions a cyclone", () => {
    expect(guardNonWarningCategory({ title: "Facility or Park Closure Park Closure for Nyinggulara National Park", category: cyclone,
      isAwsCompliant: false, hazardCategoryIds: ["cyclone"], headlineNamesCategory: names, fallback: other }).id).toBe("other");
  });
  it("keeps the hazard when the closure headline names it", () => {
    expect(guardNonWarningCategory({ title: "Park closed due to Cyclone Narelle", category: cyclone,
      isAwsCompliant: false, hazardCategoryIds: ["cyclone"], headlineNamesCategory: names, fallback: other }).id).toBe("cyclone");
  });
  it("never touches an Australian Warning System warning", () => {
    expect(guardNonWarningCategory({ title: "Roads closed", category: cyclone,
      isAwsCompliant: true, hazardCategoryIds: ["cyclone"], headlineNamesCategory: names, fallback: other }).id).toBe("cyclone");
  });
});
