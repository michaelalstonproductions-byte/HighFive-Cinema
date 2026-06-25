import type { IncomingMessage, ServerResponse } from "node:http";
import { ContractError, errorBody } from "../errors.js";

export type JsonResponse = {
  statusCode: number;
  body: unknown;
};

export function writeJson(response: ServerResponse, statusCode: number, body: unknown): void {
  response.writeHead(statusCode, {
    "Content-Type": "application/json",
    "Cache-Control": "no-store"
  });
  response.end(JSON.stringify(body));
}

export function methodNotAllowed(): JsonResponse {
  return { statusCode: 405, body: { error: "method_not_allowed" } };
}

export function routeNotFound(): JsonResponse {
  return { statusCode: 404, body: { error: "route_not_found" } };
}

export async function readBoundedJsonBody(request: IncomingMessage, bodyLimitBytes: number): Promise<unknown> {
  const contentType = headerValue(request.headers["content-type"]);
  if (!contentType || !contentType.toLowerCase().includes("application/json")) {
    throw new ContractError("unsupported_content_type", "Content-Type must be application/json", 415);
  }

  const chunks: Uint8Array[] = [];
  let byteCount = 0;
  for await (const chunk of request) {
    const nextChunk = Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk);
    byteCount += nextChunk.length;
    if (byteCount > bodyLimitBytes) {
      throw new ContractError("payload_too_large", "Request body exceeds local staging limit", 413);
    }
    chunks.push(nextChunk);
  }

  if (chunks.length === 0) {
    throw new ContractError("empty_json_body", "Request body must contain JSON", 400);
  }

  try {
    return JSON.parse(Buffer.concat(chunks).toString("utf8"));
  } catch {
    throw new ContractError("malformed_json", "Request body must be valid JSON", 400);
  }
}

export async function readBoundedBinaryBody(request: IncomingMessage, bodyLimitBytes: number): Promise<Buffer> {
  const chunks: Uint8Array[] = [];
  let byteCount = 0;
  for await (const chunk of request) {
    const nextChunk = Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk);
    byteCount += nextChunk.length;
    if (byteCount > bodyLimitBytes) {
      throw new ContractError("payload_too_large", "Upload body exceeds local staging limit", 413);
    }
    chunks.push(nextChunk);
  }
  if (chunks.length === 0) {
    throw new ContractError("empty_upload_body", "Upload request must contain asset bytes", 400);
  }
  return Buffer.concat(chunks);
}

export function errorResponse(error: unknown): JsonResponse {
  if (error instanceof Error && error.name === "UnauthorizedIdentityAccess") {
    return {
      statusCode: 401,
      body: {
        error: error.message,
        detail: "A valid HighFive identity session is required."
      }
    };
  }
  if (error instanceof Error && error.name === "ForbiddenIdentityAccess") {
    return {
      statusCode: 403,
      body: {
        error: error.message,
        detail: "This identity role cannot access the requested creator workspace."
      }
    };
  }
  if (error instanceof ContractError) {
    return { statusCode: error.statusCode, body: errorBody(error) };
  }
  return { statusCode: 500, body: errorBody(error) };
}

function headerValue(value: string | string[] | undefined): string | undefined {
  if (Array.isArray(value)) return value[0];
  return value;
}
