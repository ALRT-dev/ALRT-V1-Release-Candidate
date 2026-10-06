import { describe, expect, it } from "vitest";
import { pageInfo } from "../lib/pagination";
import { passwordChangeProblems, PASSWORD_RULES } from "../lib/passwordRules";

describe("pageInfo", () => {
  it("uses the backend total when there is one", () => {
    expect(pageInfo({ page: 1, pageSize: 50, itemsOnPage: 50, total: 120 })).toEqual({
      page: 1,
      totalPages: 3,
      hasPrevious: false,
      hasNext: true,
      label: "Page 1 of 3",
    });
    const last = pageInfo({ page: 3, pageSize: 50, itemsOnPage: 20, total: 120 });
    expect(last.hasNext).toBe(false);
    expect(last.hasPrevious).toBe(true);
    expect(last.label).toBe("Page 3 of 3");
  });

  it("treats an empty total as one page", () => {
    const info = pageInfo({ page: 1, pageSize: 50, itemsOnPage: 0, total: 0 });
    expect(info.label).toBe("Page 1 of 1");
    expect(info.hasNext).toBe(false);
  });

  it("infers the last page from a short page when no total is returned", () => {
    const full = pageInfo({ page: 2, pageSize: 50, itemsOnPage: 50 });
    expect(full).toMatchObject({ hasNext: true, hasPrevious: true, totalPages: null, label: "Page 2" });

    const short = pageInfo({ page: 3, pageSize: 50, itemsOnPage: 7 });
    expect(short).toMatchObject({ hasNext: false, totalPages: 3, label: "Page 3 of 3" });
  });
});

describe("passwordChangeProblems", () => {
  const good = "Correct-Horse1!";

  it("accepts a password that meets every backend rule", () => {
    expect(
      passwordChangeProblems({ currentPassword: "Temp-Password1!", newPassword: good, confirmPassword: good }),
    ).toEqual([]);
  });

  it("lists each missing rule", () => {
    const problems = passwordChangeProblems({
      currentPassword: "x",
      newPassword: "short",
      confirmPassword: "short",
    });
    expect(problems.some((p) => p.includes("12 characters"))).toBe(true);
    expect(problems.some((p) => p.includes("uppercase"))).toBe(true);
    expect(problems.some((p) => p.includes("number"))).toBe(true);
    expect(problems.some((p) => p.includes("special character"))).toBe(true);
  });

  it("rejects a mismatched confirmation and reuse of the current password", () => {
    expect(
      passwordChangeProblems({ currentPassword: good, newPassword: good, confirmPassword: good }),
    ).toContain("New password must be different from your current password.");
    expect(
      passwordChangeProblems({ currentPassword: "a", newPassword: good, confirmPassword: `${good}x` }),
    ).toContain("New passwords do not match.");
  });

  it("only counts the backend's special characters", () => {
    const special = PASSWORD_RULES.find((r) => r.label.startsWith("A special"))!;
    expect(special.test("Abcdefghijk1!")).toBe(true);
    expect(special.test("Abcdefghijk1-")).toBe(false);
  });
});
