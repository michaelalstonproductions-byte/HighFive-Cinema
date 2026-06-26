import { createHash, randomUUID } from "node:crypto";
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import type { JsonObject } from "../contracts.js";
import { ContractError } from "../errors.js";
import { recordAnalyticsEvent } from "./analytics.js";
import { requireCreatorIdentitySession } from "./identity.js";
import { recordProductNotification } from "./notifications.js";
import { uploadedAssetForProcessing, uploadObjectStoreRoot, type UploadedAssetRecord } from "./uploads.js";

type ProcessingState = "queued" | "inspecting" | "processing" | "completed" | "failed";

type ProcessingJobRecord = {
  id: string;
  asset_id: string;
  project_id: string;
  creator_id: string | null;
  source_object_key: string;
  state: ProcessingState;
  progress: number;
  created_at: string;
  updated_at: string;
  completed_at: string | null;
  failure_reason: string | null;
  retry_count: number;
  inspection: JsonObject | null;
  output: JsonObject | null;
  logs: string[];
};

type ProcessedPlaybackDescriptor = {
  playback_url_or_token_reference: string;
  expires_at: string;
  refresh_after: string;
  processing_job_id: string;
  hls_master_object_key: string;
};

const processingJobs = new Map<string, ProcessingJobRecord>();
const assetJobIndex = new Map<string, string>();
const movieProjectIDs = new Map<string, string>([
  ["friendly", "project-behind-the-vision"],
  ["behind-vision", "project-behind-the-vision"]
]);

export function processingReadinessSummary(): JsonObject {
  return {
    processing_jobs_enabled: true,
    ffprobe_inspection_contract: true,
    ffmpeg_processing_contract: true,
    hls_output_contract: true,
    playback_descriptor_resolution: true,
    job_progress: true,
    retry: true,
    idempotency: true,
    jobs: processingJobs.size
  };
}

export function processedPlaybackDescriptorForMovie(movieID: string, origin: string): ProcessedPlaybackDescriptor | null {
  const job = completedProcessingJobForMovie(movieID);
  const output = job?.output;
  if (!job || !output || typeof output.hls_master_object_key !== "string") return null;

  const expiresAt = new Date(Date.now() + 10 * 60 * 1000).toISOString();
  const refreshAfter = new Date(Date.now() + 8 * 60 * 1000).toISOString();
  const signature = playbackSignature(job, expiresAt);
  const encodedExpires = encodeURIComponent(expiresAt);
  const encodedSignature = encodeURIComponent(signature);

  return {
    playback_url_or_token_reference: `${origin}/v1/playback/hls/${encodeURIComponent(job.id)}/master.m3u8?expires_at=${encodedExpires}&signature=${encodedSignature}`,
    expires_at: expiresAt,
    refresh_after: refreshAfter,
    processing_job_id: job.id,
    hls_master_object_key: output.hls_master_object_key
  };
}

export function processedPlaybackManifest(
  jobID: string,
  expiresAt: string | null,
  signature: string | null
): { statusCode: number; contentType: string; body: string } {
  const job = processingJobs.get(jobID);
  if (!job || job.state !== "completed" || !job.output) {
    return { statusCode: 404, contentType: "application/json", body: JSON.stringify({ error: "processed_playback_not_found" }) };
  }
  if (!expiresAt || !signature || Date.parse(expiresAt) <= Date.now() || signature !== playbackSignature(job, expiresAt)) {
    return { statusCode: 403, contentType: "application/json", body: JSON.stringify({ error: "playback_signature_invalid_or_expired" }) };
  }
  return {
    statusCode: 200,
    contentType: "application/vnd.apple.mpegurl",
    body: "#EXTM3U\n#EXT-X-VERSION:7\n#EXT-X-STREAM-INF:BANDWIDTH=4500000,RESOLUTION=1920x1080,CODECS=\"avc1.640028,mp4a.40.2\"\nvariant-1080p.m3u8\n"
  };
}

export async function createProcessingJob(authorizationHeader: string | undefined, body: unknown): Promise<JsonObject> {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const input = parseProcessingJobInput(body);
  const asset = uploadedAssetForProcessing(authorizationHeader, input.asset_id);

  const existingJobID = assetJobIndex.get(asset.id);
  if (existingJobID) {
    const existing = processingJobs.get(existingJobID);
    if (existing?.state === "completed") {
      return {
        status: "completed",
        idempotent: true,
        job: sanitizeProcessingJob(existing),
        detail: "Processing output already exists for this uploaded asset."
      };
    }
  }

  const now = nowISO();
  const job: ProcessingJobRecord = {
    id: `processing-job-${randomUUID()}`,
    asset_id: asset.id,
    project_id: asset.project_id,
    creator_id: asset.creator_id,
    source_object_key: asset.object_key,
    state: "queued",
    progress: 0,
    created_at: now,
    updated_at: now,
    completed_at: null,
    failure_reason: null,
    retry_count: 0,
    inspection: null,
    output: null,
    logs: [`${now} queued ${asset.filename}`]
  };
  processingJobs.set(job.id, job);
  assetJobIndex.set(asset.id, job.id);

  await runProcessingJob(job, asset);
  if (job.state === "completed") {
    recordAnalyticsEvent("processing_complete", {
      asset_id: asset.id,
      output_state: job.output?.output_state ?? "unknown"
    }, {
      identitySession: session,
      creatorID: job.creator_id,
      projectID: job.project_id,
      source: "media_processing"
    });
    recordProductNotification({
      role: "creator",
      category: "processing",
      title: "Media processing complete",
      body: `${asset.filename} produced playback-ready output for ${job.project_id}.`,
      deepLink: "highfive://creator/processing"
    });
  }
  return {
    status: job.state,
    idempotent: false,
    job: sanitizeProcessingJob(job),
    detail: job.state === "completed" ? "Uploaded asset processed into local HLS output records." : "Processing job failed."
  };
}

export function listProcessingJobs(authorizationHeader: string | undefined): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const jobs = Array.from(processingJobs.values()).filter((job) => session.role === "admin" || job.creator_id === session.creator_id);
  return {
    status: "ready",
    jobs: jobs.map(sanitizeProcessingJob)
  };
}

export async function retryProcessingJob(authorizationHeader: string | undefined, jobID: string): Promise<JsonObject> {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const job = processingJobs.get(jobID);
  if (!job) throw new ContractError("processing_job_not_found", "Processing job was not found.", 404);
  if (session.role !== "admin" && job.creator_id !== session.creator_id) {
    throw new ContractError("processing_job_forbidden", "Processing job belongs to another creator.", 403);
  }
  const asset = uploadedAssetForProcessing(authorizationHeader, job.asset_id);
  job.retry_count += 1;
  job.state = "queued";
  job.progress = 0;
  job.failure_reason = null;
  job.logs.push(`${nowISO()} retry requested`);
  await runProcessingJob(job, asset);
  const completed = (job as ProcessingJobRecord).state === "completed";
  if (completed) {
    recordAnalyticsEvent("processing_complete", {
      asset_id: asset.id,
      retry_count: job.retry_count,
      output_state: job.output?.output_state ?? "unknown"
    }, {
      identitySession: session,
      creatorID: job.creator_id,
      projectID: job.project_id,
      source: "media_processing_retry"
    });
    recordProductNotification({
      role: "creator",
      category: "processing",
      title: "Processing retry complete",
      body: `${asset.filename} completed after retry for ${job.project_id}.`,
      deepLink: "highfive://creator/processing"
    });
  }
  return {
    status: job.state,
    job: sanitizeProcessingJob(job),
    detail: completed ? "Processing retry completed." : "Processing retry failed."
  };
}

export function resetProcessingJobsForTests(): void {
  processingJobs.clear();
  assetJobIndex.clear();
}

async function runProcessingJob(job: ProcessingJobRecord, asset: UploadedAssetRecord): Promise<void> {
  try {
    transition(job, "inspecting", 20, "ffprobe inspection contract started");
    job.inspection = inspectAsset(asset);
    validateInspection(job.inspection);

    transition(job, "processing", 55, "ffmpeg processing contract started");
    job.output = await createHLSOutput(job, asset);

    transition(job, "completed", 100, "HLS output and metadata records created");
    job.completed_at = nowISO();
  } catch (error) {
    job.state = "failed";
    job.progress = 100;
    job.updated_at = nowISO();
    job.failure_reason = error instanceof Error ? error.message : "Unknown processing error";
    job.logs.push(`${job.updated_at} failed ${job.failure_reason}`);
  }
}

function inspectAsset(asset: UploadedAssetRecord): JsonObject {
  const isVideo = asset.asset_kind === "source_video" || asset.asset_kind === "trailer" || asset.content_type.startsWith("video/");
  const isImage = asset.asset_kind === "poster" || asset.asset_kind === "artwork" || asset.content_type.startsWith("image/");
  return {
    file_size_bytes: asset.size_bytes,
    duration_seconds: isVideo ? Math.max(12, Math.min(7200, Math.round(asset.size_bytes / 128))) : 0,
    dimensions: isVideo ? { width: 1920, height: 1080 } : { width: 1080, height: 1600 },
    aspect_ratio: isVideo ? "16:9" : "27:40",
    frame_rate: isVideo ? 24 : null,
    video_codec: isVideo ? "h264_contract" : null,
    audio_codec: isVideo ? "aac_contract" : null,
    audio_channel_count: isVideo ? 2 : 0,
    has_video_track: isVideo || isImage,
    has_audio_track: isVideo,
    ffprobe_contract: "local_scaffold",
    warning_count: isVideo ? 0 : 1,
    warnings: isVideo ? [] : ["Image asset inspected as poster/artwork; HLS derivatives require source video."]
  };
}

function validateInspection(inspection: JsonObject): void {
  if (inspection.has_video_track !== true) {
    throw new ContractError("processing_invalid_media", "Uploaded asset does not contain a usable visual track.", 422);
  }
}

async function createHLSOutput(job: ProcessingJobRecord, asset: UploadedAssetRecord): Promise<JsonObject> {
  const packageKey = [
    sanitizeSegment(asset.creator_id ?? "creator"),
    sanitizeSegment(asset.project_id),
    "processing",
    sanitizeSegment(job.id)
  ].join("/");
  const outputDir = path.join(uploadObjectStoreRoot(), packageKey);
  const masterKey = `${packageKey}/master.m3u8`;
  const variantKey = `${packageKey}/variant-1080p.m3u8`;
  const thumbnailKey = `${packageKey}/thumbnail-manifest.json`;
  await mkdir(outputDir, { recursive: true });
  const variantManifest = "#EXTM3U\n#EXT-X-VERSION:7\n#EXT-X-TARGETDURATION:6\n#EXTINF:6.0,\nsegment-00001.ts\n#EXT-X-ENDLIST\n";
  const masterManifest = "#EXTM3U\n#EXT-X-VERSION:7\n#EXT-X-STREAM-INF:BANDWIDTH=4500000,RESOLUTION=1920x1080,CODECS=\"avc1.640028,mp4a.40.2\"\nvariant-1080p.m3u8\n";
  await writeFile(path.join(uploadObjectStoreRoot(), variantKey), variantManifest);
  await writeFile(path.join(uploadObjectStoreRoot(), masterKey), masterManifest);
  await writeFile(path.join(uploadObjectStoreRoot(), thumbnailKey), JSON.stringify({ source_asset_id: asset.id, generated: true }, null, 2));
  const checksum = createHash("sha256").update(`${asset.checksum_sha256}:${job.id}:${masterManifest}`).digest("hex");
  return {
    output_state: "playback_ready",
    package_version: "hls_contract_v1",
    hls_master_object_key: masterKey,
    variants: [
      { quality: "1080p", object_key: variantKey, bandwidth: 4500000, codec: "h264_contract" }
    ],
    poster_variant_object_key: thumbnailKey,
    captions: [],
    audio_tracks: [{ language: "en", codec: "aac_contract", channels: 2 }],
    package_checksum_sha256: checksum,
    idempotency_key: `${asset.id}:${asset.checksum_sha256}`,
    storage_provider: "local_object_store",
    ffmpeg_contract: "local_scaffold"
  };
}

function transition(job: ProcessingJobRecord, state: ProcessingState, progress: number, message: string): void {
  job.state = state;
  job.progress = progress;
  job.updated_at = nowISO();
  job.logs.push(`${job.updated_at} ${message}`);
}

function sanitizeProcessingJob(job: ProcessingJobRecord): JsonObject {
  return { ...job };
}

function completedProcessingJobForMovie(movieID: string): ProcessingJobRecord | null {
  const projectID = movieProjectIDs.get(movieID);
  const completedJobs = Array.from(processingJobs.values())
    .filter((job) => job.state === "completed" && job.output)
    .sort((lhs, rhs) => (rhs.completed_at ?? rhs.updated_at).localeCompare(lhs.completed_at ?? lhs.updated_at));
  if (projectID) {
    return completedJobs.find((job) => job.project_id === projectID) ?? completedJobs[0] ?? null;
  }
  return completedJobs[0] ?? null;
}

function playbackSignature(job: ProcessingJobRecord, expiresAt: string): string {
  const checksum = typeof job.output?.package_checksum_sha256 === "string" ? job.output.package_checksum_sha256 : job.id;
  return createHash("sha256").update(`${job.id}:${expiresAt}:${checksum}`).digest("hex");
}

function parseProcessingJobInput(body: unknown): { asset_id: string } {
  if (!isRecord(body)) throw new ContractError("invalid_processing_job", "Processing job request must be a JSON object.", 400);
  const assetID = stringField(body, "asset_id");
  if (!assetID) throw new ContractError("invalid_processing_job", "asset_id is required.", 422);
  return { asset_id: assetID };
}

function sanitizeSegment(value: string): string {
  return value.toLowerCase().replace(/[^a-z0-9._-]+/g, "-").replace(/(^-|-$)/g, "") || "processing";
}

function nowISO(): string {
  return new Date().toISOString();
}

function isRecord(value: unknown): value is JsonObject {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function stringField(body: JsonObject, key: string): string | null {
  const value = body[key];
  return typeof value === "string" ? value.trim() : null;
}
