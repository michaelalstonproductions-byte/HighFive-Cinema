import {
  catalogPath,
  catalogDeltaPath,
  catalogSyncPath,
  collectionDetailPath,
  contentDetailPath,
  creatorDetailPath,
  openAPIPath,
  readinessPath
} from "../contracts.js";

export function openAPISpec(): Record<string, unknown> {
  return {
    openapi: "3.1.0",
    info: {
      title: "HighFive Cinema Production Backend Foundation",
      version: "0.29.0",
      description: "Read-only local catalog foundation for P29A. Authentication, uploads, payments, and media processing are out of scope."
    },
    paths: {
      "/health": { get: { summary: "Health check" } },
      [readinessPath]: { get: { summary: "Readiness check" } },
      [catalogPath]: { get: { summary: "Fetch read-only catalog" } },
      [catalogSyncPath]: { get: { summary: "Fetch full catalog sync snapshot" } },
      [catalogDeltaPath]: { get: { summary: "Fetch catalog delta sync payload" } },
      [`${contentDetailPath}{id}`]: { get: { summary: "Fetch content detail" } },
      [`${creatorDetailPath}{id}`]: { get: { summary: "Fetch creator detail" } },
      [`${collectionDetailPath}{id}`]: { get: { summary: "Fetch collection detail" } },
      [openAPIPath]: { get: { summary: "Fetch OpenAPI document" } }
    }
  };
}
