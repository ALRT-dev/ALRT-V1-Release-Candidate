import { describe, expect, it } from "vitest";
import { isMissingRoute } from "../api/client";

describe("isMissingRoute", () => {
  it("treats the backend's unknown-route 404 as a missing feature", () => {
    expect(
      isMissingRoute(404, {
        error: "The route [GET]: /api/admin/ask-alrt/config does not exist!",
      }),
    ).toBe(true);
  });

  it("treats an empty or text 404 as a missing feature", () => {
    expect(isMissingRoute(404, null)).toBe(true);
    expect(isMissingRoute(404, "<html>Not Found</html>")).toBe(true);
  });

  it("keeps a record-level 404 as it is", () => {
    expect(isMissingRoute(404, { error: "Hazard not found" })).toBe(false);
  });

  it("ignores other statuses", () => {
    expect(isMissingRoute(500, null)).toBe(false);
    expect(isMissingRoute(403, { error: "The route [GET]: /x does not exist!" })).toBe(false);
  });
});
