import { beforeEach, describe, expect, it, vi } from "vitest";
const db = vi.hoisted(() => ({hazardCategory:{findUnique:vi.fn()},safetyGuide:{findFirst:vi.fn()}}));
vi.mock("../utils/prisma_client.util.js",()=>({default:db}));
vi.mock("../services/xp_ledger.service.js",()=>({recordGuideCompletion:vi.fn()}));
import {getGuideForHazardCategory} from "../services/guide.service.js";
describe("hazard-specific learning guides",()=>{
  beforeEach(()=>{vi.clearAllMocks();db.hazardCategory.findUnique.mockResolvedValue({id:"structureFire",parentId:"utilitiesAndInfrastructure"});});
  it("only searches published guides explicitly linked to the actual category",async()=>{
    db.safetyGuide.findFirst.mockResolvedValue(null);
    expect(await getGuideForHazardCategory("structureFire")).toBeNull();
    expect(db.safetyGuide.findFirst.mock.calls[0][0].where).toEqual({isPublished:true,categoryIds:{has:"structureFire"}});
  });
});
