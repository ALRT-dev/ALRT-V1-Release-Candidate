import { describe, expect, it, vi } from "vitest";
vi.mock("@prisma/client", async (importOriginal) => ({
  ...await importOriginal<typeof import("@prisma/client")>(),
  FireStatus: { active: "active", beingControlled: "beingControlled", underControl: "underControl", closed: "closed" },
}));
vi.mock("../services/hazard_category.service.js", () => ({ MainCategoryId: {} }));
import { getCategoryFromDescription, getCategoryFromTitleFirst } from "../utils/ingestion.category.util.js";

const parent = { id: "grp", name: "grp", keywords: [], parent: null };
const mk = (id: string, keywords: string[]) =>
  ({ id, name: id, keywords, parent, description: "", isActive: true }) as never;
const cats = [mk("powerOutage", ["power outage"]), mk("smoke", ["smoke"]), mk("airQualityAlert", ["air quality"]), mk("otherFire", ["fire alarm"]), mk("other", [])];

describe("smoke routing", () => {
  it("health advice about smoke goes to air quality", () => {
    expect(getCategoryFromDescription("Smoke in the area. People with asthma should check health advice.", cats).id).toBe("airQualityAlert");
  });
  it("residual smoke goes to other fire", () => {
    expect(getCategoryFromDescription("Residual smoke may be visible near the burn.", cats).id).toBe("otherFire");
  });
  it("plain smoke stays smoke", () => {
    expect(getCategoryFromDescription("Smoke reported", cats).id).toBe("smoke");
  });
  it("headline wins over body words", () => {
    const c = getCategoryFromTitleFirst("Smoke Alert - Mundaring", "Smoke Alert. Expect a power outage. Asthma advice.", cats);
    expect(c?.id).toBe("airQualityAlert");
  });
  it("no headline match returns null", () => {
    expect(getCategoryFromTitleFirst("Notice", "power outage", cats)).toBeNull();
  });
});
