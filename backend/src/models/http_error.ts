/**
 * Stable, machine-readable reasons the app can branch on without parsing
 * wording. Access refusals must say WHICH problem it is: a lapsed group
 * plan is not "buy Individual", a full group is not a payment problem.
 */
export type HttpErrorCode =
  | "INDIVIDUAL_REQUIRED"
  | "GROUP_PLAN_ENDED"
  | "SAVED_PLACE_LIMIT"
  | "GROUP_FULL"
  | "GROUP_ALREADY_COVERED"
  | "PLAN_TOO_SMALL"
  | "CHANGE_IN_STORE"
  | "HOST_ONLY"
  | "PAYER_ONLY"
  | "NO_SOS_RECIPIENTS"
  | "SOS_PRESET_OTHER_GROUP";

export class HttpError extends Error {
  statusCode: number
  code?: HttpErrorCode | undefined
  details?: Record<string, unknown> | undefined

  constructor(
    statusCode: number,
    message: string,
    code?: HttpErrorCode,
    details?: Record<string, unknown>,
  ) {
    super(message)
    this.statusCode = statusCode
    this.code = code
    this.details = details
  }
}
