import { catalogSeed } from "../catalog/catalogSeed.js";
import type { JsonObject } from "../contracts.js";
import { ContractError } from "../errors.js";
import { requireIdentitySession, type IdentitySession } from "./identity.js";

type OrganizationRecord = {
  id: string;
  name: string;
  owner_user_id: string;
  creator_id: string | null;
  studio_tier: "independent" | "studio" | "enterprise";
  state: "active" | "review";
  created_at: string;
  updated_at: string;
};

type StudioAccountRecord = {
  id: string;
  organization_id: string;
  user_id: string;
  display_name: string;
  role: "owner" | "admin" | "producer" | "editor" | "viewer";
  status: "active" | "invited";
  created_at: string;
  updated_at: string;
};

type WorkspaceRecord = {
  id: string;
  organization_id: string;
  name: string;
  workspace_type: "development" | "production" | "distribution" | "analytics";
  project_ids: string[];
  state: "active" | "archived";
  created_at: string;
  updated_at: string;
};

type PermissionRecord = {
  id: string;
  organization_id: string;
  account_id: string;
  workspace_id: string;
  permission: "owner" | "manage" | "edit" | "review" | "view";
  scope: "organization" | "workspace" | "library";
  created_at: string;
  updated_at: string;
};

type DepartmentRecord = {
  id: string;
  organization_id: string;
  name: string;
  lead_account_id: string;
  workspace_ids: string[];
  focus: "production" | "post" | "distribution" | "analytics" | "operations";
  created_at: string;
  updated_at: string;
};

type SharedLibraryRecord = {
  id: string;
  organization_id: string;
  name: string;
  collection_ids: string[];
  title_ids: string[];
  workspace_ids: string[];
  access_level: "private" | "department" | "organization";
  created_at: string;
  updated_at: string;
};

const organizations: OrganizationRecord[] = [];
const accounts: StudioAccountRecord[] = [];
const workspaces: WorkspaceRecord[] = [];
const permissions: PermissionRecord[] = [];
const departments: DepartmentRecord[] = [];
const sharedLibraries: SharedLibraryRecord[] = [];

let organizationCounter = 1;
let accountCounter = 1;
let workspaceCounter = 1;
let permissionCounter = 1;
let departmentCounter = 1;
let libraryCounter = 1;

seedEnterpriseStudios();

export function v3EnterpriseStudiosReadinessSummary(): JsonObject {
  return {
    v3_enterprise_studios_enabled: true,
    studio_accounts: true,
    organizations: true,
    multiple_workspaces: true,
    permissions: true,
    departments: true,
    shared_libraries: true,
    external_services: false,
    organization_records: organizations.length,
    workspace_records: workspaces.length,
    shared_library_records: sharedLibraries.length
  };
}

export function v3EnterpriseStudiosSummary(authorizationHeader: string | undefined): JsonObject {
  const session = requireEnterpriseSession(authorizationHeader);
  const visibleOrganizations = organizations.filter((record) => visibleOrganization(session, record));
  const organizationIDs = new Set(visibleOrganizations.map((record) => record.id));
  return {
    status: "ready",
    enterprise_studios: "local_v3_enterprise_studios",
    external_services: false,
    user_id: session.user_id,
    creator_id: session.creator_id,
    organizations: visibleOrganizations,
    accounts: accounts.filter((record) => organizationIDs.has(record.organization_id)),
    workspaces: workspaces.filter((record) => organizationIDs.has(record.organization_id)),
    permissions: permissions.filter((record) => organizationIDs.has(record.organization_id)),
    departments: departments.filter((record) => organizationIDs.has(record.organization_id)),
    shared_libraries: sharedLibraries.filter((record) => organizationIDs.has(record.organization_id)),
    dashboard: enterpriseStudioDashboard(organizationIDs),
    generated_at: nowISO()
  };
}

export function createEnterpriseOrganization(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireEnterpriseSession(authorizationHeader);
  const organization: OrganizationRecord = {
    id: `enterprise-organization-${organizationCounter++}`,
    name: trimmed(optionalString(body, "name") ?? `${session.display_name} Enterprise Studio`, 140),
    owner_user_id: session.user_id,
    creator_id: session.creator_id,
    studio_tier: studioTier(optionalString(body, "studio_tier")),
    state: organizationState(optionalString(body, "state")),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  organizations.push(organization);

  const ownerAccount: StudioAccountRecord = {
    id: `enterprise-account-${accountCounter++}`,
    organization_id: organization.id,
    user_id: session.user_id,
    display_name: session.display_name,
    role: "owner",
    status: "active",
    created_at: nowISO(),
    updated_at: nowISO()
  };
  accounts.push(ownerAccount);

  return {
    status: "created",
    organization,
    owner_account: ownerAccount
  };
}

export function createEnterpriseAccount(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireEnterpriseSession(authorizationHeader);
  const organization = organizationForRequest(session, optionalString(body, "organization_id"));
  const account: StudioAccountRecord = {
    id: `enterprise-account-${accountCounter++}`,
    organization_id: organization.id,
    user_id: trimmed(optionalString(body, "user_id") ?? `local-studio-user-${accountCounter}`, 120),
    display_name: trimmed(optionalString(body, "display_name") ?? "Studio Teammate", 120),
    role: accountRole(optionalString(body, "role")),
    status: accountStatus(optionalString(body, "status")),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  accounts.push(account);
  return {
    status: "created",
    account
  };
}

export function createEnterpriseWorkspace(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireEnterpriseSession(authorizationHeader);
  const organization = organizationForRequest(session, optionalString(body, "organization_id"));
  const workspace: WorkspaceRecord = {
    id: `enterprise-workspace-${workspaceCounter++}`,
    organization_id: organization.id,
    name: trimmed(optionalString(body, "name") ?? `${organization.name} Workspace`, 120),
    workspace_type: workspaceType(optionalString(body, "workspace_type")),
    project_ids: stringArray(body, "project_ids", defaultProjectIDs()),
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

export function createEnterprisePermission(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireEnterpriseSession(authorizationHeader);
  const organization = organizationForRequest(session, optionalString(body, "organization_id"));
  const account = accountForRequest(organization.id, optionalString(body, "account_id"));
  const workspace = workspaceForRequest(organization.id, optionalString(body, "workspace_id"));
  const permission: PermissionRecord = {
    id: `enterprise-permission-${permissionCounter++}`,
    organization_id: organization.id,
    account_id: account.id,
    workspace_id: workspace.id,
    permission: permissionLevel(optionalString(body, "permission")),
    scope: permissionScope(optionalString(body, "scope")),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  permissions.push(permission);
  return {
    status: "created",
    permission,
    effective_permissions: effectivePermissions(organization.id, account.id)
  };
}

export function createEnterpriseDepartment(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireEnterpriseSession(authorizationHeader);
  const organization = organizationForRequest(session, optionalString(body, "organization_id"));
  const account = accountForRequest(organization.id, optionalString(body, "lead_account_id"));
  const workspaceIDs = stringArray(body, "workspace_ids", workspacesForOrganization(organization.id).slice(0, 2).map((workspace) => workspace.id));
  const department: DepartmentRecord = {
    id: `enterprise-department-${departmentCounter++}`,
    organization_id: organization.id,
    name: trimmed(optionalString(body, "name") ?? "Production Department", 120),
    lead_account_id: account.id,
    workspace_ids: workspaceIDs,
    focus: departmentFocus(optionalString(body, "focus")),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  departments.push(department);
  return {
    status: "created",
    department
  };
}

export function createEnterpriseSharedLibrary(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireEnterpriseSession(authorizationHeader);
  const organization = organizationForRequest(session, optionalString(body, "organization_id"));
  const library: SharedLibraryRecord = {
    id: `enterprise-shared-library-${libraryCounter++}`,
    organization_id: organization.id,
    name: trimmed(optionalString(body, "name") ?? "Studio Shared Library", 120),
    collection_ids: stringArray(body, "collection_ids", catalogSeed.collections.slice(0, 2).map((collection) => collection.id)),
    title_ids: stringArray(body, "title_ids", catalogSeed.movies.slice(0, 4).map((movie) => movie.id)),
    workspace_ids: stringArray(body, "workspace_ids", workspacesForOrganization(organization.id).slice(0, 2).map((workspace) => workspace.id)),
    access_level: libraryAccessLevel(optionalString(body, "access_level")),
    created_at: nowISO(),
    updated_at: nowISO()
  };
  sharedLibraries.push(library);
  return {
    status: "created",
    shared_library: library
  };
}

function seedEnterpriseStudios(): void {
  if (organizations.length > 0) return;
  const creatorID = "maya-hart";
  const organizationID = "enterprise-organization-seed-1";
  const ownerAccountID = "enterprise-account-seed-owner";
  const producerAccountID = "enterprise-account-seed-producer";
  const workspaceID = "enterprise-workspace-seed-1";
  organizations.push({
    id: organizationID,
    name: "HighFive Studio Group",
    owner_user_id: "local-admin",
    creator_id: creatorID,
    studio_tier: "enterprise",
    state: "active",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  accounts.push({
    id: ownerAccountID,
    organization_id: organizationID,
    user_id: "local-admin",
    display_name: "HighFive Admin",
    role: "owner",
    status: "active",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  accounts.push({
    id: producerAccountID,
    organization_id: organizationID,
    user_id: "local-producer",
    display_name: "Local Producer",
    role: "producer",
    status: "active",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  workspaces.push({
    id: workspaceID,
    organization_id: organizationID,
    name: "Feature Production Workspace",
    workspace_type: "production",
    project_ids: defaultProjectIDs(),
    state: "active",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  permissions.push({
    id: "enterprise-permission-seed-1",
    organization_id: organizationID,
    account_id: ownerAccountID,
    workspace_id: workspaceID,
    permission: "owner",
    scope: "organization",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  departments.push({
    id: "enterprise-department-seed-1",
    organization_id: organizationID,
    name: "Production Operations",
    lead_account_id: producerAccountID,
    workspace_ids: [workspaceID],
    focus: "production",
    created_at: nowISO(),
    updated_at: nowISO()
  });
  sharedLibraries.push({
    id: "enterprise-shared-library-seed-1",
    organization_id: organizationID,
    name: "Studio Review Shelf",
    collection_ids: catalogSeed.collections.slice(0, 2).map((collection) => collection.id),
    title_ids: catalogSeed.movies.slice(0, 4).map((movie) => movie.id),
    workspace_ids: [workspaceID],
    access_level: "organization",
    created_at: nowISO(),
    updated_at: nowISO()
  });
}

function requireEnterpriseSession(authorizationHeader: string | undefined): IdentitySession {
  const session = requireIdentitySession(authorizationHeader);
  if (session.role !== "creator" && session.role !== "admin") {
    throw new ContractError("enterprise_studio_role_required", "Enterprise studio operations require a creator or admin session", 403);
  }
  return session;
}

function visibleOrganization(session: IdentitySession, organization: OrganizationRecord): boolean {
  return session.role === "admin" || organization.owner_user_id === session.user_id || organization.creator_id === session.creator_id;
}

function organizationForRequest(session: IdentitySession, requestedID: string | null): OrganizationRecord {
  const visible = organizations.filter((record) => visibleOrganization(session, record));
  const requested = requestedID ? visible.find((record) => record.id === requestedID) : null;
  const fallback = visible[0];
  if (!requested && !fallback) {
    throw new ContractError("enterprise_organization_required", "A visible enterprise organization is required", 400);
  }
  return requested ?? fallback;
}

function accountForRequest(organizationID: string, requestedID: string | null): StudioAccountRecord {
  const records = accounts.filter((record) => record.organization_id === organizationID);
  const requested = requestedID ? records.find((record) => record.id === requestedID) : null;
  return requested ?? records[0] ?? {
    id: "enterprise-account-missing",
    organization_id: organizationID,
    user_id: "local-missing",
    display_name: "Local Missing Account",
    role: "viewer",
    status: "invited",
    created_at: nowISO(),
    updated_at: nowISO()
  };
}

function workspaceForRequest(organizationID: string, requestedID: string | null): WorkspaceRecord {
  const records = workspacesForOrganization(organizationID);
  const requested = requestedID ? records.find((record) => record.id === requestedID) : null;
  return requested ?? records[0] ?? {
    id: "enterprise-workspace-missing",
    organization_id: organizationID,
    name: "Local Missing Workspace",
    workspace_type: "production",
    project_ids: [],
    state: "archived",
    created_at: nowISO(),
    updated_at: nowISO()
  };
}

function workspacesForOrganization(organizationID: string): WorkspaceRecord[] {
  return workspaces.filter((record) => record.organization_id === organizationID);
}

function enterpriseStudioDashboard(organizationIDs: Set<string>): JsonObject {
  const organizationWorkspaces = workspaces.filter((record) => organizationIDs.has(record.organization_id));
  const organizationAccounts = accounts.filter((record) => organizationIDs.has(record.organization_id));
  const organizationLibraries = sharedLibraries.filter((record) => organizationIDs.has(record.organization_id));
  return {
    organizations: organizationIDs.size,
    active_accounts: organizationAccounts.filter((record) => record.status === "active").length,
    active_workspaces: organizationWorkspaces.filter((record) => record.state === "active").length,
    departments: departments.filter((record) => organizationIDs.has(record.organization_id)).length,
    shared_libraries: organizationLibraries.length,
    shared_titles: new Set(organizationLibraries.flatMap((record) => record.title_ids)).size,
    permission_records: permissions.filter((record) => organizationIDs.has(record.organization_id)).length
  };
}

function effectivePermissions(organizationID: string, accountID: string): JsonObject {
  const records = permissions.filter((record) => record.organization_id === organizationID && record.account_id === accountID);
  return {
    account_id: accountID,
    organization_id: organizationID,
    permissions: records.map((record) => ({
      workspace_id: record.workspace_id,
      permission: record.permission,
      scope: record.scope
    }))
  };
}

function optionalString(body: unknown, key: string): string | null {
  if (!isRecord(body)) return null;
  return typeof body[key] === "string" && body[key].trim().length > 0 ? body[key].trim() : null;
}

function stringArray(body: unknown, key: string, fallback: string[]): string[] {
  if (!isRecord(body) || !Array.isArray(body[key])) return fallback;
  const values = body[key].filter((value): value is string => typeof value === "string" && value.trim().length > 0);
  return values.length > 0 ? values.map((value) => value.trim()) : fallback;
}

function defaultProjectIDs(): string[] {
  return catalogSeed.publishing_projects.slice(0, 4).map((project) => project.id);
}

function studioTier(value: string | null): OrganizationRecord["studio_tier"] {
  if (value === "independent" || value === "studio") return value;
  return "enterprise";
}

function organizationState(value: string | null): OrganizationRecord["state"] {
  return value === "review" ? "review" : "active";
}

function accountRole(value: string | null): StudioAccountRecord["role"] {
  if (value === "admin" || value === "producer" || value === "editor" || value === "viewer") return value;
  return "owner";
}

function accountStatus(value: string | null): StudioAccountRecord["status"] {
  return value === "invited" ? "invited" : "active";
}

function workspaceType(value: string | null): WorkspaceRecord["workspace_type"] {
  if (value === "development" || value === "distribution" || value === "analytics") return value;
  return "production";
}

function permissionLevel(value: string | null): PermissionRecord["permission"] {
  if (value === "manage" || value === "edit" || value === "review" || value === "view") return value;
  return "owner";
}

function permissionScope(value: string | null): PermissionRecord["scope"] {
  if (value === "workspace" || value === "library") return value;
  return "organization";
}

function departmentFocus(value: string | null): DepartmentRecord["focus"] {
  if (value === "post" || value === "distribution" || value === "analytics" || value === "operations") return value;
  return "production";
}

function libraryAccessLevel(value: string | null): SharedLibraryRecord["access_level"] {
  if (value === "private" || value === "department") return value;
  return "organization";
}

function trimmed(value: string, limit: number): string {
  const clean = value.trim();
  return clean.length <= limit ? clean : clean.slice(0, limit).trim();
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function nowISO(): string {
  return new Date().toISOString();
}
