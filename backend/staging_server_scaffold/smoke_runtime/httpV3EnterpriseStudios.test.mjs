import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

async function session(role) {
  const result = await postJson("/v1/identity/dev/sign-in", { role });
  assertJsonResponse(result, 200);
  return {
    authorization: `HighFiveSession ${result.json.session.session_id}`,
    creatorID: result.json.session.creator_id,
    userID: result.json.session.user_id
  };
}

test("v3 enterprise studios: readiness exposes local enterprise capabilities", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.v3_enterprise_studios_enabled, true);
  assert.equal(ready.json.v3_enterprise_studio_accounts, true);
  assert.equal(ready.json.v3_enterprise_studio_organizations, true);
  assert.equal(ready.json.v3_enterprise_studio_multiple_workspaces, true);
  assert.equal(ready.json.v3_enterprise_studio_permissions, true);
  assert.equal(ready.json.v3_enterprise_studio_departments, true);
  assert.equal(ready.json.v3_enterprise_studio_shared_libraries, true);
  assert.equal(ready.json.v3_enterprise_studio_external_services, false);
  assert.ok(ready.json.v3_enterprise_studio_organization_records >= 1);
  assert.ok(ready.json.v3_enterprise_studio_workspace_records >= 1);
  assert.ok(ready.json.v3_enterprise_studio_shared_library_records >= 1);
});

test("v3 enterprise studios: summary returns seeded organizations, accounts, workspaces, departments, and libraries", async () => {
  const admin = await session("admin");
  const summary = await requestJson("/v3/enterprise-studios/summary", {
    headers: { authorization: admin.authorization }
  });
  assertJsonResponse(summary, 200);
  assert.equal(summary.json.enterprise_studios, "local_v3_enterprise_studios");
  assert.equal(summary.json.external_services, false);
  assert.equal(summary.json.user_id, admin.userID);
  assert.ok(summary.json.organizations.some((record) => record.id === "enterprise-organization-seed-1"));
  assert.ok(summary.json.accounts.some((record) => record.id === "enterprise-account-seed-owner"));
  assert.ok(summary.json.workspaces.some((record) => record.id === "enterprise-workspace-seed-1"));
  assert.ok(summary.json.permissions.some((record) => record.id === "enterprise-permission-seed-1"));
  assert.ok(summary.json.departments.some((record) => record.id === "enterprise-department-seed-1"));
  assert.ok(summary.json.shared_libraries.some((record) => record.id === "enterprise-shared-library-seed-1"));
  assert.ok(summary.json.dashboard.active_workspaces >= 1);
  assert.ok(summary.json.dashboard.shared_titles >= 1);
  assertNoCredentialMaterial(summary.json);
});

test("v3 enterprise studios: creator can create organization, account, workspace, permission, department, and shared library records", async () => {
  const creator = await session("creator");
  const headers = { authorization: creator.authorization };

  const organization = await postJson("/v3/enterprise-studios/organizations", {
    name: "Creator Enterprise Studio",
    studio_tier: "studio"
  }, headers);
  assertJsonResponse(organization, 201);
  assert.equal(organization.json.organization.studio_tier, "studio");

  const account = await postJson("/v3/enterprise-studios/accounts", {
    organization_id: organization.json.organization.id,
    user_id: "local-editor",
    display_name: "Local Editor",
    role: "editor",
    status: "active"
  }, headers);
  assertJsonResponse(account, 201);
  assert.equal(account.json.account.role, "editor");

  const workspace = await postJson("/v3/enterprise-studios/workspaces", {
    organization_id: organization.json.organization.id,
    name: "Post Production Workspace",
    workspace_type: "production",
    project_ids: ["project-behind-the-vision"]
  }, headers);
  assertJsonResponse(workspace, 201);
  assert.equal(workspace.json.workspace.workspace_type, "production");

  const permission = await postJson("/v3/enterprise-studios/permissions", {
    organization_id: organization.json.organization.id,
    account_id: account.json.account.id,
    workspace_id: workspace.json.workspace.id,
    permission: "edit",
    scope: "workspace"
  }, headers);
  assertJsonResponse(permission, 201);
  assert.equal(permission.json.permission.permission, "edit");
  assert.equal(permission.json.effective_permissions.permissions.length, 1);

  const department = await postJson("/v3/enterprise-studios/departments", {
    organization_id: organization.json.organization.id,
    lead_account_id: account.json.account.id,
    workspace_ids: [workspace.json.workspace.id],
    name: "Post Department",
    focus: "post"
  }, headers);
  assertJsonResponse(department, 201);
  assert.equal(department.json.department.focus, "post");

  const library = await postJson("/v3/enterprise-studios/shared-libraries", {
    organization_id: organization.json.organization.id,
    name: "Editorial Library",
    title_ids: ["friendly", "big-loss"],
    workspace_ids: [workspace.json.workspace.id],
    access_level: "department"
  }, headers);
  assertJsonResponse(library, 201);
  assert.equal(library.json.shared_library.access_level, "department");

  const summary = await requestJson("/v3/enterprise-studios/summary", { headers });
  assertJsonResponse(summary, 200);
  assert.ok(summary.json.organizations.some((record) => record.id === organization.json.organization.id));
  assert.ok(summary.json.accounts.some((record) => record.id === account.json.account.id));
  assert.ok(summary.json.workspaces.some((record) => record.id === workspace.json.workspace.id));
  assert.ok(summary.json.permissions.some((record) => record.id === permission.json.permission.id));
  assert.ok(summary.json.departments.some((record) => record.id === department.json.department.id));
  assert.ok(summary.json.shared_libraries.some((record) => record.id === library.json.shared_library.id));
});

test("v3 enterprise studios: viewer cannot access enterprise studios", async () => {
  const viewer = await session("viewer");
  const summary = await requestJson("/v3/enterprise-studios/summary", {
    headers: { authorization: viewer.authorization }
  });
  assertJsonResponse(summary, 403);
  assert.equal(summary.json.error, "enterprise_studio_role_required");

  const organization = await postJson("/v3/enterprise-studios/organizations", {
    name: "Viewer Studio"
  }, { authorization: viewer.authorization });
  assertJsonResponse(organization, 403);
  assert.equal(organization.json.error, "enterprise_studio_role_required");
});

test("v3 enterprise studios: OpenAPI exposes enterprise studio paths", async () => {
  const spec = await requestJson("/openapi.json");
  assertJsonResponse(spec, 200);
  assert.ok(spec.json.paths["/v3/enterprise-studios/summary"]);
  assert.ok(spec.json.paths["/v3/enterprise-studios/organizations"]);
  assert.ok(spec.json.paths["/v3/enterprise-studios/accounts"]);
  assert.ok(spec.json.paths["/v3/enterprise-studios/workspaces"]);
  assert.ok(spec.json.paths["/v3/enterprise-studios/permissions"]);
  assert.ok(spec.json.paths["/v3/enterprise-studios/departments"]);
  assert.ok(spec.json.paths["/v3/enterprise-studios/shared-libraries"]);
});
