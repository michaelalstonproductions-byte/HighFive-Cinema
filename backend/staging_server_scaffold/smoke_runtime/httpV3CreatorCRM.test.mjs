import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

async function session(role) {
  const result = await postJson("/v1/identity/dev/sign-in", { role });
  assertJsonResponse(result, 200);
  return {
    authorization: `HighFiveSession ${result.json.session.session_id}`,
    creatorID: result.json.session.creator_id
  };
}

test("v3 creator CRM: readiness exposes local CRM capabilities", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.v3_creator_crm_enabled, true);
  assert.equal(ready.json.v3_creator_crm_inbox, true);
  assert.equal(ready.json.v3_creator_crm_contracts, true);
  assert.equal(ready.json.v3_creator_crm_tasks, true);
  assert.equal(ready.json.v3_creator_crm_milestones, true);
  assert.equal(ready.json.v3_creator_crm_teams, true);
  assert.equal(ready.json.v3_creator_crm_deliverables, true);
  assert.equal(ready.json.v3_creator_crm_external_services, false);
  assert.ok(ready.json.v3_creator_crm_inbox_records >= 1);
  assert.ok(ready.json.v3_creator_crm_task_records >= 1);
});

test("v3 creator CRM: summary returns seeded inbox, contracts, tasks, teams, and deliverables", async () => {
  const creator = await session("creator");
  const summary = await requestJson("/v3/creator-crm/summary", {
    headers: { authorization: creator.authorization }
  });
  assertJsonResponse(summary, 200);
  assert.equal(summary.json.crm, "local_v3_creator_crm");
  assert.equal(summary.json.external_services, false);
  assert.equal(summary.json.creator_id, creator.creatorID);
  assert.ok(summary.json.inbox.some((record) => record.id === "crm-inbox-seed-1"));
  assert.ok(summary.json.contracts.some((record) => record.id === "crm-contract-seed-1"));
  assert.ok(summary.json.tasks.some((record) => record.id === "crm-task-seed-1"));
  assert.ok(summary.json.teams.some((record) => record.id === "crm-team-seed-1"));
  assert.ok(summary.json.deliverables.some((record) => record.id === "crm-deliverable-seed-1"));
  assert.ok(summary.json.dashboard.open_tasks >= 1);
  assertNoCredentialMaterial(summary.json);
});

test("v3 creator CRM: creator can create inbox, contract, task, milestone, team, and deliverable records", async () => {
  const creator = await session("creator");
  const headers = { authorization: creator.authorization };

  const inbox = await postJson("/v3/creator-crm/inbox", {
    from: "Local Producer",
    subject: "Campaign notes ready",
    category: "crew",
    project_id: "project-behind-the-vision"
  }, headers);
  assertJsonResponse(inbox, 201);
  assert.equal(inbox.json.inbox_record.category, "crew");

  const contract = await postJson("/v3/creator-crm/contracts", {
    project_id: "project-behind-the-vision",
    partner_name: "HighFive Studio Services",
    contract_type: "services",
    value_preview: "Local services planning"
  }, headers);
  assertJsonResponse(contract, 201);
  assert.equal(contract.json.contract.contract_type, "services");

  const task = await postJson("/v3/creator-crm/tasks", {
    project_id: "project-behind-the-vision",
    title: "Send trailer notes to editor",
    owner: "Maya Hart",
    status: "in_progress",
    priority: "high",
    due_label: "Tomorrow"
  }, headers);
  assertJsonResponse(task, 201);
  assert.equal(task.json.task.priority, "high");
  assert.ok(task.json.task_board.in_progress.some((record) => record.id === task.json.task.id));

  const milestone = await postJson("/v3/creator-crm/milestones", {
    project_id: "project-behind-the-vision",
    title: "Creator review locked",
    status: "review",
    target_label: "Release prep"
  }, headers);
  assertJsonResponse(milestone, 201);
  assert.equal(milestone.json.milestone.status, "review");

  const team = await postJson("/v3/creator-crm/teams", {
    name: "Release Team",
    members: [
      { name: "Maya Hart", role: "Director", permission: "owner" },
      { name: "Local Editor", role: "Editor", permission: "edit" }
    ]
  }, headers);
  assertJsonResponse(team, 201);
  assert.equal(team.json.team.members.length, 2);

  const deliverable = await postJson("/v3/creator-crm/deliverables", {
    project_id: "project-behind-the-vision",
    title: "Final trailer cut",
    kind: "trailer",
    status: "review",
    owner: "Local Editor"
  }, headers);
  assertJsonResponse(deliverable, 201);
  assert.equal(deliverable.json.deliverable.kind, "trailer");

  const summary = await requestJson("/v3/creator-crm/summary", { headers });
  assertJsonResponse(summary, 200);
  assert.ok(summary.json.inbox.some((record) => record.id === inbox.json.inbox_record.id));
  assert.ok(summary.json.contracts.some((record) => record.id === contract.json.contract.id));
  assert.ok(summary.json.milestones.some((record) => record.id === milestone.json.milestone.id));
  assert.ok(summary.json.deliverables.some((record) => record.id === deliverable.json.deliverable.id));
});

test("v3 creator CRM: viewer cannot access creator CRM", async () => {
  const viewer = await session("viewer");
  const summary = await requestJson("/v3/creator-crm/summary", {
    headers: { authorization: viewer.authorization }
  });
  assertJsonResponse(summary, 403);
  assert.equal(summary.json.error, "creator_role_required");

  const task = await postJson("/v3/creator-crm/tasks", {
    title: "Viewer task"
  }, { authorization: viewer.authorization });
  assertJsonResponse(task, 403);
  assert.equal(task.json.error, "creator_role_required");
});

test("v3 creator CRM: OpenAPI exposes CRM paths", async () => {
  const spec = await requestJson("/openapi.json");
  assertJsonResponse(spec, 200);
  assert.ok(spec.json.paths["/v3/creator-crm/summary"]);
  assert.ok(spec.json.paths["/v3/creator-crm/inbox"]);
  assert.ok(spec.json.paths["/v3/creator-crm/contracts"]);
  assert.ok(spec.json.paths["/v3/creator-crm/tasks"]);
  assert.ok(spec.json.paths["/v3/creator-crm/milestones"]);
  assert.ok(spec.json.paths["/v3/creator-crm/teams"]);
  assert.ok(spec.json.paths["/v3/creator-crm/deliverables"]);
});
