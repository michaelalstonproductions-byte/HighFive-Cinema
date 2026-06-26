import type { JsonObject } from "../contracts.js";
import { ContractError } from "../errors.js";
import { requireIdentitySession, type IdentityRole, type IdentitySession } from "./identity.js";

type BetaCohort = "internal" | "external" | "creator";
type BetaStatus = "invited" | "active" | "paused";
type FeedbackSeverity = "low" | "medium" | "high" | "blocker";
type FeedbackState = "open" | "triaged" | "resolved";
type CrashState = "open" | "fixed" | "wont_fix";

type BetaTesterRecord = {
  id: string;
  user_id: string;
  role: IdentityRole;
  cohort: BetaCohort;
  status: BetaStatus;
  build_id: string;
  enrolled_at: string;
  updated_at: string;
};

type BetaFeedbackRecord = {
  id: string;
  tester_id: string;
  user_id: string;
  cohort: BetaCohort;
  build_id: string;
  category: string;
  severity: FeedbackSeverity;
  route: string;
  message: string;
  state: FeedbackState;
  created_at: string;
  updated_at: string;
};

type BetaCrashRecord = {
  id: string;
  tester_id: string;
  user_id: string;
  cohort: BetaCohort;
  build_id: string;
  route: string;
  exception_name: string;
  app_version: string;
  state: CrashState;
  created_at: string;
  updated_at: string;
};

type BetaAuditRecord = {
  id: string;
  action: string;
  actor_user_id: string;
  role: IdentityRole;
  target_id: string | null;
  result: string;
  created_at: string;
};

const betaBuild = {
  id: "highfive-cinema-rc1",
  version: "1.0.0-rc1",
  build_number: "1307649",
  status: "beta_candidate",
  cohorts: ["internal", "external", "creator"] as BetaCohort[],
  distribution_mode: "manual_beta_package",
  external_distribution_ready: true,
  creator_beta_ready: true
};

const testers = new Map<string, BetaTesterRecord>();
const feedbackRecords = new Map<string, BetaFeedbackRecord>();
const crashRecords = new Map<string, BetaCrashRecord>();
const auditRecords: BetaAuditRecord[] = [];
let feedbackCounter = 1;
let crashCounter = 1;
let auditCounter = 1;

export function betaReadinessSummary(): JsonObject {
  const stability = stabilityMetrics();
  return {
    beta_program_enabled: true,
    internal_beta_ready: true,
    external_beta_ready: true,
    creator_beta_ready: true,
    beta_feedback_enabled: true,
    beta_crash_intake_enabled: true,
    beta_resolution_workflow: true,
    beta_audit_trail: true,
    stable_beta: stability.blockers === 0,
    beta_testers: testers.size,
    beta_feedback_items: feedbackRecords.size,
    beta_crash_reports: crashRecords.size,
    unresolved_blockers: stability.blockers
  };
}

export function betaProgramSummary(authorizationHeader: string | undefined): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  recordAudit("beta_program_summary", session, null, "allowed");
  return {
    status: "ready",
    build: betaBuild,
    cohorts: betaCohortSummaries(),
    stability: stabilityMetrics(),
    unresolved_feedback: [...feedbackRecords.values()].filter((record) => record.state !== "resolved"),
    unresolved_crashes: [...crashRecords.values()].filter((record) => record.state === "open"),
    audit_records: auditRecords.slice(-25)
  };
}

export function enrollBetaTester(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireIdentitySession(authorizationHeader);
  const cohort = cohortField(body, session.role);
  authorizeCohort(session, cohort);
  const id = testerID(session.user_id, cohort);
  const record: BetaTesterRecord = {
    id,
    user_id: session.user_id,
    role: session.role,
    cohort,
    status: "active",
    build_id: betaBuild.id,
    enrolled_at: testers.get(id)?.enrolled_at ?? nowISO(),
    updated_at: nowISO()
  };
  testers.set(id, record);
  recordAudit("beta_tester_enrolled", session, id, "allowed");
  return {
    status: "enrolled",
    tester: record,
    build: betaBuild
  };
}

export function submitBetaFeedback(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireIdentitySession(authorizationHeader);
  const tester = requireTester(session, body);
  const severity = severityField(body);
  const record: BetaFeedbackRecord = {
    id: `beta-feedback-${feedbackCounter++}`,
    tester_id: tester.id,
    user_id: session.user_id,
    cohort: tester.cohort,
    build_id: tester.build_id,
    category: stringField(body, "category") ?? "General",
    severity,
    route: stringField(body, "route") ?? "unknown",
    message: sanitize(stringField(body, "message") ?? "Beta feedback received.", 500),
    state: "open",
    created_at: nowISO(),
    updated_at: nowISO()
  };
  feedbackRecords.set(record.id, record);
  recordAudit("beta_feedback_submitted", session, record.id, "allowed");
  return {
    status: "feedback_received",
    feedback: record,
    stability: stabilityMetrics()
  };
}

export function resolveBetaFeedback(authorizationHeader: string | undefined, id: string, body: unknown): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  const record = requireFeedback(id);
  record.state = feedbackStateField(body);
  record.updated_at = nowISO();
  recordAudit("beta_feedback_resolved", session, id, "allowed");
  return {
    status: record.state,
    feedback: record,
    stability: stabilityMetrics()
  };
}

export function submitBetaCrashReport(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireIdentitySession(authorizationHeader);
  const tester = requireTester(session, body);
  const record: BetaCrashRecord = {
    id: `beta-crash-${crashCounter++}`,
    tester_id: tester.id,
    user_id: session.user_id,
    cohort: tester.cohort,
    build_id: tester.build_id,
    route: stringField(body, "route") ?? "unknown",
    exception_name: sanitize(stringField(body, "exception_name") ?? "UnknownException", 120),
    app_version: stringField(body, "app_version") ?? betaBuild.version,
    state: "open",
    created_at: nowISO(),
    updated_at: nowISO()
  };
  crashRecords.set(record.id, record);
  recordAudit("beta_crash_reported", session, record.id, "allowed");
  return {
    status: "crash_recorded",
    crash: record,
    stability: stabilityMetrics()
  };
}

export function resolveBetaCrashReport(authorizationHeader: string | undefined, id: string, body: unknown): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  const record = requireCrash(id);
  record.state = crashStateField(body);
  record.updated_at = nowISO();
  recordAudit("beta_crash_resolved", session, id, "allowed");
  return {
    status: record.state,
    crash: record,
    stability: stabilityMetrics()
  };
}

export function betaStabilityReport(authorizationHeader: string | undefined): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  recordAudit("beta_stability_report", session, null, "allowed");
  return {
    status: stabilityMetrics().blockers === 0 ? "stable_beta" : "needs_fixes",
    stability: stabilityMetrics(),
    cohorts: betaCohortSummaries(),
    feedback: [...feedbackRecords.values()],
    crashes: [...crashRecords.values()]
  };
}

export function betaAuditTrail(authorizationHeader: string | undefined): JsonObject {
  const session = requireAdminSession(authorizationHeader);
  recordAudit("beta_audit", session, null, "allowed");
  return {
    status: "ready",
    audit_records: auditRecords.slice(-50)
  };
}

function betaCohortSummaries(): JsonObject[] {
  return betaBuild.cohorts.map((cohort) => {
    const cohortTesters = [...testers.values()].filter((tester) => tester.cohort === cohort);
    const cohortFeedback = [...feedbackRecords.values()].filter((record) => record.cohort === cohort);
    const cohortCrashes = [...crashRecords.values()].filter((record) => record.cohort === cohort);
    return {
      cohort,
      enrolled: cohortTesters.length,
      active: cohortTesters.filter((tester) => tester.status === "active").length,
      feedback_items: cohortFeedback.length,
      open_feedback: cohortFeedback.filter((record) => record.state !== "resolved").length,
      crash_reports: cohortCrashes.length,
      open_crashes: cohortCrashes.filter((record) => record.state === "open").length
    };
  });
}

function stabilityMetrics(): JsonObject & { blockers: number } {
  const openFeedback = [...feedbackRecords.values()].filter((record) => record.state !== "resolved");
  const openCrashes = [...crashRecords.values()].filter((record) => record.state === "open");
  const blockers = openFeedback.filter((record) => record.severity === "blocker").length + openCrashes.length;
  return {
    build_id: betaBuild.id,
    tester_count: testers.size,
    feedback_count: feedbackRecords.size,
    crash_count: crashRecords.size,
    open_feedback_count: openFeedback.length,
    open_crash_count: openCrashes.length,
    blockers,
    zero_blockers: blockers === 0,
    stable_beta: blockers === 0
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

function authorizeCohort(session: IdentitySession, cohort: BetaCohort): void {
  if (cohort === "internal" && session.role !== "admin") {
    throw new ContractError("internal_beta_requires_admin", "Internal beta enrollment requires an admin session.", 403);
  }
  if (cohort === "creator" && session.role === "viewer") {
    throw new ContractError("creator_beta_requires_creator", "Creator beta enrollment requires creator or admin role.", 403);
  }
}

function requireTester(session: IdentitySession, body: unknown): BetaTesterRecord {
  const cohort = cohortField(body, session.role);
  const tester = testers.get(testerID(session.user_id, cohort));
  if (!tester) {
    throw new ContractError("beta_tester_not_enrolled", "The current account must enroll in the beta before submitting beta data.", 403);
  }
  return tester;
}

function requireFeedback(id: string): BetaFeedbackRecord {
  const record = feedbackRecords.get(id);
  if (!record) throw new ContractError("beta_feedback_not_found", "Beta feedback was not found.", 404);
  return record;
}

function requireCrash(id: string): BetaCrashRecord {
  const record = crashRecords.get(id);
  if (!record) throw new ContractError("beta_crash_not_found", "Beta crash report was not found.", 404);
  return record;
}

function cohortField(body: unknown, role: IdentityRole): BetaCohort {
  const value = stringField(body, "cohort");
  if (value === "internal" || value === "external" || value === "creator") return value;
  return role === "creator" ? "creator" : "external";
}

function severityField(body: unknown): FeedbackSeverity {
  const value = stringField(body, "severity");
  if (value === "low" || value === "medium" || value === "high" || value === "blocker") return value;
  return "medium";
}

function feedbackStateField(body: unknown): FeedbackState {
  const value = stringField(body, "state");
  if (value === "triaged" || value === "resolved") return value;
  return "resolved";
}

function crashStateField(body: unknown): CrashState {
  const value = stringField(body, "state");
  if (value === "wont_fix") return value;
  return "fixed";
}

function testerID(userID: string, cohort: BetaCohort): string {
  return `beta-tester-${cohort}-${userID}`;
}

function stringField(body: unknown, key: string): string | null {
  if (!isRecord(body)) return null;
  const value = body[key];
  return typeof value === "string" && value.trim().length > 0 ? value.trim() : null;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function sanitize(value: string, maxLength: number): string {
  return value.replace(/\s+/g, " ").trim().slice(0, maxLength);
}

function recordAudit(action: string, session: IdentitySession, targetID: string | null, result: string): void {
  auditRecords.push({
    id: `beta-audit-${auditCounter++}`,
    action,
    actor_user_id: session.user_id,
    role: session.role,
    target_id: targetID,
    result,
    created_at: nowISO()
  });
  if (auditRecords.length > 200) auditRecords.splice(0, auditRecords.length - 200);
}

function nowISO(): string {
  return new Date().toISOString();
}
