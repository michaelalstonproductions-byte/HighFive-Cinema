export class ContractError extends Error {
  readonly statusCode: number;
  readonly code: string;

  constructor(code: string, message: string, statusCode = 400) {
    super(message);
    this.name = "ContractError";
    this.code = code;
    this.statusCode = statusCode;
  }
}

export function errorBody(error: unknown): { error: string; detail: string } {
  if (error instanceof ContractError) {
    return { error: error.code, detail: error.message };
  }
  return { error: "internal_error", detail: "Unhandled staging scaffold error" };
}
