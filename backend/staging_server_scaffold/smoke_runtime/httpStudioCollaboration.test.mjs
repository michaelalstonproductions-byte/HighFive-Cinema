import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

async function session(role) {
  const result = await postJson("/v1/identity/dev/sign-in", { role });
  assertJsonResponse(result, 200);
  return {
    authorization: `HighFiveSession ${result.json.session.session_id}`,
    userID: result.json.session.user_id,
    creatorID: result.json.session.creator_id
  };
}

test("studio collaboration: readiness exposes local studio collaboration capabilities", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.studio_collaboration_enabled, true);
  assert.equal(ready.json.studio_collaboration_production_companies, true);
  assert.equal(ready.json.studio_collaboration_workspaces, true);
  assert.equal(ready.json.studio_collaboration_multi_user_editing, true);
  assert.equal(ready.json.studio_collaboration_role_permissions, true);
  assert.equal(ready.json.studio_collaboration_approvals, true);
  assert.equal(ready.json.studio_collaboration_shared_projects, true);
  assert.equal(ready.json.studio_collaboration_notifications, true);
  assert.equal(ready.json.studio_collaboration_external_services, false);
  assert.ok(ready.json.studio_collaboration_projects >= 1);
});

test("studio collaboration: summary returns seeded workspace and permission summary", async () => {
  const creator = await session("creator");
  const summary = await requestJson("/v2/studio-collaboration/summary", {
    headers: { authorization: creator.authorization }
  });
  assertJsonResponse(summary, 200);
  assert.ok(summary.json.companies.some((company) => company.id === "production-company-highfive"));
  assert.ok(summary.json.workspaces.some((workspace) => workspace.id === "studio-workspace-highfive"));
  assert.ok(summary.json.shared_projects.some((project) => project.id === "studio-project-behind-the-vision"));
  assert.ok(summary.json.permission_summary.some((record) => record.can_edit === true));
  assertNoCredentialMaterial(summary.json);
});

test("studio collaboration: creator can create company, workspace, project, collaborator, edits, and approvals", async () => {
  const creator = await session("creator");
  const creatorHeaders = { authorization: creator.authorization };

  const company = await postJson("/v2/studio-collaboration/companies", {
    name: "Moonrise Production Company"
  }, creatorHeaders);
  assertJsonResponse(company, 201);
  assert.equal(company.json.status, "created");

  const workspace = await postJson("/v2/studio-collaboration/workspaces", {
    company_id: company.json.company.id,
    name: "Moonrise Cut Room"
  }, creatorHeaders);
  assertJsonResponse(workspace, 201);
  assert.equal(workspace.json.workspace.company_id, company.json.company.id);

  const shared = await postJson("/v2/studio-collaboration/projects", {
    workspace_id: workspace.json.workspace.id,
    project_id: "project-behind-the-vision",
    title: "Moonrise Studio Collaboration"
  }, creatorHeaders);
  assertJsonResponse(shared, 201);
  const projectID = shared.json.shared_project.id;

  const collaborator = await postJson(`/v2/studio-collaboration/projects/${projectID}/collaborators`, {
    user_id: "local-editor",
    display_name: "Local Editor",
    role: "editor",
    permission: "edit"
  }, creatorHeaders);
  assertJsonResponse(collaborator, 201);
  assert.equal(collaborator.json.collaborator.permission, "edit");

  const reviewer = await postJson(`/v2/studio-collaboration/projects/${projectID}/collaborators`, {
    user_id: "local-admin",
    display_name: "HighFive Admin",
    role: "reviewer",
    permission: "review"
  }, creatorHeaders);
  assertJsonResponse(reviewer, 201);
  assert.equal(reviewer.json.collaborator.permission, "review");

  const edit = await postJson(`/v2/studio-collaboration/projects/${projectID}/edits`, {
    section: "trailer",
    summary: "Editor assembled the opening sequence for studio review."
  }, creatorHeaders);
  assertJsonResponse(edit, 201);
  assert.equal(edit.json.edit.section, "trailer");

  const approval = await postJson(`/v2/studio-collaboration/projects/${projectID}/approvals`, {
    reviewer_user_id: "local-admin",
    request_note: "Ready for studio approval."
  }, creatorHeaders);
  assertJsonResponse(approval, 201);
  assert.equal(approval.json.approval.status, "pending");

  const admin = await session("admin");
  const decision = await postJson(`/v2/studio-collaboration/projects/${projectID}/approvals/${approval.json.approval.id}/decision`, {
    status: "approved",
    decision_note: "Approved for release package preparation."
  }, { authorization: admin.authorization });
  assertJsonResponse(decision, 200);
  assert.equal(decision.json.approval.status, "approved");
  assert.equal(decision.json.shared_project.status, "approved");

  const summary = await requestJson("/v2/studio-collaboration/summary", {
    headers: creatorHeaders
  });
  assertJsonResponse(summary, 200);
  assert.ok(summary.json.edit_activity.some((record) => record.id === edit.json.edit.id));
  assert.ok(summary.json.approvals.some((record) => record.id === approval.json.approval.id && record.status === "approved"));
  assertNoCredentialMaterial(summary.json);
});

test("studio collaboration: viewer cannot access creator collaboration APIs", async () => {
  const viewer = await session("viewer");
  const summary = await requestJson("/v2/studio-collaboration/summary", {
    headers: { authorization: viewer.authorization }
  });
  assertJsonResponse(summary, 403);
  assert.equal(summary.json.error, "creator_role_required");

  const create = await postJson("/v2/studio-collaboration/projects", {
    project_id: "project-behind-the-vision"
  }, { authorization: viewer.authorization });
  assertJsonResponse(create, 403);
  assert.equal(create.json.error, "creator_role_required");
});

test("studio collaboration: OpenAPI exposes the V2 studio collaboration contract paths", async () => {
  const spec = await requestJson("/openapi.json");
  assertJsonResponse(spec, 200);
  assert.ok(spec.json.paths["/v2/studio-collaboration/summary"]);
  assert.ok(spec.json.paths["/v2/studio-collaboration/companies"]);
  assert.ok(spec.json.paths["/v2/studio-collaboration/workspaces"]);
  assert.ok(spec.json.paths["/v2/studio-collaboration/projects"]);
  assert.ok(spec.json.paths["/v2/studio-collaboration/projects/{id}/collaborators"]);
  assert.ok(spec.json.paths["/v2/studio-collaboration/projects/{id}/approvals/{approvalID}/decision"]);
});
