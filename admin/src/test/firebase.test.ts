import { describe, expect, test } from "vitest";
import { isFirebaseConfigured } from "../lib/firebase";

// No Firebase Web App has been registered for this project yet, so every
// VITE_FIREBASE_* value is blank in every committed env file (.env.example,
// .env.test) - this pins that "not configured" is the real, current state,
// not just an assumption, and that Ask ALRT's page correctly detects it
// rather than attempting a broken Firebase call.
describe("isFirebaseConfigured", () => {
  test("is false until a real Firebase Web App config is supplied", () => {
    expect(isFirebaseConfigured()).toBe(false);
  });
});
