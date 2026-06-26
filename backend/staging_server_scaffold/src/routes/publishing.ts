import { catalogSeed, type CatalogCollection, type CatalogMovie, type CatalogSeed } from "../catalog/catalogSeed.js";
import type { JsonObject } from "../contracts.js";
import { ContractError } from "../errors.js";
import { recordAnalyticsEvent } from "./analytics.js";
import { requireCreatorIdentitySession, requireIdentitySession, type IdentitySession } from "./identity.js";
import { recordProductNotification } from "./notifications.js";

type ReleaseState = "draft" | "review" | "scheduled" | "published" | "archived";
type RevisionAction =
  | "created"
  | "updated"
  | "archived"
  | "restored"
  | "submitted"
  | "withdrawn"
  | "revision_requested"
  | "approved"
  | "rejected"
  | "scheduled"
  | "published"
  | "unpublished";

type ReviewStatus = "pending_review" | "needs_revision" | "approved" | "rejected" | "scheduled" | "published" | "unpublished" | "archived";

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

type PublishingReviewRecord = {
  id: string;
  project_id: string;
  content_id: string;
  creator_id: string;
  title: string;
  status: ReviewStatus;
  submitted_at: string | null;
  reviewed_at: string | null;
  scheduled_for: string | null;
  reviewer_user_id: string | null;
  creator_note: string | null;
  admin_note: string | null;
  revision_request: string | null;
  catalog_visible: boolean;
  version: number;
};

const drafts = new Map<string, PublishingDraftRecord>();
const reviews = new Map<string, PublishingReviewRecord>();
const syncQueue: DraftSyncAuditRecord[] = [];
let draftCounter = 1;
let revisionCounter = 1;
let auditCounter = 1;
let reviewCounter = 1;

seedDrafts();

export function publishingReadinessSummary(): JsonObject {
  return {
    creator_draft_sync_enabled: true,
    optimistic_concurrency: true,
    conflict_detection: true,
    revision_history: true,
    role_enforcement: true,
    offline_queue_contract: true,
    submit_for_review: true,
    withdraw_submission: true,
    admin_review_queue: true,
    request_revision: true,
    approve: true,
    reject: true,
    schedule: true,
    publish: true,
    unpublish: true,
    archive_reviewed_project: true,
    processing_readiness_gate: true,
    rights_readiness_gate: true,
    approve_reject_schedule_publish: true,
    catalog_visibility_transaction: true,
    review_audit_log: true
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

export function submitCreatorDraftForReview(authorizationHeader: string | undefined, draftID: string, body: unknown): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const draft = requireDraftAccess(session, draftID);
  assertExpectedVersion(draft, body);
  assertReviewReady(draft);
  draft.release_state = "review";
  draft.version += 1;
  draft.updated_at = nowISO();
  draft.updated_at_label = "Submitted for admin review";
  draft.revisions.push(revision(draft.id, draft.version, "submitted", session, noteField(body) ?? "Submitted for review."));
  const review = upsertReview(draft, {
    status: "pending_review",
    submitted_at: draft.updated_at,
    reviewed_at: null,
    scheduled_for: null,
    reviewer_user_id: null,
    creator_note: noteField(body),
    admin_note: null,
    revision_request: null,
    catalog_visible: false
  });
  recordAudit("submit_for_review", session, draft.id, "allowed", "Creator submitted project for admin review.");
  return mutationResponse("submitted_for_review", draft, session, review);
}

export function withdrawCreatorReviewSubmission(authorizationHeader: string | undefined, draftID: string, body: unknown): JsonObject {
  const session = requireCreatorIdentitySession(authorizationHeader);
  const draft = requireDraftAccess(session, draftID);
  assertExpectedVersion(draft, body);
  if (draft.release_state !== "review") {
    throw new ContractError("draft_not_in_review", "Only projects in review can be withdrawn.", 409);
  }
  draft.release_state = "draft";
  draft.version += 1;
  draft.updated_at = nowISO();
  draft.updated_at_label = "Review submission withdrawn";
  draft.revisions.push(revision(draft.id, draft.version, "withdrawn", session, noteField(body) ?? "Review submission withdrawn by creator."));
  const review = upsertReview(draft, {
    status: "needs_revision",
    reviewed_at: draft.updated_at,
    reviewer_user_id: session.user_id,
    creator_note: noteField(body),
    admin_note: "Creator withdrew the review submission.",
    revision_request: "Creator returned project to draft before admin decision.",
    catalog_visible: false
  });
  recordAudit("withdraw_submission", session, draft.id, "allowed", "Creator withdrew project from review.");
  return mutationResponse("withdrawn", draft, session, review);
}

export function adminReviewQueue(authorizationHeader: string | undefined): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  const records = Array.from(reviews.values())
    .filter((record) => record.status !== "archived")
    .sort((a, b) => (b.submitted_at ?? "").localeCompare(a.submitted_at ?? ""));
  recordAudit("admin_review_queue", session, "all", "allowed", `Returned ${records.length} review records.`);
  return {
    status: "ready",
    review_queue: records.map(sanitizeReview),
    pending_count: records.filter((record) => record.status === "pending_review").length,
    approved_count: records.filter((record) => record.status === "approved").length,
    published_count: records.filter((record) => record.status === "published").length,
    audit_records: syncQueue.slice(-20)
  };
}

export function adminReviewAuditTrail(authorizationHeader: string | undefined): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  recordAudit("admin_review_audit", session, "all", "allowed", "Admin inspected publishing review audit trail.");
  return {
    status: "ready",
    audit_records: syncQueue.slice(-50),
    review_queue: Array.from(reviews.values()).map(sanitizeReview)
  };
}

export function adminRequestRevision(authorizationHeader: string | undefined, draftID: string, body: unknown): JsonObject {
  return adminReviewMutation(authorizationHeader, draftID, body, "revision_requested", "needs_revision", "review", false);
}

export function adminApproveProject(authorizationHeader: string | undefined, draftID: string, body: unknown): JsonObject {
  return adminReviewMutation(authorizationHeader, draftID, body, "approved", "approved", "review", false);
}

export function adminRejectProject(authorizationHeader: string | undefined, draftID: string, body: unknown): JsonObject {
  return adminReviewMutation(authorizationHeader, draftID, body, "rejected", "rejected", "review", false);
}

export function adminScheduleProject(authorizationHeader: string | undefined, draftID: string, body: unknown): JsonObject {
  const scheduledFor = stringField(body, "scheduled_for") ?? new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();
  return adminReviewMutation(authorizationHeader, draftID, body, "scheduled", "scheduled", "scheduled", false, scheduledFor);
}

export function adminPublishProject(authorizationHeader: string | undefined, draftID: string, body: unknown): JsonObject {
  return adminReviewMutation(authorizationHeader, draftID, body, "published", "published", "published", true);
}

export function adminUnpublishProject(authorizationHeader: string | undefined, draftID: string, body: unknown): JsonObject {
  return adminReviewMutation(authorizationHeader, draftID, body, "unpublished", "unpublished", "review", false);
}

export function adminArchiveProject(authorizationHeader: string | undefined, draftID: string, body: unknown): JsonObject {
  return adminReviewMutation(authorizationHeader, draftID, body, "archived", "archived", "archived", false);
}

export function canAccessCreatorProject(session: IdentitySession, projectID: string): boolean {
  if (session.role === "admin") return true;
  return accessibleDrafts(session).some((draft) => draft.id === projectID);
}

export function governedCatalogSeed(seed: CatalogSeed = catalogSeed): CatalogSeed {
  const publishedDrafts = Array.from(drafts.values()).filter((draft) => {
    const review = reviews.get(draft.id);
    return draft.release_state === "published" && (review?.catalog_visible ?? true);
  });
  const movies = uniqueByID([...seed.movies, ...publishedDrafts.map(catalogMovieFromDraft)]);
  const creatorPublishedIDs = unique([
    ...(seed.collections.find((collection) => collection.id === "creator-published")?.movie_ids ?? []),
    ...publishedDrafts.map((draft) => draft.content_id)
  ]);
  const collections = seed.collections.map((collection): CatalogCollection => {
    if (collection.id === "creator-published") return { ...collection, movie_ids: creatorPublishedIDs };
    return collection;
  });
  if (!collections.some((collection) => collection.id === "creator-published")) {
    collections.push({
      id: "creator-published",
      title: "Creator Published",
      subtitle: "Governed published creator projects",
      movie_ids: creatorPublishedIDs
    });
  }
  return {
    ...seed,
    movies,
    collections
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
    if (draft.release_state === "published" || draft.release_state === "review" || draft.release_state === "scheduled") {
      reviews.set(draft.id, {
        id: `review-${reviewCounter++}`,
        project_id: draft.id,
        content_id: draft.content_id,
        creator_id: draft.creator_id,
        title: draft.title,
        status: draft.release_state === "published" ? "published" : draft.release_state === "scheduled" ? "scheduled" : "pending_review",
        submitted_at: catalogSeed.generated_at,
        reviewed_at: draft.release_state === "published" ? catalogSeed.generated_at : null,
        scheduled_for: null,
        reviewer_user_id: draft.release_state === "published" ? "local-admin" : null,
        creator_note: "Seeded creator project.",
        admin_note: draft.release_state === "published" ? "Seeded project is visible in catalog." : null,
        revision_request: null,
        catalog_visible: draft.release_state === "published",
        version: draft.version
      });
    }
  }
}

function requireAdminSession(authorizationHeader: string | undefined): IdentitySession {
  const session = requireIdentitySession(authorizationHeader);
  if (session.role !== "admin") {
    recordAudit("admin_access_denied", session, "all", "denied", "Admin review workflow requires admin role.");
    const error = new Error("admin_role_required");
    error.name = "ForbiddenIdentityAccess";
    throw error;
  }
  return session;
}

function adminReviewMutation(
  authorizationHeader: string | undefined,
  draftID: string,
  body: unknown,
  action: RevisionAction,
  reviewStatus: ReviewStatus,
  releaseState: ReleaseState,
  catalogVisible: boolean,
  scheduledFor: string | null = null
): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  const draft = requireDraftAccess(session, draftID);
  assertAdminTransitionAllowed(draft, action);
  draft.release_state = releaseState;
  draft.version += 1;
  draft.updated_at = nowISO();
  draft.updated_at_label = labelFor(action);
  if (releaseState === "archived") draft.archived_at = draft.updated_at;
  if (action === "unpublished") draft.archived_at = null;
  const detail = noteField(body) ?? labelFor(action);
  draft.revisions.push(revision(draft.id, draft.version, action, session, detail));
  const review = upsertReview(draft, {
    status: reviewStatus,
    reviewed_at: draft.updated_at,
    scheduled_for: scheduledFor,
    reviewer_user_id: session.user_id,
    admin_note: detail,
    revision_request: action === "revision_requested" ? detail : null,
    catalog_visible: catalogVisible
  });
  recordAudit(action, session, draft.id, "allowed", `${labelFor(action)} Catalog visible: ${catalogVisible}.`);
  return mutationResponse(action, draft, session, review);
}

function assertAdminTransitionAllowed(draft: PublishingDraftRecord, action: RevisionAction): void {
  if (action === "published" && draft.release_state !== "review" && draft.release_state !== "scheduled") {
    throw new ContractError("publish_state_invalid", "Project must be in review or scheduled before publish.", 409);
  }
  if ((action === "approved" || action === "rejected" || action === "revision_requested") && draft.release_state !== "review") {
    throw new ContractError("review_state_invalid", "Project must be in review for this admin decision.", 409);
  }
}

function assertReviewReady(draft: PublishingDraftRecord): void {
  const statuses = [draft.poster_status, draft.trailer_status, draft.metadata_status, draft.artwork_status].map((status) => status.toLowerCase());
  if (!statuses.every((status) => status === "ready")) {
    throw new ContractError("publishing_readiness_failed", "Poster, trailer, metadata, and artwork must be ready before review submission.", 422);
  }
}

function upsertReview(draft: PublishingDraftRecord, update: Partial<PublishingReviewRecord>): PublishingReviewRecord {
  const previous = reviews.get(draft.id);
  const review: PublishingReviewRecord = {
    id: previous?.id ?? `review-${reviewCounter++}`,
    project_id: draft.id,
    content_id: draft.content_id,
    creator_id: draft.creator_id,
    title: draft.title,
    status: update.status ?? previous?.status ?? "pending_review",
    submitted_at: update.submitted_at ?? previous?.submitted_at ?? null,
    reviewed_at: update.reviewed_at ?? previous?.reviewed_at ?? null,
    scheduled_for: update.scheduled_for ?? previous?.scheduled_for ?? null,
    reviewer_user_id: update.reviewer_user_id ?? previous?.reviewer_user_id ?? null,
    creator_note: update.creator_note ?? previous?.creator_note ?? null,
    admin_note: update.admin_note ?? previous?.admin_note ?? null,
    revision_request: update.revision_request ?? previous?.revision_request ?? null,
    catalog_visible: update.catalog_visible ?? previous?.catalog_visible ?? false,
    version: draft.version
  };
  reviews.set(draft.id, review);
  return review;
}

function mutationResponse(status: string, draft: PublishingDraftRecord, session: IdentitySession, review: PublishingReviewRecord): JsonObject {
  if (["submitted_for_review", "withdrawn", "approved", "rejected", "scheduled", "published", "unpublished", "archived", "revision_requested"].includes(status)) {
    recordAnalyticsEvent("publishing_state_change", {
      status,
      release_state: draft.release_state,
      catalog_visible: review.catalog_visible
    }, {
      identitySession: session,
      contentID: draft.content_id,
      creatorID: draft.creator_id,
      projectID: draft.id,
      source: "publishing_review"
    });
    recordProductNotification({
      userID: draft.owner_user_id,
      role: "creator",
      category: status === "published" ? "release" : "publishing",
      title: status === "published" ? "Release published" : "Publishing review update",
      body: `${draft.title} moved to ${status.replaceAll("_", " ")}.`,
      deepLink: status === "published" ? "highfive://content/release" : "highfive://creator/publishing"
    });
  }
  return {
    status,
    draft: sanitizeDraft(draft),
    review: sanitizeReview(review),
    revisions: draft.revisions,
    audit_records: syncQueue.filter((record) => record.project_id === draft.id || session.role === "admin").slice(-12),
    catalog_visibility: review.catalog_visible ? "visible" : "private"
  };
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

function sanitizeReview(review: PublishingReviewRecord): JsonObject {
  return {
    id: review.id,
    project_id: review.project_id,
    content_id: review.content_id,
    creator_id: review.creator_id,
    title: review.title,
    status: review.status,
    submitted_at: review.submitted_at,
    reviewed_at: review.reviewed_at,
    scheduled_for: review.scheduled_for,
    reviewer_user_id: review.reviewer_user_id,
    creator_note: review.creator_note,
    admin_note: review.admin_note,
    revision_request: review.revision_request,
    catalog_visible: review.catalog_visible,
    version: review.version
  };
}

function catalogMovieFromDraft(draft: PublishingDraftRecord): CatalogMovie {
  return {
    id: draft.content_id,
    title: draft.title,
    subtitle: "Creator Published",
    synopsis: draft.description,
    year: "2026",
    rating: "NR",
    duration: draft.runtime,
    genres: unique([draft.genre, ...draft.tags]).filter(Boolean),
    poster_asset_name: draft.poster_asset_name,
    backdrop_asset_name: null,
    creator_id: draft.creator_id,
    creator_name: draft.creator,
    is_original: false,
    is_coming_soon: false,
    is_downloaded: false,
    progress: null,
    collection_ids: ["creator-published", slug(draft.genre)]
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

function labelFor(action: string): string {
  return action.split("_").map((part) => part.slice(0, 1).toUpperCase() + part.slice(1)).join(" ");
}

function noteField(body: unknown): string | null {
  return stringField(body, "note") ?? stringField(body, "admin_note") ?? stringField(body, "creator_note");
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

function unique(values: string[]): string[] {
  return [...new Set(values)];
}

function uniqueByID<T extends { id: string }>(values: T[]): T[] {
  const seen = new Set<string>();
  return values.filter((value) => {
    if (seen.has(value.id)) return false;
    seen.add(value.id);
    return true;
  });
}
