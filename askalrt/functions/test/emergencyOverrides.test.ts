import {
  aliasesFromNames,
  mergeEmergencyNumbers,
  sanitizeEmergencyConfig,
} from "../src/askalrt/emergencyOverrides";
import { detectEmergencyLookup } from "../src/askalrt/matching";
import { EMERGENCY_NUMBERS, resolveEmergencyNumber } from "../src/lib/emergencyLogic";

describe("sanitizeEmergencyConfig", () => {
  it("returns an empty config for missing or non-object input", () => {
    expect(sanitizeEmergencyConfig(undefined)).toEqual({ numbers: {}, names: {} });
    expect(sanitizeEmergencyConfig("nope")).toEqual({ numbers: {}, names: {} });
    expect(sanitizeEmergencyConfig(null)).toEqual({ numbers: {}, names: {} });
  });

  it("upper-cases ISO codes and keeps valid numbers and names", () => {
    expect(
      sanitizeEmergencyConfig({ numbers: { jp: "110", AU: " 000 " }, names: { jp: "Japan" } })
    ).toEqual({ numbers: { JP: "110", AU: "000" }, names: { JP: "Japan" } });
  });

  it("drops bad ISO codes, non-numeric numbers, blank names and wrong types", () => {
    const out = sanitizeEmergencyConfig({
      numbers: { JPN: "110", US: "9-1-1", NZ: 111, GB: "999", CA: "1234567" },
      names: { JP: "", US: 5, GB: "x".repeat(61), FR: "France" },
    });
    expect(out.numbers).toEqual({ GB: "999" });
    expect(out.names).toEqual({ FR: "France" });
  });
});

describe("mergeEmergencyNumbers", () => {
  it("lets overrides win and leaves the defaults untouched", () => {
    const merged = mergeEmergencyNumbers(EMERGENCY_NUMBERS, { AU: "112", JP: "110" });
    expect(merged.AU).toBe("112");
    expect(merged.JP).toBe("110");
    expect(merged.NZ).toBe("111");
    expect(EMERGENCY_NUMBERS.AU).toBe("000");
  });

  it("feeds resolveEmergencyNumber so an edited number is the one quoted", () => {
    const merged = mergeEmergencyNumbers(EMERGENCY_NUMBERS, { NZ: "112" });
    expect(resolveEmergencyNumber({ simCountry: "NZ" }, merged)).toBe("112");
  });
});

describe("country names as lookup aliases", () => {
  it("normalises names to alias keys", () => {
    expect(aliasesFromNames({ JP: "Japan", KR: "South Korea" })).toEqual({
      japan: "JP",
      "south korea": "KR",
    });
  });

  it("lets a question naming an admin-added country resolve to its ISO", () => {
    const aliases = aliasesFromNames({ JP: "Japan" });
    expect(detectEmergencyLookup("what's the emergency number in Japan", aliases)).toEqual({ iso: "JP" });
    expect(detectEmergencyLookup("what's the emergency number in Japan")).toBeNull();
  });

  it("matches admin-added names as whole words only", () => {
    const aliases = aliasesFromNames({ OM: "Oman" });
    expect(detectEmergencyLookup("emergency number for a woman in danger", aliases)).toBeNull();
    expect(detectEmergencyLookup("emergency number in Oman", aliases)).toEqual({ iso: "OM" });
  });
});
