import type { Request, Response, NextFunction } from "express";
import * as zod from "zod";
import { HttpError } from "../models/http_error.js";

type ValidationTarget = "body" | "query" | "params";

export const validate =
  (schema: zod.ZodSchema, target: ValidationTarget = "body") =>
  (req: Request, res: Response, next: NextFunction) => {
    try {
      const parsed = schema.parse((req as any)[target] || {});
      if (target === "query") {
        // Express 5's req.query is a getter re-parsed from the URL on every
        // access (no setter, and not cached on the instance) - so neither
        // `req.query = parsed` (throws: only a getter) nor mutating the
        // object returned by one access (silently lost - the next access
        // re-parses from scratch) makes the validated/coerced values
        // visible downstream. Defining an own property on this req instance
        // shadows the prototype getter for every later access on the same
        // request.
        Object.defineProperty(req, "query", {
          value: parsed,
          writable: true,
          configurable: true,
          enumerable: true,
        });
      } else {
        (req as any)[target] = parsed;
      }
      next();
    } catch (error: any) {
      if (error instanceof zod.ZodError) {
        const errors = error.issues.map((err: any) => ({
          path: err.path.join("."),
          message: err.message,
        }));

        throw new HttpError(
          400,
          `${errors.map((e: any) => e.message).join(", ")}`
        );
      }
      next(error);
    }
  };
