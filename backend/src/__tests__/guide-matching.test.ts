import { beforeEach, describe, expect, it, vi } from "vitest";
const db = vi.hoisted(() => ({hazardCategory:{findUnique:vi.fn()},safetyGuide:{findFirst:vi.fn()}}));
vi.mock("../utils/prisma_client.util.js",()=>({default:db}));
vi.mock("../services/xp_ledger.service.js",()=>({recordGuideCompletion:vi.fn()}));
import {getGuideForHazardCategory} from "../services/guide.service.js";
describe("hazard-specific learning guides",()=>{
  it("rejects a bushfire guide incorrectly linked to generic fire", async()=>{
    db.hazardCategory.findUnique.mockResolvedValue({id:"otherFire",parentId:"weather"});
    db.safetyGuide.findFirst.mockResolvedValue({id:"guide",slug:"bushfire-being-prepared",title:"Bushfire: being prepared"});
    expect(await getGuideForHazardCategory("otherFire")).toBeNull();
  });
  beforeEach(()=>{vi.clearAllMocks();db.hazardCategory.findUnique.mockResolvedValue({id:"structureFire",parentId:"utilitiesAndInfrastructure"});});
  it("only searches published guides explicitly linked to the actual category",async()=>{
    db.safetyGuide.findFirst.mockResolvedValue(null);
    expect(await getGuideForHazardCategory("structureFire")).toBeNull();
    expect(db.safetyGuide.findFirst).toHaveBeenCalledWith(expect.objectContaining({where:{isPublished:true,categoryIds:{has:"structureFire"}}}));
  });
});
