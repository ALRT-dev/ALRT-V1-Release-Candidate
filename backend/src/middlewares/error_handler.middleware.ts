import type { NextFunction, Request, Response } from "express";
import { HttpError } from "../models/http_error.js";

export const errorHandlerMiddleware = (
  error: any,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.error(`Error occurred at endpoint ${req.originalUrl}:`, error);
  const status = error.statusCode || 500;
  // Unexpected server faults (DB, SDK, bugs) must not leak internals to clients.
  if (
    status >= 500 &&
    !(error instanceof HttpError) &&
    (process.env.NODE_ENV === "prod" || process.env.NODE_ENV === "production")
  ) {
    res.status(status).send({ error: "Internal Server Error" });
    return;
  }
  res
    .status(status)
    .send({
      error: error.message || "Internal Server Error",
      ...(error.code ? { code: error.code } : {}),
      ...(error.details ? { details: error.details } : {}),
    });
};
