import { catalogSeed } from "../catalog/catalogSeed.js";
import type { JsonObject } from "../contracts.js";

export type IdentityRole = "viewer" | "creator" | "admin";

type IdentitySession = {
  session_id: string;
  user_id: string;
  display_name: string;
  email: string | null;
  role: IdentityRole;
  creator_id: string | null;
  workspace_id: string;
  provider: "development" | "apple";
  issued_at: string;
  expires_at: string;
};

type IdentityAuditEvent = {
  id: string;
  action: string;
  user_id: string | null;
  role: IdentityRole | "signed_out";
  detail: string;
  created_at: string;
};

const sessions = new Map<string, IdentitySession>();
const auditEvents: IdentityAuditEvent[] = [];
let sessionCounter = 1;
let auditCounter = 1;

export function createDevelopmentIdentitySession(body: unknown): JsonObject {
  const requestedRole = roleFromBody(body) ?? "creator";
  const user = userForRole(requestedRole);
  const session = createSession({
    userID: user.id,
    displayName: user.display_name,
    email: null,
    role: requestedRole,
    provider: "development"
  });
  sessions.set(session.session_id, session);
  recordAudit("sign_in", session, "Development identity session created for local simulator use.");
  return sessionResponse(session, "Development sign-in ready");
}

export function exchangeAppleIdentity(body: unknown): JsonObject {
  const requestedRole = roleFromBody(body) ?? "viewer";
  const user = userForRole(requestedRole);
  const session = createSession({
    userID: user.id,
    displayName: user.display_name,
    email: null,
    role: requestedRole,
    provider: "apple"
  });
  sessions.set(session.session_id, session);
  recordAudit("apple_exchange", session, "Apple identity exchange contract accepted by local backend stub.");
  return sessionResponse(session, "Apple exchange contract ready");
}

export function refreshIdentitySession(authorizationHeader: string | undefined): JsonObject {
  const session = requireSession(authorizationHeader);
  const refreshed = {
    ...session,
    session_id: nextSessionID(session.role),
    issued_at: nowISO(),
    expires_at: expiresAtISO()
  };
  sessions.delete(session.session_id);
  sessions.set(refreshed.session_id, refreshed);
  recordAudit("refresh", refreshed, "Session refreshed with a new local authorization identifier.");
  return sessionResponse(refreshed, "Session refreshed");
}

export function signOutIdentitySession(authorizationHeader: string | undefined): JsonObject {
  const session = requireSession(authorizationHeader);
  sessions.delete(session.session_id);
  recordAudit("sign_out", session, "Session removed from local backend memory.");
  return {
    status: "signed_out",
    user_id: session.user_id,
    audit_events: auditEvents.slice(-5)
  };
}

export function currentIdentitySession(authorizationHeader: string | undefined): JsonObject {
  const session = requireSession(authorizationHeader);
  recordAudit("me", session, "Current session inspected.");
  return sessionResponse(session, "Session active");
}

export function requestAccountDeletion(authorizationHeader: string | undefined): JsonObject {
  const session = requireSession(authorizationHeader);
  recordAudit("delete_request", session, "Account deletion request recorded for manual policy handling.");
  return {
    status: "deletion_requested",
    user_id: session.user_id,
    role: session.role,
    detail: "Deletion request recorded. Production retention policy and identity-provider confirmation are required before deletion.",
    audit_events: auditEvents.slice(-5)
  };
}

export function creatorWorkspaceMutation(authorizationHeader: string | undefined): JsonObject {
  const session = requireSession(authorizationHeader);
  if (session.role !== "creator" && session.role !== "admin") {
    recordAudit("creator_workspace_denied", session, "Viewer role denied creator workspace mutation.");
    const error = new Error("creator_role_required");
    error.name = "ForbiddenIdentityAccess";
    throw error;
  }
  recordAudit("creator_workspace_allowed", session, "Creator workspace mutation authorized locally.");
  return {
    status: "authorized",
    workspace_id: session.workspace_id,
    role: session.role,
    creator_id: session.creator_id,
    detail: "Creator workspace mutation accepted by local role enforcement."
  };
}

export function identityAuditTrail(): JsonObject {
  return {
    status: "ready",
    events: auditEvents.slice(-20)
  };
}

export function identityReadinessSummary(): JsonObject {
  return {
    auth_enabled: true,
    sign_in_with_apple_contract: true,
    development_identity_mode: true,
    roles: ["viewer", "creator", "admin"],
    session_refresh: true,
    account_deletion_request: true,
    role_authorization: true
  };
}

function sessionResponse(session: IdentitySession, detail: string): JsonObject {
  return {
    status: isExpired(session) ? "expired" : "authenticated",
    detail,
    session,
    permissions: permissionsForRole(session.role),
    audit_events: auditEvents.slice(-5)
  };
}

function createSession(input: {
  userID: string;
  displayName: string;
  email: string | null;
  role: IdentityRole;
  provider: "development" | "apple";
}): IdentitySession {
  return {
    session_id: nextSessionID(input.role),
    user_id: input.userID,
    display_name: input.displayName,
    email: input.email,
    role: input.role,
    creator_id: input.role === "creator" || input.role === "admin" ? catalogSeed.creators[0]?.id ?? null : null,
    workspace_id: input.role === "viewer" ? "watch-workspace" : "creator-workspace",
    provider: input.provider,
    issued_at: nowISO(),
    expires_at: expiresAtISO()
  };
}

function requireSession(authorizationHeader: string | undefined): IdentitySession {
  const sessionID = parseAuthorization(authorizationHeader);
  const session = sessionID ? sessions.get(sessionID) : null;
  if (!session) {
    const error = new Error("identity_session_required");
    error.name = "UnauthorizedIdentityAccess";
    throw error;
  }
  if (isExpired(session)) {
    sessions.delete(session.session_id);
    recordAudit("expired", session, "Expired session rejected.");
    const error = new Error("identity_session_expired");
    error.name = "UnauthorizedIdentityAccess";
    throw error;
  }
  return session;
}

function parseAuthorization(value: string | undefined): string | null {
  if (!value) return null;
  const [scheme, sessionID] = value.split(" ");
  return scheme === "HighFiveSession" && sessionID ? sessionID : null;
}

function roleFromBody(body: unknown): IdentityRole | null {
  if (!isRecord(body)) return null;
  return isRole(body.role) ? body.role : null;
}

function userForRole(role: IdentityRole): { id: string; display_name: string; role: string } {
  const existing = catalogSeed.users.find((user) => user.role === role);
  if (existing) return existing;
  return {
    id: role === "admin" ? "local-admin" : `local-${role}`,
    display_name: role === "admin" ? "HighFive Admin" : role === "creator" ? "HighFive Creator" : "Local Viewer",
    role
  };
}

function permissionsForRole(role: IdentityRole): JsonObject[] {
  const canCreate = role === "creator" || role === "admin";
  return [
    { id: "watch", status: "allowed", detail: "Browse catalog, save titles, and play eligible content." },
    { id: "creator", status: canCreate ? "allowed" : "denied", detail: canCreate ? "Creator workspace mutations allowed." : "Viewer role cannot mutate creator workspace." },
    { id: "admin", status: role === "admin" ? "allowed" : "denied", detail: role === "admin" ? "Administration mutations allowed." : "Administration requires admin role." }
  ];
}

function recordAudit(action: string, session: IdentitySession | null, detail: string): void {
  auditEvents.push({
    id: `identity-audit-${auditCounter++}`,
    action,
    user_id: session?.user_id ?? null,
    role: session?.role ?? "signed_out",
    detail,
    created_at: nowISO()
  });
  if (auditEvents.length > 100) auditEvents.splice(0, auditEvents.length - 100);
}

function nextSessionID(role: IdentityRole): string {
  return `hf-session-${role}-${sessionCounter++}`;
}

function nowISO(): string {
  return new Date().toISOString();
}

function expiresAtISO(): string {
  return new Date(Date.now() + 45 * 60 * 1000).toISOString();
}

function isExpired(session: IdentitySession): boolean {
  return Date.parse(session.expires_at) <= Date.now();
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function isRole(value: unknown): value is IdentityRole {
  return value === "viewer" || value === "creator" || value === "admin";
}
