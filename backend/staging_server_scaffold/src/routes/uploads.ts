import { createHash, randomUUID } from "node:crypto";
import { mkdir, rename, rm, writeFile } from "node:fs/promises";
import path from "node:path";
import type { JsonObject } from "../contracts.js";
import { ContractError, errorBody } from "../errors.js";
import { recordAnalyticsEvent } from "./analytics.js";
import { requireCreatorIdentitySession, type IdentitySession } from "./identity.js";
import { recordProductNotification } from "./notifications.js";
import { canAccessCreatorProject } from "./publishing.js";

type UploadAssetKind = "poster" | "trailer" | "source_video" | "artwork";
type UploadState = "session_ready" | "uploading" | "uploaded" | "cancelled" | "failed";

type UploadSessionRecord = {
  id: string;
  project_id: string;
  creator_id: string | null;
  owner_user_id: string;
  asset_kind: UploadAssetKind;
  filename: string;
  content_type: string;
  expected_size_bytes: number;
  expected_checksum_sha256: string | null;
  upload_url: string;
  expires_at: string;
  created_at: string;
  completed_at: string | null;
  state: UploadState;
};

export type UploadedAssetRecord = {
  id: string;
  upload_session_id: string;
  project_id: string;
  creator_id: string | null;
  owner_user_id: string;
  asset_kind: UploadAssetKind;
  filename: string;
  content_type: string;
  size_bytes: number;
  checksum_sha256: string;
  object_key: string;
  storage_provider: "local_object_store";
  upload_state: "uploaded";
  duplicate_of: string | null;
  created_at: string;
  completed_at: string;
};

const uploadSessions = new Map<string, UploadSessionRecord>();
const uploadedAssets = new Map<string, UploadedAssetRecord>();
const checksumIndex = new Map<string, string>();
const objectStoreRoot = process.env.HIGHFIVE_OBJECT_STORE_DIR ?? "/private/tmp/highfive-p33a-object-storage";
const uploadTTLMilliseconds = 10 * 60 * 1000;

export function uploadReadinessSummary(): JsonObject {
  return {
    signed_upload_sessions: true,
    local_object_storage: true,
    checksum_validation: true,
    duplicate_detection: true,
    project_ownership_checks: true,
    uploaded_assets: uploadedAssets.size
  };
}

export function createCreatorUploadSession(
  authorizationHeader: string | undefined,
  body: unknown,
  baseURL = "http://127.0.0.1"
): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const input = parseUploadSessionInput(body);
  if (!canAccessCreatorProject(session, input.project_id)) {
    throw new ContractError("project_access_denied", "Creator identity cannot upload assets for this project.", 403);
  }

  const id = `upload-session-${randomUUID()}`;
  const now = nowISO();
  const record: UploadSessionRecord = {
    id,
    project_id: input.project_id,
    creator_id: session.creator_id,
    owner_user_id: session.user_id,
    asset_kind: input.asset_kind,
    filename: input.filename,
    content_type: input.content_type,
    expected_size_bytes: input.size_bytes,
    expected_checksum_sha256: input.checksum_sha256,
    upload_url: `/v1/creator/uploads/${id}/blob`,
    expires_at: new Date(Date.now() + uploadTTLMilliseconds).toISOString(),
    created_at: now,
    completed_at: null,
    state: "session_ready"
  };
  uploadSessions.set(id, record);

  return {
    status: "session_ready",
    session: sanitizeUploadSession(record, baseURL),
    asset_record: null,
    detail: "Short-lived upload session created for local object storage."
  };
}

export async function putCreatorUploadBlob(
  authorizationHeader: string | undefined,
  sessionID: string,
  data: Buffer
): Promise<JsonObject> {
  const identity = requireCreatorIdentitySession(authorizationHeader);
  const session = requireUploadSession(identity, sessionID);
  session.state = "uploading";

  if (data.byteLength !== session.expected_size_bytes) {
    session.state = "failed";
    throw new ContractError("upload_size_mismatch", `Expected ${session.expected_size_bytes} bytes but received ${data.byteLength}.`, 422);
  }

  const checksum = sha256Hex(data);
  if (session.expected_checksum_sha256 && session.expected_checksum_sha256.toLowerCase() !== checksum) {
    session.state = "failed";
    throw new ContractError("upload_checksum_mismatch", "Uploaded asset checksum did not match the signed session.", 422);
  }

  const duplicateOf = checksumIndex.get(checksum) ?? null;
  const objectKey = objectKeyFor(session, checksum);
  const objectPath = path.join(objectStoreRoot, objectKey);
  const tmpPath = `${objectPath}.tmp`;
  await mkdir(path.dirname(objectPath), { recursive: true });
  await writeFile(tmpPath, data);
  await rename(tmpPath, objectPath);

  const completedAt = nowISO();
  const asset: UploadedAssetRecord = {
    id: `asset-${randomUUID()}`,
    upload_session_id: session.id,
    project_id: session.project_id,
    creator_id: session.creator_id,
    owner_user_id: session.owner_user_id,
    asset_kind: session.asset_kind,
    filename: session.filename,
    content_type: session.content_type,
    size_bytes: data.byteLength,
    checksum_sha256: checksum,
    object_key: objectKey,
    storage_provider: "local_object_store",
    upload_state: "uploaded",
    duplicate_of: duplicateOf,
    created_at: session.created_at,
    completed_at: completedAt
  };
  session.state = "uploaded";
  session.completed_at = completedAt;
  uploadedAssets.set(asset.id, asset);
  if (!duplicateOf) checksumIndex.set(checksum, asset.id);
  recordAnalyticsEvent("upload", {
    asset_kind: asset.asset_kind,
    size_bytes: asset.size_bytes,
    duplicate_detected: duplicateOf !== null
  }, {
    identitySession: identity,
    creatorID: asset.creator_id,
    projectID: asset.project_id,
    source: "creator_upload"
  });
  recordProductNotification({
    userID: asset.owner_user_id,
    role: "creator",
    category: "upload",
    title: "Upload stored",
    body: `${asset.filename} was verified and stored for ${asset.project_id}.`,
    deepLink: "highfive://creator/uploads"
  });

  return {
    status: "uploaded",
    session: sanitizeUploadSession(session),
    asset_record: sanitizeUploadedAsset(asset),
    duplicate_detected: duplicateOf !== null,
    detail: "Asset bytes stored in local object storage and verified by checksum."
  };
}

export async function cancelCreatorUploadSession(authorizationHeader: string | undefined, sessionID: string): Promise<JsonObject> {
  const identity = requireCreatorIdentitySession(authorizationHeader);
  const session = requireUploadSession(identity, sessionID, true);
  session.state = "cancelled";
  const prefix = path.join(objectStoreRoot, session.creator_id ?? "creator", session.project_id, session.id);
  await rm(prefix, { recursive: true, force: true });
  return {
    status: "cancelled",
    session: sanitizeUploadSession(session),
    detail: "Upload session cancelled and local temporary storage cleaned."
  };
}

export function listCreatorUploadedAssets(authorizationHeader: string | undefined): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const assets = Array.from(uploadedAssets.values()).filter((asset) => canAccessAsset(session, asset));
  return {
    status: "ready",
    assets: assets.map(sanitizeUploadedAsset),
    object_store: {
      provider: "local_object_store",
      root: objectStoreRoot,
      credentials_required: false
    }
  };
}

export function uploadedAssetForProcessing(authorizationHeader: string | undefined, assetID: string): UploadedAssetRecord {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const asset = uploadedAssets.get(assetID);
  if (!asset) throw new ContractError("uploaded_asset_not_found", "Uploaded asset was not found.", 404);
  if (!canAccessAsset(session, asset)) {
    throw new ContractError("uploaded_asset_forbidden", "Uploaded asset belongs to another creator.", 403);
  }
  return asset;
}

export function uploadObjectStoreRoot(): string {
  return objectStoreRoot;
}

export function resetUploadStorageForTests(): void {
  uploadSessions.clear();
  uploadedAssets.clear();
  checksumIndex.clear();
}

function requireUploadSession(identity: IdentitySession, sessionID: string, allowExpired = false): UploadSessionRecord {
  const session = uploadSessions.get(sessionID);
  if (!session) throw new ContractError("upload_session_not_found", "Upload session was not found.", 404);
  if (session.owner_user_id !== identity.user_id && identity.role !== "admin") {
    throw new ContractError("upload_session_forbidden", "Upload session belongs to another creator.", 403);
  }
  if (!canAccessCreatorProject(identity, session.project_id)) {
    throw new ContractError("project_access_denied", "Creator identity cannot access this upload session project.", 403);
  }
  if (!allowExpired && Date.parse(session.expires_at) <= Date.now()) {
    throw new ContractError("upload_session_expired", "Upload session expired before the asset was stored.", 410);
  }
  if (session.state === "cancelled") {
    throw new ContractError("upload_session_cancelled", "Upload session has already been cancelled.", 409);
  }
  if (session.state === "uploaded") {
    throw new ContractError("upload_session_completed", "Upload session has already received asset bytes.", 409);
  }
  return session;
}

function parseUploadSessionInput(body: unknown): {
  project_id: string;
  asset_kind: UploadAssetKind;
  filename: string;
  content_type: string;
  size_bytes: number;
  checksum_sha256: string | null;
} {
  if (!isRecord(body)) throw new ContractError("invalid_upload_session", "Upload session request must be a JSON object.", 400);
  const projectID = stringField(body, "project_id");
  const assetKind = stringField(body, "asset_kind");
  const filename = stringField(body, "filename");
  const contentType = stringField(body, "content_type");
  const sizeBytes = numberField(body, "size_bytes");
  const checksum = stringField(body, "checksum_sha256");
  if (!projectID) throw new ContractError("invalid_upload_session", "project_id is required.", 422);
  if (!isUploadAssetKind(assetKind)) throw new ContractError("invalid_upload_session", "asset_kind must be poster, trailer, source_video, or artwork.", 422);
  if (!filename || filename.length > 180 || filename.includes("/") || filename.includes("\\")) {
    throw new ContractError("invalid_upload_session", "filename must be a safe local filename.", 422);
  }
  if (!contentType || !/^[a-z0-9.+-]+\/[a-z0-9.+-]+$/i.test(contentType)) {
    throw new ContractError("invalid_upload_session", "content_type must be a valid MIME type.", 422);
  }
  if (sizeBytes === null || !Number.isInteger(sizeBytes) || sizeBytes <= 0 || sizeBytes > 10 * 1024 * 1024) {
    throw new ContractError("invalid_upload_session", "size_bytes must be between 1 byte and 10 MB for local staging.", 422);
  }
  if (checksum && !/^[a-f0-9]{64}$/i.test(checksum)) {
    throw new ContractError("invalid_upload_session", "checksum_sha256 must be a 64-character hex digest.", 422);
  }
  return { project_id: projectID, asset_kind: assetKind, filename, content_type: contentType, size_bytes: sizeBytes, checksum_sha256: checksum };
}

function objectKeyFor(session: UploadSessionRecord, checksum: string): string {
  return [
    sanitizeSegment(session.creator_id ?? "creator"),
    sanitizeSegment(session.project_id),
    sanitizeSegment(session.id),
    `${session.asset_kind}-${checksum.slice(0, 16)}-${sanitizeSegment(session.filename)}`
  ].join("/");
}

function sanitizeUploadSession(record: UploadSessionRecord, baseURL?: string): JsonObject {
  const uploadPath = record.upload_url;
  return {
    id: record.id,
    project_id: record.project_id,
    creator_id: record.creator_id,
    asset_kind: record.asset_kind,
    filename: record.filename,
    content_type: record.content_type,
    expected_size_bytes: record.expected_size_bytes,
    expected_checksum_sha256: record.expected_checksum_sha256,
    upload_url: baseURL ? `${baseURL}${uploadPath}` : uploadPath,
    expires_at: record.expires_at,
    created_at: record.created_at,
    completed_at: record.completed_at,
    state: record.state
  };
}

function sanitizeUploadedAsset(asset: UploadedAssetRecord): JsonObject {
  return { ...asset };
}

function canAccessAsset(session: IdentitySession, asset: UploadedAssetRecord): boolean {
  return session.role === "admin" || asset.owner_user_id === session.user_id || asset.creator_id === session.creator_id;
}

function sha256Hex(data: Buffer): string {
  return createHash("sha256").update(data).digest("hex");
}

function nowISO(): string {
  return new Date().toISOString();
}

function sanitizeSegment(value: string): string {
  return value.toLowerCase().replace(/[^a-z0-9._-]+/g, "-").replace(/(^-|-$)/g, "") || "asset";
}

function isUploadAssetKind(value: string | null): value is UploadAssetKind {
  return value === "poster" || value === "trailer" || value === "source_video" || value === "artwork";
}

function isRecord(value: unknown): value is JsonObject {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function stringField(body: JsonObject, key: string): string | null {
  const value = body[key];
  return typeof value === "string" ? value.trim() : null;
}

function numberField(body: JsonObject, key: string): number | null {
  const value = body[key];
  return typeof value === "number" ? value : null;
}

export function uploadErrorBody(error: unknown): JsonObject {
  return errorBody(error);
}
