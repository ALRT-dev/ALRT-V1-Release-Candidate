import { readFileSync } from "node:fs";
import { beforeEach, describe, expect, it, vi } from "vitest";
const db = vi.hoisted(() => ({hazardCategory:{findUnique:vi.fn()},safetyGuide:{findFirst:vi.fn()}}));
vi.mock("../utils/prisma_client.util.js",()=>({default:db}));
vi.mock("../services/xp_ledger.service.js",()=>({recordGuideCompletion:vi.fn()}));
import {getGuideForHazardCategory} from "../services/guide.service.js";
import {guideSlugForCategory, guideStageForLevel, linkedGuideSlugs} from "../utils/guide_category_map.util.js";

const category = (name: string, parent = "Weather & Environment") =>
  ({id:"0b6c7e2a-uuid",name,parent:{name:parent}});

describe("hazard-specific learning guides",()=>{
  beforeEach(()=>{vi.clearAllMocks();db.safetyGuide.findFirst.mockImplementation(async({where}:any)=>({id:"g",slug:where.slug,title:where.slug}));});

  it("gives a real bushfire its bushfire guide (uuid ids no longer hide it)", async()=>{
    db.hazardCategory.findUnique.mockResolvedValue(category("Bushfire"));
    expect((await getGuideForHazardCategory("0b6c7e2a-uuid"))?.slug).toBe("bushfire-being-prepared");
    expect(db.safetyGuide.findFirst).toHaveBeenCalledWith(expect.objectContaining({where:{isPublished:true,slug:"bushfire-being-prepared"}}));
  });

  it("picks the during and after guides from the alert level", async()=>{
    db.hazardCategory.findUnique.mockResolvedValue(category("Bushfire"));
    expect((await getGuideForHazardCategory("x","Watch and Act"))?.slug).toBe("bushfire-during");
    expect((await getGuideForHazardCategory("x","Emergency Warning"))?.slug).toBe("bushfire-during");
    expect((await getGuideForHazardCategory("x","Advice"))?.slug).toBe("bushfire-being-prepared");
    expect((await getGuideForHazardCategory("x","No longer a threat"))?.slug).toBe("bushfire-after");
  });

  it.each(["Vehicle Fire","Other Fire","Planned Burn"])("gives %s no bushfire guide", async(name)=>{
    db.hazardCategory.findUnique.mockResolvedValue(category(name));
    expect(await getGuideForHazardCategory("x","Watch and Act")).toBeNull();
    expect(db.safetyGuide.findFirst).not.toHaveBeenCalled();
  });

  it("links subcategories the keyword seed missed", ()=>{
    expect(guideSlugForCategory({name:"Power Outage",parentName:"Utilities & Infrastructure"})).toBe("power-outage");
    expect(guideSlugForCategory({name:"Boil Water Notice"})).toBe("water-contamination");
    expect(guideSlugForCategory({name:"Water Over Road"})).toBe("driving-near-floodwater");
    expect(guideSlugForCategory({name:"Fire Weather"})).toBe("bushfire-being-prepared");
    expect(guideSlugForCategory({name:"Heat Health Alert"})).toBe("heatwave");
    expect(guideSlugForCategory({name:"Flood",level:"Emergency Warning"})).toBe("flash-flooding");
  });

  it("never links a parent group on its own", ()=>{
    expect(guideSlugForCategory({name:"Weather & Environment"})).toBeNull();
    expect(guideSlugForCategory({name:"Crash",parentName:"Transport & Traffic"})).toBeNull();
  });

  it("reads stages from levels", ()=>{
    expect(guideStageForLevel(undefined)).toBe("before");
    expect(guideStageForLevel("GDACS Red")).toBe("during");
    expect(guideStageForLevel("Cancelled")).toBe("after");
  });

  it("only links guides that the seed or the 16 Nov drafts create", ()=>{
    const seed = readFileSync(new URL("../services/guide_seed.service.ts", import.meta.url), "utf8")
      + readFileSync(new URL("../data/guidance_drafts_20261116.ts", import.meta.url), "utf8");
    for (const slug of linkedGuideSlugs()) expect(seed).toContain(`slug: "${slug}"`);
  });

  it("gives smoke, structure fire, hazmat and landslide their own guides (drafted 16 Nov)", ()=>{
    expect(guideSlugForCategory({name:"Smoke"})).toBe("smoke-air-quality");
    expect(guideSlugForCategory({name:"Structural Fire"})).toBe("house-fire");
    expect(guideSlugForCategory({name:"Chemical Spill"})).toBe("hazardous-materials");
    expect(guideSlugForCategory({name:"Land Slip"})).toBe("landslide");
  });

  it("sends a replaced guide's links to its replacement", async()=>{
    db.hazardCategory.findUnique.mockResolvedValue(category("Terror","Safety & Crime"));
    db.safetyGuide.findFirst.mockImplementation(async({where}:any)=>where.slug==="armed-attack-escape-hide-tell"?{id:"g",slug:where.slug}:null);
    expect((await getGuideForHazardCategory("x"))?.slug).toBe("armed-attack-escape-hide-tell");
  });
});
