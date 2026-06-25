import { catalogSeed } from "../catalog/catalogSeed.js";
import type { JsonObject } from "../contracts.js";
import { ContractError } from "../errors.js";
import { requireCreatorIdentitySession, type IdentitySession } from "./identity.js";

type ReleaseState = "draft" | "review" | "scheduled" | "published" | "archived";
type RevisionAction = "created" | "updated" | "archived" | "restored";

type DraftRevisionRecord = {
  id: string;
  project_id: string;
  version: number;
  action: RevisionAction;
  actor_user_id: string;
  detail: string;
  created_at: string;
};

type DraftSyncAuditRecord = {
  id: string;
  project_id: string;
  action: string;
  user_id: string;
  role: string;
  result: string;
  detail: string;
  created_at: string;
};

type PublishingDraftRecord = {
  id: string;
  owner_user_id: string;
  creator_id: string;
  content_id: string;
  title: string;
  description: string;
  creator: string;
  genre: string;
  tags: string[];
  runtime: string;
  release_state: ReleaseState;
  poster_asset_name: string | null;
  poster_status: string;
  trailer_status: string;
  metadata_status: string;
  artwork_status: string;
  version: number;
  updated_at_label: string;
  updated_at: string;
  archived_at: string | null;
  project_members: JsonObject[];
  revisions: DraftRevisionRecord[];
};

const drafts = new Map<string, PublishingDraftRecord>();
const syncQueue: DraftSyncAuditRecord[] = [];
let draftCounter = 1;
let revisionCounter = 1;
let auditCounter = 1;

seedDrafts();

export function publishingReadinessSummary(): JsonObject {
  return {
    creator_draft_sync_enabled: true,
    optimistic_concurrency: true,
    conflict_detection: true,
    revision_history: true,
    role_enforcement: true,
    offline_queue_contract: true
  };
}

export function listCreatorDrafts(authorizationHeader: string | undefined): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const records = accessibleDrafts(session);
  recordAudit("list", session, "all", "allowed", `Returned ${records.length} creator drafts.`);
  return {
    status: "ready",
    drafts: records.map(sanitizeDraft),
    revision_count: records.reduce((count, record) => count + record.revisions.length, 0),
    sync_queue: syncQueue.slice(-10),
    detail: "Creator drafts resolved through publishing persistence."
  };
}

export function getCreatorDraft(authorizationHeader: string | undefined, draftID: string): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const draft = requireDraftAccess(session, draftID);
  recordAudit("get", session, draft.id, "allowed", "Draft loaded for creator workspace.");
  return {
    status: "ready",
    draft: sanitizeDraft(draft),
    revisions: draft.revisions
  };
}

export function createCreatorDraftRemote(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const input = parseDraftInput(body);
  validateDraftInput(input);

  const creatorID = stringField(body, "creator_id") ?? session.creator_id ?? catalogSeed.creators[0]?.id ?? "local-creator";
  const creator = catalogSeed.creators.find((record) => record.id === creatorID);
  const now = nowISO();
  const draft: PublishingDraftRecord = {
    id: stringField(body, "id") ?? `remote-draft-${draftCounter++}`,
    owner_user_id: session.user_id,
    creator_id: creatorID,
    content_id: stringField(body, "content_id") ?? `content-${slug(input.title)}`,
    title: input.title,
    description: input.description,
    creator: input.creator || creator?.name || session.display_name,
    genre: input.genre,
    tags: input.tags,
    runtime: input.runtime,
    release_state: "draft",
    poster_asset_name: stringField(body, "poster_asset_name"),
    poster_status: input.poster_status,
    trailer_status: input.trailer_status,
    metadata_status: input.metadata_status,
    artwork_status: input.artwork_status,
    version: 1,
    updated_at_label: "Remote draft created",
    updated_at: now,
    archived_at: null,
    project_members: membershipFor(session),
    revisions: []
  };
  draft.revisions.push(revision(draft.id, draft.version, "created", session, "Draft created through remote publishing repository."));
  drafts.set(draft.id, draft);
  recordAudit("create", session, draft.id, "allowed", "Remote draft created.");
  return {
    status: "created",
    draft: sanitizeDraft(draft),
    revisions: draft.revisions,
    audit_records: syncQueue.slice(-5)
  };
}

export function updateCreatorDraftRemote(authorizationHeader: string | undefined, draftID: string, body: unknown): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const draft = requireDraftAccess(session, draftID);
  assertExpectedVersion(draft, body);
  const input = parseDraftInput(body);
  validateDraftInput(input);

  draft.title = input.title;
  draft.description = input.description;
  draft.creator = input.creator || draft.creator;
  draft.genre = input.genre;
  draft.tags = input.tags;
  draft.runtime = input.runtime;
  draft.poster_asset_name = stringField(body, "poster_asset_name") ?? draft.poster_asset_name;
  draft.poster_status = input.poster_status;
  draft.trailer_status = input.trailer_status;
  draft.metadata_status = input.metadata_status;
  draft.artwork_status = input.artwork_status;
  draft.version += 1;
  draft.updated_at_label = "Remote draft updated";
  draft.updated_at = nowISO();
  draft.revisions.push(revision(draft.id, draft.version, "updated", session, "Draft updated with optimistic concurrency."));
  recordAudit("update", session, draft.id, "allowed", `Draft updated to version ${draft.version}.`);
  return {
    status: "updated",
    draft: sanitizeDraft(draft),
    revisions: draft.revisions,
    audit_records: syncQueue.slice(-5)
  };
}

export function archiveCreatorDraftRemote(authorizationHeader: string | undefined, draftID: string, body: unknown): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const draft = requireDraftAccess(session, draftID);
  assertExpectedVersion(draft, body);
  draft.release_state = "archived";
  draft.archived_at = nowISO();
  draft.version += 1;
  draft.updated_at_label = "Remote draft archived";
  draft.updated_at = draft.archived_at;
  draft.revisions.push(revision(draft.id, draft.version, "archived", session, "Draft archived by creator workspace."));
  recordAudit("archive", session, draft.id, "allowed", "Draft archived.");
  return {
    status: "archived",
    draft: sanitizeDraft(draft),
    revisions: draft.revisions,
    audit_records: syncQueue.slice(-5)
  };
}

export function restoreCreatorDraftRemote(authorizationHeader: string | undefined, draftID: string, body: unknown): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const draft = requireDraftAccess(session, draftID);
  assertExpectedVersion(draft, body);
  draft.release_state = "draft";
  draft.archived_at = null;
  draft.version += 1;
  draft.updated_at_label = "Remote draft restored";
  draft.updated_at = nowISO();
  draft.revisions.push(revision(draft.id, draft.version, "restored", session, "Draft restored into active workspace."));
  recordAudit("restore", session, draft.id, "allowed", "Draft restored.");
  return {
    status: "restored",
    draft: sanitizeDraft(draft),
    revisions: draft.revisions,
    audit_records: syncQueue.slice(-5)
  };
}

export function creatorDraftRevisionHistory(authorizationHeader: string | undefined, draftID: string): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const draft = requireDraftAccess(session, draftID);
  recordAudit("revisions", session, draft.id, "allowed", "Revision history inspected.");
  return {
    status: "ready",
    project_id: draft.id,
    version: draft.version,
    revisions: draft.revisions,
    audit_records: syncQueue.slice(-5)
  };
}

export function creatorDraftSyncQueue(authorizationHeader: string | undefined): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const records = syncQueue.filter((record) => record.user_id === session.user_id || session.role === "admin").slice(-20);
  recordAudit("queue", session, "all", "allowed", `Returned ${records.length} sync queue audit records.`);
  return {
    status: "ready",
    queued_edits: records,
    offline_edits_supported: true,
    retry_supported: true,
    merge_strategy: "server_version_wins_until_creator_resolves_conflict"
  };
}

function seedDrafts(): void {
  if (drafts.size > 0) return;
  for (const project of catalogSeed.publishing_projects) {
    const creator = catalogSeed.creators.find((record) => record.id === project.creator_id);
    const movie = catalogSeed.movies.find((record) => record.id === project.content_id);
    const draft: PublishingDraftRecord = {
      id: project.id,
      owner_user_id: "local-creator",
      creator_id: project.creator_id,
      content_id: project.content_id,
      title: project.title,
      description: movie?.synopsis ?? "Seeded creator project.",
      creator: creator?.name ?? "HighFive Creator",
      genre: movie?.genres[0] ?? "Creator",
      tags: movie?.genres ?? ["Creator"],
      runtime: movie?.duration ?? "38m",
      release_state: project.release_state,
      poster_asset_name: movie?.poster_asset_name ?? null,
      poster_status: project.poster_status,
      trailer_status: project.trailer_status,
      metadata_status: project.metadata_status,
      artwork_status: project.artwork_status,
      version: 1,
      updated_at_label: "Seeded backend project",
      updated_at: catalogSeed.generated_at,
      archived_at: null,
      project_members: [{ user_id: "local-creator", role: "owner", permission: "edit" }],
      revisions: []
    };
    draft.revisions.push({
      id: `draft-revision-${revisionCounter++}`,
      project_id: draft.id,
      version: draft.version,
      action: "created",
      actor_user_id: "system",
      detail: "Seeded from catalog project.",
      created_at: catalogSeed.generated_at
    });
    drafts.set(draft.id, draft);
  }
}

function accessibleDrafts(session: IdentitySession): PublishingDraftRecord[] {
  return Array.from(drafts.values()).filter((draft) => canAccessDraft(session, draft));
}

function requireDraftAccess(session: IdentitySession, draftID: string): PublishingDraftRecord {
  const draft = drafts.get(draftID);
  if (!draft) throw new ContractError("draft_not_found", "Creator draft was not found.", 404);
  if (!canAccessDraft(session, draft)) {
    recordAudit("access_denied", session, draftID, "denied", "Creator session does not own this project.");
    const error = new Error("creator_project_access_denied");
    error.name = "ForbiddenIdentityAccess";
    throw error;
  }
  return draft;
}

function canAccessDraft(session: IdentitySession, draft: PublishingDraftRecord): boolean {
  if (session.role === "admin") return true;
  if (draft.owner_user_id === session.user_id) return true;
  if (draft.creator_id === session.creator_id) return true;
  return draft.project_members.some((member) => member.user_id === session.user_id);
}

function assertExpectedVersion(draft: PublishingDraftRecord, body: unknown): void {
  const version = numberField(body, "base_version");
  if (version === null) throw new ContractError("base_version_required", "Optimistic concurrency requires base_version.", 409);
  if (version !== draft.version) {
    throw new ContractError("draft_version_conflict", `Draft is version ${draft.version}; client sent ${version}.`, 409);
  }
}

function parseDraftInput(body: unknown): {
  title: string;
  description: string;
  creator: string;
  genre: string;
  tags: string[];
  runtime: string;
  poster_status: string;
  trailer_status: string;
  metadata_status: string;
  artwork_status: string;
} {
  return {
    title: stringField(body, "title") ?? "",
    description: stringField(body, "description") ?? "",
    creator: stringField(body, "creator") ?? "",
    genre: stringField(body, "genre") ?? "",
    tags: stringArrayField(body, "tags"),
    runtime: stringField(body, "runtime") ?? "",
    poster_status: stringField(body, "poster_status") ?? "missing",
    trailer_status: stringField(body, "trailer_status") ?? "missing",
    metadata_status: stringField(body, "metadata_status") ?? "missing",
    artwork_status: stringField(body, "artwork_status") ?? "missing"
  };
}

function validateDraftInput(input: ReturnType<typeof parseDraftInput>): void {
  if (input.title.trim().length < 2) throw new ContractError("draft_validation_failed", "Draft title is required.", 422);
  if (input.description.trim().length < 12) throw new ContractError("draft_validation_failed", "Draft description must describe the title.", 422);
  if (input.genre.trim().length < 2) throw new ContractError("draft_validation_failed", "Draft genre is required.", 422);
  if (input.runtime.trim().length < 2) throw new ContractError("draft_validation_failed", "Draft runtime is required.", 422);
  if (input.tags.length === 0) throw new ContractError("draft_validation_failed", "At least one draft tag is required.", 422);
}

function sanitizeDraft(draft: PublishingDraftRecord): JsonObject {
  return {
    id: draft.id,
    owner_user_id: draft.owner_user_id,
    creator_id: draft.creator_id,
    content_id: draft.content_id,
    title: draft.title,
    description: draft.description,
    creator: draft.creator,
    genre: draft.genre,
    tags: draft.tags,
    runtime: draft.runtime,
    release_state: draft.release_state,
    poster_asset_name: draft.poster_asset_name,
    poster_status: draft.poster_status,
    trailer_status: draft.trailer_status,
    metadata_status: draft.metadata_status,
    artwork_status: draft.artwork_status,
    version: draft.version,
    updated_at_label: draft.updated_at_label,
    updated_at: draft.updated_at,
    archived_at: draft.archived_at,
    project_members: draft.project_members
  };
}

function revision(projectID: string, version: number, action: RevisionAction, session: IdentitySession, detail: string): DraftRevisionRecord {
  return {
    id: `draft-revision-${revisionCounter++}`,
    project_id: projectID,
    version,
    action,
    actor_user_id: session.user_id,
    detail,
    created_at: nowISO()
  };
}

function recordAudit(action: string, session: IdentitySession, projectID: string, result: string, detail: string): void {
  syncQueue.push({
    id: `draft-sync-audit-${auditCounter++}`,
    project_id: projectID,
    action,
    user_id: session.user_id,
    role: session.role,
    result,
    detail,
    created_at: nowISO()
  });
  if (syncQueue.length > 100) syncQueue.splice(0, syncQueue.length - 100);
}

function membershipFor(session: IdentitySession): JsonObject[] {
  return [
    { user_id: session.user_id, role: "owner", permission: "edit" },
    { user_id: "local-admin", role: "admin", permission: "review" }
  ];
}

function stringField(body: unknown, key: string): string | null {
  if (!isRecord(body)) return null;
  const value = body[key];
  return typeof value === "string" ? value : null;
}

function numberField(body: unknown, key: string): number | null {
  if (!isRecord(body)) return null;
  const value = body[key];
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}

function stringArrayField(body: unknown, key: string): string[] {
  if (!isRecord(body)) return [];
  const value = body[key];
  if (!Array.isArray(value)) return [];
  return value.filter((item): item is string => typeof item === "string" && item.trim().length > 0);
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function slug(value: string): string {
  return value.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "") || "draft";
}

function nowISO(): string {
  return new Date().toISOString();
}
