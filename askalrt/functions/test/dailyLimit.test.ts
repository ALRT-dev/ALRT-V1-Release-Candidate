import { AI_DAILY_LIMIT, isValidTimeZone, localDayKey } from "../src/askalrt/askAlrt";

describe("Ask ALRT daily limit (V1 access model)", () => {
  it("is 3 on Free and 10 on Individual", () => {
    expect(AI_DAILY_LIMIT).toEqual({ free: 3, individual: 10 });
  });

  it("counts the account's local calendar day, not UTC", () => {
    // 2026-09-28 20:30 UTC is 29 Sep in Sydney (06:30) and Perth (04:30),
    // and still 28 Sep in Los Angeles (13:30).
    const at = new Date(Date.UTC(2026, 8, 28, 20, 30));
    expect(localDayKey(at, "UTC")).toBe("20260928");
    expect(localDayKey(at, "Australia/Sydney")).toBe("20260929");
    expect(localDayKey(at, "Australia/Perth")).toBe("20260929");
    expect(localDayKey(at, "America/Los_Angeles")).toBe("20260928");
  });

  it("follows daylight saving without double-counting a day", () => {
    // Sydney moves to AEDT on 4 Oct 2026 at 02:00 local.
    const before = new Date(Date.UTC(2026, 9, 3, 14, 30)); // 00:30 AEST 4 Oct
    const after = new Date(Date.UTC(2026, 9, 3, 16, 30)); // 03:30 AEDT 4 Oct
    expect(localDayKey(before, "Australia/Sydney")).toBe("20261004");
    expect(localDayKey(after, "Australia/Sydney")).toBe("20261004");
  });

  it("accepts real IANA zones and rejects junk", () => {
    expect(isValidTimeZone("Australia/Brisbane")).toBe(true);
    expect(isValidTimeZone("Not/AZone")).toBe(false);
    expect(isValidTimeZone("")).toBe(false);
    expect(isValidTimeZone(42)).toBe(false);
    expect(isValidTimeZone("x".repeat(100))).toBe(false);
  });
});
