import { catalogSeed, type CatalogMovie, type CatalogSeed } from "../catalog/catalogSeed.js";
import type { JsonObject } from "../contracts.js";
import { ContractError } from "../errors.js";
import { requireIdentitySession, type IdentitySession } from "./identity.js";

type RightsWindowState = "active" | "expired" | "scheduled" | "blocked";
type ModerationState = "open" | "cleared" | "needs_revision" | "takedown";
type ModerationDecision = "flagged" | "cleared" | "needs_revision" | "takedown" | "restored";

type RightsWindowRecord = {
  id: string;
  content_id: string;
  title: string;
  territories: string[];
  starts_at: string;
  ends_at: string;
  state: RightsWindowState;
  licensing_package_id: string;
  rights_holder: string;
  updated_at: string;
};

type ModerationCaseRecord = {
  id: string;
  content_id: string;
  title: string;
  category: string;
  state: ModerationState;
  policy_status: string;
  reviewer_user_id: string | null;
  note: string;
  updated_at: string;
};

type OperationsAuditRecord = {
  id: string;
  action: string;
  content_id: string | null;
  actor_user_id: string;
  role: string;
  result: string;
  detail: string;
  created_at: string;
};

const rightsWindows = new Map<string, RightsWindowRecord>();
const moderationCases = new Map<string, ModerationCaseRecord>();
const auditRecords: OperationsAuditRecord[] = [];
let moderationCounter = 1;
let auditCounter = 1;

seedOperations();

export function operationsReadinessSummary(): JsonObject {
  return {
    rights_windows: true,
    territory_enforcement: true,
    availability_enforcement: true,
    moderation_queue: true,
    takedown_supported: true,
    restore_supported: true,
    audit_trail: true,
    admin_role_enforcement: true,
    platform_health: true,
    external_moderation_service: false
  };
}

export function operationsSummary(authorizationHeader: string | undefined): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  recordAudit("operations_summary", session, null, "allowed", "Admin inspected rights, moderation, and platform operations.");
  return {
    status: "ready",
    rights_windows: Array.from(rightsWindows.values()).map(sanitizeRightsWindow),
    moderation_cases: Array.from(moderationCases.values()).map(sanitizeModerationCase),
    platform_health: platformHealth(),
    availability: catalogSeed.movies.map((movie) => availabilityRecord(movie.id, "US")),
    audit_records: auditRecords.slice(-25)
  };
}

export function rightsLedger(authorizationHeader: string | undefined): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  recordAudit("rights_ledger", session, null, "allowed", "Admin inspected rights windows and territory rules.");
  return {
    status: "ready",
    rights_windows: Array.from(rightsWindows.values()).map(sanitizeRightsWindow),
    availability: catalogSeed.movies.map((movie) => availabilityRecord(movie.id, "US"))
  };
}

export function moderationQueue(authorizationHeader: string | undefined): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  recordAudit("moderation_queue", session, null, "allowed", "Admin inspected moderation queue.");
  return {
    status: "ready",
    moderation_cases: Array.from(moderationCases.values()).map(sanitizeModerationCase),
    audit_records: auditRecords.slice(-20)
  };
}

export function flagContentForModeration(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  const contentID = requiredString(body, "content_id");
  const movie = requireMovie(contentID);
  const category = stringField(body, "category") ?? "Policy Review";
  const note = stringField(body, "note") ?? "Admin flagged content for moderation review.";
  const record = upsertModerationCase(movie, {
    category,
    state: "open",
    policy_status: "Flagged",
    reviewer_user_id: session.user_id,
    note
  });
  recordAudit("content_flagged", session, contentID, "allowed", note);
  return {
    status: "flagged",
    moderation_case: sanitizeModerationCase(record),
    availability: availabilityRecord(contentID, "US"),
    audit_records: auditRecords.slice(-8)
  };
}

export function decideModerationCase(authorizationHeader: string | undefined, caseID: string, action: string | null, body: unknown): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  const record = requireModerationCase(caseID);
  const decision = moderationDecision(action);
  const note = stringField(body, "note") ?? `Admin decision: ${decision}.`;
  switch (decision) {
  case "cleared":
    record.state = "cleared";
    record.policy_status = "Cleared";
    break;
  case "needs_revision":
    record.state = "needs_revision";
    record.policy_status = "Needs Revision";
    break;
  case "takedown":
    record.state = "takedown";
    record.policy_status = "Takedown";
    break;
  case "restored":
    record.state = "cleared";
    record.policy_status = "Restored";
    break;
  case "flagged":
    record.state = "open";
    record.policy_status = "Flagged";
    break;
  }
  record.reviewer_user_id = session.user_id;
  record.note = note;
  record.updated_at = nowISO();
  recordAudit(`moderation_${decision}`, session, record.content_id, "allowed", note);
  return {
    status: decision,
    moderation_case: sanitizeModerationCase(record),
    availability: availabilityRecord(record.content_id, "US"),
    audit_records: auditRecords.slice(-8)
  };
}

export function expireRightsWindow(authorizationHeader: string | undefined, contentID: string, body: unknown): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  const record = requireRightsWindow(contentID);
  record.state = "expired";
  record.ends_at = stringField(body, "ends_at") ?? "2026-01-01T00:00:00.000Z";
  record.updated_at = nowISO();
  recordAudit("rights_window_expired", session, contentID, "allowed", `${record.title} rights window expired.`);
  return {
    status: "expired",
    rights_window: sanitizeRightsWindow(record),
    availability: availabilityRecord(contentID, "US"),
    audit_records: auditRecords.slice(-8)
  };
}

export function restoreRightsWindow(authorizationHeader: string | undefined, contentID: string, body: unknown): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  const record = requireRightsWindow(contentID);
  record.state = "active";
  record.starts_at = stringField(body, "starts_at") ?? "2026-01-01T00:00:00.000Z";
  record.ends_at = stringField(body, "ends_at") ?? "2027-12-31T23:59:59.000Z";
  record.updated_at = nowISO();
  recordAudit("rights_window_restored", session, contentID, "allowed", `${record.title} rights window restored.`);
  return {
    status: "restored",
    rights_window: sanitizeRightsWindow(record),
    availability: availabilityRecord(contentID, "US"),
    audit_records: auditRecords.slice(-8)
  };
}

export function operationsAuditTrail(authorizationHeader: string | undefined): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  recordAudit("operations_audit", session, null, "allowed", "Admin inspected platform operations audit trail.");
  return {
    status: "ready",
    audit_records: auditRecords.slice(-50),
    platform_health: platformHealth()
  };
}

export function availabilityRecord(contentID: string, territory = "US"): JsonObject {
  const movie = catalogSeed.movies.find((candidate) => candidate.id === contentID);
  const rights = rightsWindows.get(contentID);
  const moderation = Array.from(moderationCases.values()).find((record) => record.content_id === contentID && record.state === "takedown");
  const deniedReasons: string[] = [];

  if (!movie && !rights) deniedReasons.push("content_not_found");
  if (!rights) deniedReasons.push("rights_window_missing");
  if (rights && rights.state !== "active") deniedReasons.push(`rights_${rights.state}`);
  if (rights && !rights.territories.includes(territory)) deniedReasons.push("territory_unavailable");
  if (moderation) deniedReasons.push("moderation_takedown");

  return {
    content_id: contentID,
    title: movie?.title ?? rights?.title ?? contentID,
    territory,
    available: deniedReasons.length === 0,
    denial_reasons: deniedReasons,
    rights_window_id: rights?.id ?? null,
    moderation_case_id: moderation?.id ?? null
  };
}

export function isContentAvailable(contentID: string, territory = "US"): boolean {
  return Boolean(availabilityRecord(contentID, territory).available);
}

export function operationsGovernedCatalogSeed(seed: CatalogSeed = catalogSeed, territory = "US"): CatalogSeed {
  for (const movie of seed.movies) {
    ensureRightsWindow(movie);
  }
  const movies = seed.movies.filter((movie) => isContentAvailable(movie.id, territory));
  const visibleIDs = new Set(movies.map((movie) => movie.id));
  return {
    ...seed,
    movies,
    collections: seed.collections
      .map((collection) => ({
        ...collection,
        movie_ids: collection.movie_ids.filter((movieID) => visibleIDs.has(movieID))
      }))
      .filter((collection) => collection.movie_ids.length > 0),
    series: seed.series.filter((series) => visibleIDs.has(series.hero_movie_id)).map((series) => ({
      ...series,
      seasons: series.seasons.map((season) => ({
        ...season,
        episodes: season.episodes.filter((episode) => episode.release_state === "published")
      }))
    })),
    publishing_projects: seed.publishing_projects.filter((project) => visibleIDs.has(project.content_id))
  };
}

function ensureRightsWindow(movie: CatalogMovie): RightsWindowRecord {
  const existing = rightsWindows.get(movie.id);
  if (existing) return existing;
  const record: RightsWindowRecord = {
    id: `rights-${movie.id}`,
    content_id: movie.id,
    title: movie.title,
    territories: ["US", "CA", "GB"],
    starts_at: "2026-01-01T00:00:00.000Z",
    ends_at: "2027-12-31T23:59:59.000Z",
    state: "active",
    licensing_package_id: `license-${movie.id}`,
    rights_holder: movie.creator_name,
    updated_at: nowISO()
  };
  rightsWindows.set(movie.id, record);
  return record;
}

function platformHealth(): JsonObject[] {
  const allMovies = catalogSeed.movies;
  const available = allMovies.filter((movie) => isContentAvailable(movie.id, "US"));
  const openModeration = Array.from(moderationCases.values()).filter((record) => record.state === "open" || record.state === "needs_revision");
  return [
    {
      id: "catalog",
      title: "Catalog Availability",
      status: available.length === allMovies.length ? "healthy" : "restricted",
      value: `${available.length}/${allMovies.length}`,
      detail: "Rights windows and moderation state are applied before catalog responses."
    },
    {
      id: "rights",
      title: "Rights Windows",
      status: Array.from(rightsWindows.values()).every((record) => record.state === "active") ? "healthy" : "attention",
      value: `${rightsWindows.size}`,
      detail: "Territory and window records are enforced by the operations layer."
    },
    {
      id: "moderation",
      title: "Moderation Queue",
      status: openModeration.length === 0 ? "clear" : "review",
      value: `${openModeration.length}`,
      detail: "Open and revision cases require admin decision."
    },
    {
      id: "audit",
      title: "Audit Trail",
      status: "recording",
      value: `${auditRecords.length}`,
      detail: "Admin operations are recorded with actor, role, result, and detail."
    }
  ];
}

function seedOperations(): void {
  if (rightsWindows.size > 0) return;
  for (const movie of catalogSeed.movies) {
    rightsWindows.set(movie.id, {
      id: `rights-${movie.id}`,
      content_id: movie.id,
      title: movie.title,
      territories: movie.id === "paranormall-s1" ? ["US", "CA"] : ["US", "CA", "GB"],
      starts_at: "2026-01-01T00:00:00.000Z",
      ends_at: "2027-12-31T23:59:59.000Z",
      state: "active",
      licensing_package_id: `license-${movie.id}`,
      rights_holder: movie.creator_name,
      updated_at: nowISO()
    });
  }
  const seeded = catalogSeed.movies.find((movie) => movie.id === "behind-the-vision");
  if (seeded) {
    upsertModerationCase(seeded, {
      category: "Policy Review",
      state: "cleared",
      policy_status: "Cleared",
      reviewer_user_id: "local-admin",
      note: "Seed moderation case cleared for baseline catalog visibility."
    });
  }
}

function upsertModerationCase(movie: CatalogMovie, update: Partial<ModerationCaseRecord>): ModerationCaseRecord {
  const existing = Array.from(moderationCases.values()).find((record) => record.content_id === movie.id);
  const record: ModerationCaseRecord = {
    id: existing?.id ?? `moderation-${moderationCounter++}`,
    content_id: movie.id,
    title: movie.title,
    category: update.category ?? existing?.category ?? "Policy Review",
    state: update.state ?? existing?.state ?? "open",
    policy_status: update.policy_status ?? existing?.policy_status ?? "Flagged",
    reviewer_user_id: update.reviewer_user_id ?? existing?.reviewer_user_id ?? null,
    note: update.note ?? existing?.note ?? "Awaiting admin moderation decision.",
    updated_at: nowISO()
  };
  moderationCases.set(record.id, record);
  return record;
}

function sanitizeRightsWindow(record: RightsWindowRecord): JsonObject {
  return { ...record };
}

function sanitizeModerationCase(record: ModerationCaseRecord): JsonObject {
  return { ...record };
}

function requireAdminSession(authorizationHeader: string | undefined): IdentitySession {
  const session = requireIdentitySession(authorizationHeader);
  if (session.role !== "admin") {
    recordAudit("admin_access_denied", session, null, "denied", "Platform operations require admin role.");
    const error = new Error("admin_role_required");
    error.name = "ForbiddenIdentityAccess";
    throw error;
  }
  return session;
}

function requireMovie(contentID: string): CatalogMovie {
  const movie = catalogSeed.movies.find((candidate) => candidate.id === contentID);
  if (!movie) throw new ContractError("content_not_found", "Catalog content was not found", 404);
  return movie;
}

function requireRightsWindow(contentID: string): RightsWindowRecord {
  requireMovie(contentID);
  const record = rightsWindows.get(contentID);
  if (!record) throw new ContractError("rights_window_not_found", "Rights window was not found", 404);
  return record;
}

function requireModerationCase(caseID: string): ModerationCaseRecord {
  const record = moderationCases.get(caseID);
  if (!record) throw new ContractError("moderation_case_not_found", "Moderation case was not found", 404);
  return record;
}

function moderationDecision(action: string | null): ModerationDecision {
  if (action === "clear") return "cleared";
  if (action === "needs-revision") return "needs_revision";
  if (action === "takedown") return "takedown";
  if (action === "restore") return "restored";
  if (action === "flag") return "flagged";
  throw new ContractError("moderation_action_invalid", "Unknown moderation decision.", 404);
}

function recordAudit(action: string, session: IdentitySession, contentID: string | null, result: string, detail: string): void {
  auditRecords.push({
    id: `operations-audit-${auditCounter++}`,
    action,
    content_id: contentID,
    actor_user_id: session.user_id,
    role: session.role,
    result,
    detail,
    created_at: nowISO()
  });
  if (auditRecords.length > 200) auditRecords.splice(0, auditRecords.length - 200);
}

function requiredString(body: unknown, key: string): string {
  const value = stringField(body, key);
  if (!value) throw new ContractError("field_required", `${key} is required.`, 422);
  return value;
}

function stringField(body: unknown, key: string): string | null {
  if (!isRecord(body)) return null;
  const value = body[key];
  return typeof value === "string" && value.trim().length > 0 ? value : null;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function nowISO(): string {
  return new Date().toISOString();
}
