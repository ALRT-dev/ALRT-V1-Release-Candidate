import type { NextFunction, Request, Response } from "express";

export const errorHandlerMiddleware = (
  error: any,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.error(`Error occurred at endpoint ${req.originalUrl}:`, error);
  res
    .status(error.statusCode || 500)
    .send({
      error: error.message || "Internal Server Error",
      ...(error.code ? { code: error.code } : {}),
      ...(error.details ? { details: error.details } : {}),
    });
};
