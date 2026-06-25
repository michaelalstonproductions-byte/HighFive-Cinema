import {
  catalogPath,
  catalogDeltaPath,
  catalogSyncPath,
  collectionDetailPath,
  contentDetailPath,
  creatorDraftDetailPath,
  creatorDraftsPath,
  creatorDraftSyncQueuePath,
  creatorDetailPath,
  creatorProcessingJobDetailPath,
  creatorProcessingJobsPath,
  creatorUploadAssetsPath,
  creatorUploadDetailPath,
  creatorUploadSessionsPath,
  openAPIPath,
  playbackDescriptorPath,
  playbackHLSPath,
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
      [creatorDraftsPath]: {
        get: { summary: "List authenticated creator drafts" },
        post: { summary: "Create authenticated creator draft" }
      },
      [`${creatorDraftDetailPath}{id}`]: {
        get: { summary: "Fetch authenticated creator draft" },
        patch: { summary: "Update authenticated creator draft with optimistic concurrency" }
      },
      [`${creatorDraftDetailPath}{id}/archive`]: { post: { summary: "Archive authenticated creator draft" } },
      [`${creatorDraftDetailPath}{id}/restore`]: { post: { summary: "Restore authenticated creator draft" } },
      [`${creatorDraftDetailPath}{id}/revisions`]: { get: { summary: "Fetch creator draft revision history" } },
      [creatorDraftSyncQueuePath]: { get: { summary: "Fetch creator draft sync queue audit records" } },
      [creatorUploadSessionsPath]: { post: { summary: "Create short-lived creator upload session" } },
      [`${creatorUploadDetailPath}{id}/blob`]: { put: { summary: "Upload verified asset bytes into local object storage" } },
      [`${creatorUploadDetailPath}{id}/cancel`]: { post: { summary: "Cancel creator upload session and cleanup local staging object" } },
      [creatorUploadAssetsPath]: { get: { summary: "List uploaded creator asset records" } },
      [creatorProcessingJobsPath]: {
        get: { summary: "List creator media processing jobs" },
        post: { summary: "Create local media processing job for uploaded asset" }
      },
      [`${creatorProcessingJobDetailPath}{id}/retry`]: { post: { summary: "Retry a failed or completed media processing job idempotently" } },
      [playbackDescriptorPath]: { post: { summary: "Resolve a short-lived playback descriptor for entitled content" } },
      [`${playbackHLSPath}{id}/master.m3u8`]: { get: { summary: "Fetch signed local HLS master manifest for a processed asset" } },
      [openAPIPath]: { get: { summary: "Fetch OpenAPI document" } }
    }
  };
}
