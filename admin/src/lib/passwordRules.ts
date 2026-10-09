/**
 * Mirrors the admin password rules the backend enforces
 * (backend/src/validators/admin/auth.validator.ts, changeAdminPasswordSchema).
 * The server is the authority and its error message is always shown; this
 * only gives feedback while typing.
 */
export const PASSWORD_SPECIAL_CHARACTERS = '!@#$%^&*(),.?":{}|<>';

export interface PasswordRule {
  label: string;
  test: (password: string) => boolean;
}

export const PASSWORD_RULES: PasswordRule[] = [
  { label: "At least 12 characters", test: (p) => p.length >= 12 },
  { label: "No more than 128 characters", test: (p) => p.length <= 128 },
  { label: "An uppercase letter", test: (p) => /[A-Z]/.test(p) },
  { label: "A lowercase letter", test: (p) => /[a-z]/.test(p) },
  { label: "A number", test: (p) => /[0-9]/.test(p) },
  {
    label: `A special character (one of ${PASSWORD_SPECIAL_CHARACTERS})`,
    test: (p) => /[!@#$%^&*(),.?":{}|<>]/.test(p),
  },
];

/** Every reason the form cannot be submitted yet, in display order. */
export const passwordChangeProblems = (input: {
  currentPassword: string;
  newPassword: string;
  confirmPassword: string;
}): string[] => {
  const problems: string[] = [];
  if (!input.currentPassword) problems.push("Enter your current password.");
  for (const rule of PASSWORD_RULES) {
    if (!rule.test(input.newPassword)) problems.push(`New password needs: ${rule.label.toLowerCase()}.`);
  }
  if (input.newPassword !== input.confirmPassword) problems.push("New passwords do not match.");
  if (input.currentPassword && input.currentPassword === input.newPassword) {
    problems.push("New password must be different from your current password.");
  }
  return problems;
};
