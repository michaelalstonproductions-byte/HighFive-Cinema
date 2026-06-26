import type { JsonObject } from "../contracts.js";
import { ContractError } from "../errors.js";
import { requireIdentitySession, type IdentitySession } from "./identity.js";

type ReleaseState = "candidate" | "submitted" | "released";
type HotfixState = "open" | "monitoring" | "closed";
type OnboardingState = "invited" | "activated";

type ReleaseRecord = {
  id: string;
  build_id: string;
  version: string;
  state: ReleaseState;
  external_submission_confirmed: boolean;
  public_release_confirmed: boolean;
  submitted_at: string | null;
  released_at: string | null;
  updated_at: string;
};

type HotfixRecord = {
  id: string;
  title: string;
  severity: string;
  state: HotfixState;
  created_at: string;
  updated_at: string;
};

type CreatorOnboardingRecord = {
  id: string;
  creator_id: string;
  title: string;
  state: OnboardingState;
  checklist: string[];
  created_at: string;
  updated_at: string;
};

type ReleaseAuditRecord = {
  id: string;
  action: string;
  actor_user_id: string;
  target_id: string | null;
  result: string;
  created_at: string;
};

const releaseRecord: ReleaseRecord = {
  id: "highfive-cinema-public-release",
  build_id: "highfive-cinema-rc1",
  version: "1.0.0-rc1",
  state: "candidate",
  external_submission_confirmed: false,
  public_release_confirmed: false,
  submitted_at: null,
  released_at: null,
  updated_at: nowISO()
};

const hotfixes = new Map<string, HotfixRecord>();
const creatorOnboarding = new Map<string, CreatorOnboardingRecord>();
const auditRecords: ReleaseAuditRecord[] = [];
let hotfixCounter = 1;
let onboardingCounter = 1;
let auditCounter = 1;

export function publicReleaseReadinessSummary(): JsonObject {
  return {
    public_release_operations_enabled: true,
    submission_record_enabled: true,
    release_cutover_enabled: true,
    release_monitoring_enabled: true,
    hotfix_tracking_enabled: true,
    launch_analytics_enabled: true,
    creator_onboarding_enabled: true,
    audit_trail_enabled: true,
    external_submission_required: true,
    external_submission_confirmed: releaseRecord.external_submission_confirmed,
    public_release_confirmed: releaseRecord.public_release_confirmed,
    open_hotfixes: [...hotfixes.values()].filter((record) => record.state !== "closed").length,
    onboarded_creators: [...creatorOnboarding.values()].filter((record) => record.state === "activated").length
  };
}

export function publicReleaseSummary(authorizationHeader: string | undefined): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  recordAudit("public_release_summary", session, null, "allowed");
  return {
    status: releaseRecord.state,
    release: releaseRecord,
    monitoring: monitoringSnapshot(),
    analytics: analyticsSnapshot(),
    hotfixes: [...hotfixes.values()],
    creator_onboarding: [...creatorOnboarding.values()],
    audit_records: auditRecords.slice(-25),
    external_distribution_note: "External App Store release still requires manual App Store Connect action outside this repository."
  };
}

export function submitPublicRelease(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  releaseRecord.state = "submitted";
  releaseRecord.external_submission_confirmed = booleanField(body, "external_submission_confirmed");
  releaseRecord.submitted_at = nowISO();
  releaseRecord.updated_at = nowISO();
  recordAudit("public_release_submitted", session, releaseRecord.id, "recorded");
  return {
    status: releaseRecord.external_submission_confirmed ? "submission_confirmed" : "manual_submission_required",
    release: releaseRecord,
    next_step: releaseRecord.external_submission_confirmed ? "release_cutover" : "complete App Store Connect submission outside git"
  };
}

export function releasePublicRelease(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  if (releaseRecord.state === "candidate") {
    throw new ContractError("public_release_not_submitted", "Record submission before release cutover.", 409);
  }
  releaseRecord.public_release_confirmed = booleanField(body, "public_release_confirmed");
  if (!releaseRecord.public_release_confirmed) {
    throw new ContractError("public_release_confirmation_required", "Public release cutover requires an explicit manual confirmation.", 422);
  }
  releaseRecord.state = "released";
  releaseRecord.released_at = nowISO();
  releaseRecord.updated_at = nowISO();
  recordAudit("public_release_cutover", session, releaseRecord.id, "released");
  return {
    status: "released",
    release: releaseRecord,
    monitoring: monitoringSnapshot(),
    analytics: analyticsSnapshot()
  };
}

export function publicReleaseMonitor(authorizationHeader: string | undefined): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  recordAudit("public_release_monitor", session, releaseRecord.id, "allowed");
  return {
    status: "monitoring",
    release: releaseRecord,
    monitoring: monitoringSnapshot(),
    analytics: analyticsSnapshot()
  };
}

export function recordPublicReleaseHotfix(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  const record: HotfixRecord = {
    id: `public-hotfix-${hotfixCounter++}`,
    title: stringField(body, "title") ?? "Launch follow-up",
    severity: stringField(body, "severity") ?? "medium",
    state: "open",
    created_at: nowISO(),
    updated_at: nowISO()
  };
  hotfixes.set(record.id, record);
  recordAudit("public_release_hotfix_opened", session, record.id, "recorded");
  return {
    status: "hotfix_opened",
    hotfix: record,
    monitoring: monitoringSnapshot()
  };
}

export function updatePublicReleaseHotfix(authorizationHeader: string | undefined, id: string, body: unknown): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  const record = hotfixes.get(id);
  if (!record) throw new ContractError("public_hotfix_not_found", "Public release hotfix was not found.", 404);
  record.state = hotfixStateField(body);
  record.updated_at = nowISO();
  recordAudit("public_release_hotfix_updated", session, id, record.state);
  return {
    status: record.state,
    hotfix: record,
    monitoring: monitoringSnapshot()
  };
}

export function onboardPublicReleaseCreator(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  const creatorID = stringField(body, "creator_id") ?? `creator-launch-${onboardingCounter}`;
  const record: CreatorOnboardingRecord = {
    id: `creator-onboarding-${onboardingCounter++}`,
    creator_id: creatorID,
    title: stringField(body, "title") ?? "Launch creator",
    state: booleanField(body, "activated") ? "activated" : "invited",
    checklist: checklistField(body),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  creatorOnboarding.set(record.id, record);
  recordAudit("public_release_creator_onboarded", session, record.id, record.state);
  return {
    status: record.state,
    creator_onboarding: record,
    analytics: analyticsSnapshot()
  };
}

export function publicReleaseAuditTrail(authorizationHeader: string | undefined): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  recordAudit("public_release_audit", session, releaseRecord.id, "allowed");
  return {
    status: "ready",
    audit_records: auditRecords.slice(-50)
  };
}

function monitoringSnapshot(): JsonObject {
  const openHotfixes = [...hotfixes.values()].filter((record) => record.state !== "closed");
  return {
    release_state: releaseRecord.state,
    app_health: openHotfixes.length === 0 ? "stable" : "watching",
    open_hotfixes: openHotfixes.length,
    crash_free_session_target: "manual production telemetry required",
    support_queue_status: "ready",
    rollback_ready: true,
    incident_owner_ready: true
  };
}

function analyticsSnapshot(): JsonObject {
  return {
    launch_analytics_state: "local_release_snapshot",
    creator_onboarded_count: [...creatorOnboarding.values()].filter((record) => record.state === "activated").length,
    creator_invited_count: [...creatorOnboarding.values()].filter((record) => record.state === "invited").length,
    viewer_metrics_source: "production analytics pipeline required after public release",
    revenue_metrics_source: "production entitlement records required after public release"
  };
}

function requireAdminSession(authorizationHeader: string | undefined): IdentitySession {
  const session = requireIdentitySession(authorizationHeader);
  if (session.role !== "admin") {
    const error = new Error("admin_role_required");
    error.name = "ForbiddenIdentityAccess";
    throw error;
  }
  return session;
}

function booleanField(body: unknown, key: string): boolean {
  if (!isRecord(body)) return false;
  return body[key] === true;
}

function stringField(body: unknown, key: string): string | null {
  if (!isRecord(body)) return null;
  const value = body[key];
  return typeof value === "string" && value.trim().length > 0 ? value.trim() : null;
}

function checklistField(body: unknown): string[] {
  if (!isRecord(body) || !Array.isArray(body.checklist)) {
    return ["profile reviewed", "publishing guide shared", "support channel assigned"];
  }
  return body.checklist
    .filter((item): item is string => typeof item === "string" && item.trim().length > 0)
    .map((item) => item.trim())
    .slice(0, 12);
}

function hotfixStateField(body: unknown): HotfixState {
  const value = stringField(body, "state");
  if (value === "monitoring" || value === "closed") return value;
  return "monitoring";
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function recordAudit(action: string, session: IdentitySession, targetID: string | null, result: string): void {
  auditRecords.push({
    id: `public-release-audit-${auditCounter++}`,
    action,
    actor_user_id: session.user_id,
    target_id: targetID,
    result,
    created_at: nowISO()
  });
  if (auditRecords.length > 200) auditRecords.splice(0, auditRecords.length - 200);
}

function nowISO(): string {
  return new Date().toISOString();
}
