import { beforeEach, describe, expect, it, vi } from "vitest";
const mocks = vi.hoisted(() => ({ send: vi.fn(), optimize: vi.fn() }));
vi.mock("../utils/s3_client.util.js", () => ({ default: { send: mocks.send } }));
vi.mock("../utils/config.js", () => ({ config: { aws: { s3: { bucketName: "test", cloudfrontDomain: "" }, region: "ap-southeast-2" } } }));
vi.mock("../utils/image_optimization.util.js", () => ({ optimizeImageBuffer: mocks.optimize }));
import { uploadFileToS3 } from "../services/s3.service.js";

const original = Buffer.from("original agency artwork");
const compressed = Buffer.from("webp");
const file = { buffer: original, mimetype: "image/png", originalname: "warning.png", size: original.length } as Express.Multer.File;
beforeEach(() => {
  vi.clearAllMocks();
  mocks.send.mockResolvedValue({});
  mocks.optimize.mockResolvedValue({ buffer: compressed, mimeType: "image/webp", changed: true });
});
describe("upload image scope", () => {
  it.each(["category-images/bushfire", "future-official-artwork"])("preserves exact artwork bytes in %s", async (folder) => {
    const result = await uploadFileToS3(file, folder);
    expect(mocks.optimize).not.toHaveBeenCalled();
    expect(mocks.send.mock.calls[0]?.[0]?.input.Body).toBe(original);
    expect(result.mimeType).toBe("image/png");
    expect(result.key).toMatch(/\.png$/);
  });
  it.each(["hazards", "profile-pictures", "family-circle-photos", "family-member-photos"])("optimizes user photos in %s with a matching extension", async (folder) => {
    const result = await uploadFileToS3(file, folder);
    expect(mocks.optimize).toHaveBeenCalledWith(original, "image/png");
    expect(result.mimeType).toBe("image/webp");
    expect(result.key).toMatch(/\.webp$/);
    expect(result.originalName).toBe("warning.png");
    expect(result.size).toBe(compressed.length);
  });
});
