import { beforeEach, describe, expect, it, vi } from "vitest";
const mocks = vi.hoisted(() => ({
  $queryRaw:vi.fn().mockResolvedValue([]),
  row: null as any,
  configuration: { findUnique: vi.fn(), updateMany: vi.fn() },
  aIPrompt: { findMany: vi.fn() },
  hazardSource: { count: vi.fn() },
  hazardCategory: { count: vi.fn() },
  adminAuditLog: { create: vi.fn() },
  clearCache: vi.fn(),
}));
vi.mock("../utils/prisma_client.util.js", () => ({
  default: {
    $transaction: async (fn: any) => fn(mocks),
    configuration: mocks.configuration,
  },
}));
vi.mock("../services/configuration.service.js", () => ({
  clearCache: mocks.clearCache,
}));
import {
  emptyRegistry,
  saveTemplateRegistry,
  TEMPLATE_KEY,
  getReleasePrompt,
  readRegistry,
} from "../services/alert_templates.service.js";
import { defaultTemplatePack } from "../utils/alert_templates.util.js";

beforeEach(() => {
  vi.clearAllMocks();
  mocks.row = {
    id: "config",
    key: "aiPrompts",
    updatedAt: new Date("2026-10-13T00:00:00Z"),
    value: {
      preserved: "keep",
      officialAlertSummarizationPromptId: { actionPromptId: "p1" },
    },
  };
  mocks.configuration.findUnique.mockImplementation(async () =>
    structuredClone(mocks.row),
  );
  mocks.configuration.updateMany.mockImplementation(async ({ data }) => {
    mocks.row.value = data.value;
    return { count: 1 };
  });
  mocks.aIPrompt.findMany.mockResolvedValue([
    {
      id: "p1",
      name: "Official",
      content: "First prompt",
      model: "model",
      updatedAt: new Date(),
    },
  ]);
  mocks.hazardCategory.count.mockImplementation(
    async ({ where }) => where.id.in.length,
  );
  mocks.hazardSource.count.mockImplementation(
    async ({ where }) => new Set(where.id.in).size,
  );
  mocks.adminAuditLog.create.mockResolvedValue({});
});
const save = (args: Partial<Parameters<typeof saveTemplateRegistry>[0]> = {}) =>
  saveTemplateRegistry({
    revision: 0,
    action: "draft",
    reason: "Test change",
    adminId: null,
    ...args,
  });
describe("template publication", () => {
  it("stores drafts separately and preserves unrelated prompt configuration", async () => {
    const state = await save({ pack: defaultTemplatePack() });
    expect(state.published).toBeNull();
    expect(state.revision).toBe(1);
    expect(mocks.row.value.preserved).toBe("keep");
    expect(readRegistry(mocks.row.value).draft).toEqual(state.draft);
    expect(
      mocks.configuration.updateMany.mock.calls[0]?.[0].where.updatedAt,
    ).toEqual(new Date("2026-10-13T00:00:00Z"));
  });
  it("rejects a stale editor without writing", async () => {
    mocks.row.value[TEMPLATE_KEY] = { ...emptyRegistry(), revision: 2 };
    await expect(save()).rejects.toThrow("Someone else");
    expect(mocks.configuration.updateMany).not.toHaveBeenCalled();
  });
  it("snapshots prompts and routing, and restores the old wording as a new version", async () => {
    const first = await save({ action: "publish" });
    expect(first.published?.prompts.p1?.content).toBe("First prompt");
    mocks.aIPrompt.findMany.mockResolvedValue([
      {
        id: "p1",
        name: "Official",
        content: "Second prompt",
        model: "model",
        updatedAt: new Date(),
      },
    ]);
    const second = await save({ revision: 1, action: "publish" });
    expect(second.published?.prompts.p1?.content).toBe("Second prompt");
    const restored = await save({ revision: 2, action: "restore", version: 1 });
    expect(restored.published?.version).toBe(3);
    expect(restored.published?.prompts.p1?.content).toBe("First prompt");
    expect(restored.history.map((x) => x.version)).toEqual([2, 1]);
    const prompt = getReleasePrompt(restored.published!, {
      promptId: null,
      sourceId: "agency",
      categoryId: "fire",
      isAws: false,
      band: "action",
    });
    expect(prompt.content).toBe("First prompt");
  });
  it("refuses a concurrent configuration write", async () => {
    mocks.configuration.updateMany.mockResolvedValue({ count: 0 });
    await expect(save()).rejects.toThrow("Configuration changed");
    expect(mocks.adminAuditLog.create).not.toHaveBeenCalled();
  });
  it("refuses a missing selected prompt and a missing restoration version", async () => {
    const pack = defaultTemplatePack();
    pack.defaults.promptId = "missing";
    await expect(save({ pack })).rejects.toThrow("prompt no longer exists");
    await expect(save({ action: "restore", version: 99 })).rejects.toThrow(
      "no longer in history",
    );
  });
});
