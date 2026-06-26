import { catalogSeed } from "../catalog/catalogSeed.js";
import type { JsonObject } from "../contracts.js";
import { ContractError } from "../errors.js";
import { recordAnalyticsEvent } from "./analytics.js";
import { requireIdentitySession, type IdentitySession } from "./identity.js";
import { recordProductNotification } from "./notifications.js";

type StudioRole = "owner" | "director" | "producer" | "writer" | "editor" | "composer" | "marketing" | "reviewer";
type StudioPermission = "owner" | "edit" | "review" | "comment" | "view";

type ProductionCompanyRecord = {
  id: string;
  name: string;
  owner_user_id: string;
  creator_id: string;
  state: "active";
  created_at: string;
};

type StudioWorkspaceRecord = {
  id: string;
  company_id: string;
  name: string;
  owner_user_id: string;
  creator_id: string;
  state: "active" | "archived";
  created_at: string;
  updated_at: string;
};

type CollaboratorRecord = {
  id: string;
  user_id: string;
  display_name: string;
  role: StudioRole;
  permission: StudioPermission;
  state: "active" | "removed";
  added_at: string;
};

type StudioProjectRecord = {
  id: string;
  source_project_id: string;
  workspace_id: string;
  title: string;
  owner_user_id: string;
  creator_id: string;
  collaborators: CollaboratorRecord[];
  status: "draft" | "in_review" | "approved" | "revision_requested";
  created_at: string;
  updated_at: string;
};

type StudioEditRecord = {
  id: string;
  project_id: string;
  actor_user_id: string;
  summary: string;
  section: string;
  created_at: string;
};

type StudioApprovalRecord = {
  id: string;
  project_id: string;
  requested_by_user_id: string;
  reviewer_user_id: string;
  status: "pending" | "approved" | "revision_requested";
  request_note: string;
  decision_note: string | null;
  created_at: string;
  updated_at: string;
};

const companies: ProductionCompanyRecord[] = [];
const workspaces: StudioWorkspaceRecord[] = [];
const projects: StudioProjectRecord[] = [];
const edits: StudioEditRecord[] = [];
const approvals: StudioApprovalRecord[] = [];

let companyCounter = 1;
let workspaceCounter = 1;
let projectCounter = 1;
let collaboratorCounter = 1;
let editCounter = 1;
let approvalCounter = 1;

seedStudioCollaboration();

export function studioCollaborationReadinessSummary(): JsonObject {
  return {
    studio_collaboration_enabled: true,
    production_companies: true,
    studio_workspaces: true,
    multi_user_editing: true,
    role_permissions: true,
    approvals: true,
    shared_projects: true,
    notifications: true,
    external_services: false,
    projects: projects.length
  };
}

export function studioCollaborationSummary(authorizationHeader: string | undefined): JsonObject {
  const session = requireStudioSession(authorizationHeader);
  const visibleProjects = projects.filter((project) => canAccessProject(session, project));
  return {
    status: "ready",
    user_id: session.user_id,
    companies: companies.filter((company) => company.owner_user_id === session.user_id || session.role === "admin" || company.creator_id === session.creator_id),
    workspaces: workspaces.filter((workspace) => workspace.owner_user_id === session.user_id || session.role === "admin" || workspace.creator_id === session.creator_id),
    shared_projects: visibleProjects,
    edit_activity: edits.filter((edit) => visibleProjects.some((project) => project.id === edit.project_id)).slice(-20),
    approvals: approvals.filter((approval) => visibleProjects.some((project) => project.id === approval.project_id)).slice(-20),
    permission_summary: permissionSummary(session, visibleProjects),
    generated_at: nowISO()
  };
}

export function createProductionCompany(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireStudioSession(authorizationHeader);
  const name = optionalStringFromBody(body, "name") ?? `${session.display_name} Studio`;
  const company: ProductionCompanyRecord = {
    id: `production-company-${companyCounter++}`,
    name: trimmed(name, 100),
    owner_user_id: session.user_id,
    creator_id: creatorIDFor(session),
    state: "active",
    created_at: nowISO()
  };
  companies.push(company);
  return {
    status: "created",
    company
  };
}

export function createStudioWorkspace(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireStudioSession(authorizationHeader);
  const company = companyForRequest(session, optionalStringFromBody(body, "company_id"));
  const workspace: StudioWorkspaceRecord = {
    id: `studio-workspace-${workspaceCounter++}`,
    company_id: company.id,
    name: trimmed(optionalStringFromBody(body, "name") ?? `${company.name} Workspace`, 100),
    owner_user_id: session.user_id,
    creator_id: creatorIDFor(session),
    state: "active",
    created_at: nowISO(),
    updated_at: nowISO()
  };
  workspaces.push(workspace);
  return {
    status: "created",
    workspace
  };
}

export function shareStudioProject(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireStudioSession(authorizationHeader);
  const sourceProjectID = optionalStringFromBody(body, "project_id") ?? catalogSeed.publishing_projects[0]?.id ?? "project-behind-the-vision";
  const sourceProject = catalogSeed.publishing_projects.find((project) => project.id === sourceProjectID);
  const workspace = workspaceForRequest(session, optionalStringFromBody(body, "workspace_id"));
  const project: StudioProjectRecord = {
    id: `studio-project-${projectCounter++}`,
    source_project_id: sourceProjectID,
    workspace_id: workspace.id,
    title: trimmed(optionalStringFromBody(body, "title") ?? sourceProject?.title ?? "Shared HighFive Project", 120),
    owner_user_id: session.user_id,
    creator_id: creatorIDFor(session),
    collaborators: [
      collaboratorFor(session.user_id, session.display_name, "owner", "owner")
    ],
    status: "draft",
    created_at: nowISO(),
    updated_at: nowISO()
  };
  projects.push(project);
  recordAnalyticsEvent("publishing_state_change", {
    project_id: project.source_project_id,
    studio_project_id: project.id,
    collaboration_state: "shared"
  }, {
    authorizationHeader,
    identitySession: session,
    projectID: project.source_project_id,
    creatorID: project.creator_id,
    source: "studio_collaboration_share"
  });
  return {
    status: "shared",
    shared_project: project
  };
}

export function addStudioCollaborator(authorizationHeader: string | undefined, studioProjectID: string, body: unknown): JsonObject {
  const session = requireStudioSession(authorizationHeader);
  const project = requireProjectPermission(session, studioProjectID, "owner");
  const userID = stringFromBody(body, "user_id", "invalid_collaborator_request");
  const displayName = optionalStringFromBody(body, "display_name") ?? userID;
  const role = studioRoleFromBody(body) ?? "editor";
  const permission = permissionFromBody(body) ?? permissionForRole(role);
  const existingIndex = project.collaborators.findIndex((collaborator) => collaborator.user_id === userID);
  const collaborator = collaboratorFor(userID, displayName, role, permission);
  if (existingIndex >= 0) {
    project.collaborators[existingIndex] = collaborator;
  } else {
    project.collaborators.push(collaborator);
  }
  project.updated_at = nowISO();
  recordProductNotification({
    userID,
    role: "creator",
    category: "collaboration",
    title: "Studio collaboration invite",
    body: `${session.display_name} added you to ${project.title}.`,
    deepLink: "highfive://creator/collaboration"
  });
  return {
    status: existingIndex >= 0 ? "updated" : "added",
    shared_project: project,
    collaborator
  };
}

export function recordStudioEdit(authorizationHeader: string | undefined, studioProjectID: string, body: unknown): JsonObject {
  const session = requireStudioSession(authorizationHeader);
  const project = requireProjectPermission(session, studioProjectID, "edit");
  const edit: StudioEditRecord = {
    id: `studio-edit-${editCounter++}`,
    project_id: project.id,
    actor_user_id: session.user_id,
    summary: trimmed(optionalStringFromBody(body, "summary") ?? "Project updated", 180),
    section: trimmed(optionalStringFromBody(body, "section") ?? "metadata", 60),
    created_at: nowISO()
  };
  edits.push(edit);
  project.updated_at = edit.created_at;
  return {
    status: "recorded",
    edit,
    recent_edits: edits.filter((record) => record.project_id === project.id).slice(-12)
  };
}

export function requestStudioApproval(authorizationHeader: string | undefined, studioProjectID: string, body: unknown): JsonObject {
  const session = requireStudioSession(authorizationHeader);
  const project = requireProjectPermission(session, studioProjectID, "edit");
  const reviewerUserID = optionalStringFromBody(body, "reviewer_user_id") ??
    project.collaborators.find((collaborator) => collaborator.permission === "review")?.user_id ??
    "local-admin";
  const approval: StudioApprovalRecord = {
    id: `studio-approval-${approvalCounter++}`,
    project_id: project.id,
    requested_by_user_id: session.user_id,
    reviewer_user_id: reviewerUserID,
    status: "pending",
    request_note: trimmed(optionalStringFromBody(body, "request_note") ?? "Review requested for shared project.", 240),
    decision_note: null,
    created_at: nowISO(),
    updated_at: nowISO()
  };
  approvals.push(approval);
  project.status = "in_review";
  project.updated_at = approval.updated_at;
  recordProductNotification({
    userID: reviewerUserID,
    role: "creator",
    category: "collaboration",
    title: "Studio approval requested",
    body: `${project.title} is ready for review.`,
    deepLink: "highfive://creator/collaboration"
  });
  return {
    status: "requested",
    approval,
    shared_project: project
  };
}

export function decideStudioApproval(
  authorizationHeader: string | undefined,
  studioProjectID: string,
  approvalID: string,
  body: unknown
): JsonObject {
  const session = requireStudioSession(authorizationHeader);
  const project = requireProjectPermission(session, studioProjectID, "review");
  const approval = approvals.find((record) => record.id === approvalID && record.project_id === project.id);
  if (!approval) {
    throw new ContractError("approval_not_found", "Studio approval was not found", 404);
  }
  const decision = approvalDecisionFromBody(body) ?? "approved";
  approval.status = decision;
  approval.decision_note = trimmed(optionalStringFromBody(body, "decision_note") ?? decisionLabel(decision), 240);
  approval.updated_at = nowISO();
  project.status = decision;
  project.updated_at = approval.updated_at;
  recordAnalyticsEvent("publishing_state_change", {
    studio_project_id: project.id,
    project_id: project.source_project_id,
    collaboration_state: decision
  }, {
    authorizationHeader,
    identitySession: session,
    projectID: project.source_project_id,
    creatorID: project.creator_id,
    source: "studio_collaboration_approval"
  });
  return {
    status: "decided",
    approval,
    shared_project: project
  };
}

function seedStudioCollaboration(): void {
  if (companies.length > 0) return;
  const company: ProductionCompanyRecord = {
    id: "production-company-highfive",
    name: "HighFive Creator Studio",
    owner_user_id: "local-creator",
    creator_id: "maya-hart",
    state: "active",
    created_at: catalogSeed.generated_at
  };
  const workspace: StudioWorkspaceRecord = {
    id: "studio-workspace-highfive",
    company_id: company.id,
    name: "Opening Night Workspace",
    owner_user_id: "local-creator",
    creator_id: "maya-hart",
    state: "active",
    created_at: catalogSeed.generated_at,
    updated_at: catalogSeed.generated_at
  };
  const project: StudioProjectRecord = {
    id: "studio-project-behind-the-vision",
    source_project_id: "project-behind-the-vision",
    workspace_id: workspace.id,
    title: "Behind the Vision: Studio Notes",
    owner_user_id: "local-creator",
    creator_id: "maya-hart",
    collaborators: [
      collaboratorFor("local-creator", "HighFive Creator", "owner", "owner"),
      collaboratorFor("local-admin", "HighFive Admin", "reviewer", "review")
    ],
    status: "draft",
    created_at: catalogSeed.generated_at,
    updated_at: catalogSeed.generated_at
  };
  companies.push(company);
  workspaces.push(workspace);
  projects.push(project);
}

function requireStudioSession(authorizationHeader: string | undefined): IdentitySession {
  const session = requireIdentitySession(authorizationHeader);
  if (session.role !== "creator" && session.role !== "admin") {
    throw new ContractError("creator_role_required", "Studio collaboration requires a creator or admin session", 403);
  }
  return session;
}

function companyForRequest(session: IdentitySession, companyID: string | null): ProductionCompanyRecord {
  if (companyID) {
    const company = companies.find((record) => record.id === companyID);
    if (!company) throw new ContractError("production_company_not_found", "Production company was not found", 404);
    if (session.role !== "admin" && company.creator_id !== creatorIDFor(session) && company.owner_user_id !== session.user_id) {
      throw new ContractError("production_company_access_denied", "Session cannot access this production company", 403);
    }
    return company;
  }
  return companies.find((record) => record.creator_id === creatorIDFor(session) || record.owner_user_id === session.user_id) ??
    createImplicitCompany(session);
}

function workspaceForRequest(session: IdentitySession, workspaceID: string | null): StudioWorkspaceRecord {
  if (workspaceID) {
    const workspace = workspaces.find((record) => record.id === workspaceID);
    if (!workspace) throw new ContractError("studio_workspace_not_found", "Studio workspace was not found", 404);
    if (session.role !== "admin" && workspace.creator_id !== creatorIDFor(session) && workspace.owner_user_id !== session.user_id) {
      throw new ContractError("studio_workspace_access_denied", "Session cannot access this studio workspace", 403);
    }
    return workspace;
  }
  return workspaces.find((record) => record.creator_id === creatorIDFor(session) || record.owner_user_id === session.user_id) ??
    createImplicitWorkspace(session);
}

function createImplicitCompany(session: IdentitySession): ProductionCompanyRecord {
  const company: ProductionCompanyRecord = {
    id: `production-company-${companyCounter++}`,
    name: `${session.display_name} Studio`,
    owner_user_id: session.user_id,
    creator_id: creatorIDFor(session),
    state: "active",
    created_at: nowISO()
  };
  companies.push(company);
  return company;
}

function createImplicitWorkspace(session: IdentitySession): StudioWorkspaceRecord {
  const company = companyForRequest(session, null);
  const workspace: StudioWorkspaceRecord = {
    id: `studio-workspace-${workspaceCounter++}`,
    company_id: company.id,
    name: `${company.name} Workspace`,
    owner_user_id: session.user_id,
    creator_id: creatorIDFor(session),
    state: "active",
    created_at: nowISO(),
    updated_at: nowISO()
  };
  workspaces.push(workspace);
  return workspace;
}

function requireProjectPermission(session: IdentitySession, studioProjectID: string, required: StudioPermission): StudioProjectRecord {
  const project = projects.find((record) => record.id === studioProjectID);
  if (!project) throw new ContractError("studio_project_not_found", "Studio project was not found", 404);
  if (!canAccessProject(session, project)) {
    throw new ContractError("studio_project_access_denied", "Session cannot access this studio project", 403);
  }
  if (!hasPermission(session, project, required)) {
    throw new ContractError("studio_permission_denied", `Studio project requires ${required} permission`, 403);
  }
  return project;
}

function canAccessProject(session: IdentitySession, project: StudioProjectRecord): boolean {
  return session.role === "admin" ||
    project.owner_user_id === session.user_id ||
    project.creator_id === session.creator_id ||
    project.collaborators.some((collaborator) => collaborator.user_id === session.user_id && collaborator.state === "active");
}

function hasPermission(session: IdentitySession, project: StudioProjectRecord, required: StudioPermission): boolean {
  if (session.role === "admin") return true;
  const collaborator = project.collaborators.find((record) => record.user_id === session.user_id && record.state === "active");
  const permission = collaborator?.permission;
  if (permission === "owner") return true;
  if (required === "view") return Boolean(permission);
  if (required === "comment") return permission === "comment" || permission === "edit" || permission === "review";
  if (required === "edit") return permission === "edit";
  if (required === "review") return permission === "review";
  return false;
}

function permissionSummary(session: IdentitySession, visibleProjects: StudioProjectRecord[]): JsonObject[] {
  return visibleProjects.map((project) => ({
    project_id: project.id,
    title: project.title,
    can_edit: hasPermission(session, project, "edit"),
    can_review: hasPermission(session, project, "review"),
    can_comment: hasPermission(session, project, "comment"),
    collaborators: project.collaborators.length,
    status: project.status
  }));
}

function collaboratorFor(userID: string, displayName: string, role: StudioRole, permission: StudioPermission): CollaboratorRecord {
  return {
    id: `studio-collaborator-${collaboratorCounter++}`,
    user_id: userID,
    display_name: trimmed(displayName, 80),
    role,
    permission,
    state: "active",
    added_at: nowISO()
  };
}

function creatorIDFor(session: IdentitySession): string {
  return session.creator_id ?? catalogSeed.creators[0]?.id ?? "maya-hart";
}

function studioRoleFromBody(body: unknown): StudioRole | null {
  const role = optionalStringFromBody(body, "role");
  const allowed: StudioRole[] = ["owner", "director", "producer", "writer", "editor", "composer", "marketing", "reviewer"];
  return allowed.includes(role as StudioRole) ? role as StudioRole : null;
}

function permissionFromBody(body: unknown): StudioPermission | null {
  const permission = optionalStringFromBody(body, "permission");
  const allowed: StudioPermission[] = ["owner", "edit", "review", "comment", "view"];
  return allowed.includes(permission as StudioPermission) ? permission as StudioPermission : null;
}

function permissionForRole(role: StudioRole): StudioPermission {
  if (role === "owner") return "owner";
  if (role === "reviewer" || role === "producer") return "review";
  if (role === "director" || role === "writer" || role === "editor" || role === "composer" || role === "marketing") return "edit";
  return "view";
}

function approvalDecisionFromBody(body: unknown): "approved" | "revision_requested" | null {
  const status = optionalStringFromBody(body, "status");
  return status === "approved" || status === "revision_requested" ? status : null;
}

function decisionLabel(decision: StudioApprovalRecord["status"]): string {
  if (decision === "approved") return "Approved for the next production step.";
  if (decision === "revision_requested") return "Revision requested before approval.";
  return "Approval is pending.";
}

function stringFromBody(body: unknown, key: string, code: string): string {
  if (!isRecord(body) || typeof body[key] !== "string" || body[key].trim().length === 0) {
    throw new ContractError(code, `${key} is required`, 400);
  }
  return body[key].trim();
}

function optionalStringFromBody(body: unknown, key: string): string | null {
  if (!isRecord(body) || typeof body[key] !== "string" || body[key].trim().length === 0) return null;
  return body[key].trim();
}

function trimmed(value: string, limit: number): string {
  return value.trim().slice(0, limit);
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function nowISO(): string {
  return new Date().toISOString();
}
