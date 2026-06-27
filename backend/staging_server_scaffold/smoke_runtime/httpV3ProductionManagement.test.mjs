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

test("v3 production management: readiness exposes local production capabilities", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.v3_production_management_enabled, true);
  assert.equal(ready.json.v3_production_films, true);
  assert.equal(ready.json.v3_production_series, true);
  assert.equal(ready.json.v3_production_projects, true);
  assert.equal(ready.json.v3_production_schedules, true);
  assert.equal(ready.json.v3_production_budgets, true);
  assert.equal(ready.json.v3_production_crew, true);
  assert.equal(ready.json.v3_production_assets, true);
  assert.equal(ready.json.v3_production_external_services, false);
  assert.ok(ready.json.v3_production_project_records >= 1);
  assert.ok(ready.json.v3_production_asset_records >= 1);
});

test("v3 production management: summary returns seeded production records", async () => {
  const creator = await session("creator");
  const summary = await requestJson("/v3/production-management/summary", {
    headers: { authorization: creator.authorization }
  });
  assertJsonResponse(summary, 200);
  assert.equal(summary.json.production, "local_v3_production_management");
  assert.equal(summary.json.external_services, false);
  assert.equal(summary.json.creator_id, creator.creatorID);
  assert.ok(summary.json.films.some((record) => record.id === "production-film-seed-1"));
  assert.ok(summary.json.series.some((record) => record.id === "production-series-seed-1"));
  assert.ok(summary.json.projects.some((record) => record.id === "production-project-seed-1"));
  assert.ok(summary.json.schedules.some((record) => record.id === "production-schedule-seed-1"));
  assert.ok(summary.json.budgets.some((record) => record.id === "production-budget-seed-1"));
  assert.ok(summary.json.crew.some((record) => record.id === "production-crew-seed-1"));
  assert.ok(summary.json.assets.some((record) => record.id === "production-asset-seed-1"));
  assert.ok(summary.json.dashboard.active_projects >= 1);
  assert.ok(summary.json.dashboard.schedule_windows >= 1);
  assertNoCredentialMaterial(summary.json);
});

test("v3 production management: creator can create production records", async () => {
  const creator = await session("creator");
  const headers = { authorization: creator.authorization };

  const film = await postJson("/v3/production-management/films", {
    title: "Night Drive",
    project_id: "project-behind-the-vision",
    status: "active",
    format: "short"
  }, headers);
  assertJsonResponse(film, 201);
  assert.equal(film.json.film.format, "short");

  const series = await postJson("/v3/production-management/series", {
    title: "Creator Workshop",
    project_id: "project-behind-the-vision",
    season_count: 2,
    episode_count: 8,
    status: "planning"
  }, headers);
  assertJsonResponse(series, 201);
  assert.equal(series.json.series.episode_count, 8);

  const project = await postJson("/v3/production-management/projects", {
    title: "Night Drive Production",
    content_id: "behind-the-vision",
    phase: "production",
    status: "active"
  }, headers);
  assertJsonResponse(project, 201);
  assert.equal(project.json.project.phase, "production");

  const schedule = await postJson("/v3/production-management/schedule", {
    project_id: project.json.project.id,
    title: "Editorial review",
    schedule_type: "edit",
    window_label: "Local review week",
    status: "review"
  }, headers);
  assertJsonResponse(schedule, 201);
  assert.equal(schedule.json.schedule.schedule_type, "edit");

  const budget = await postJson("/v3/production-management/budgets", {
    project_id: project.json.project.id,
    category: "production",
    planned_amount: 25000,
    committed_amount: 9000,
    status: "review"
  }, headers);
  assertJsonResponse(budget, 201);
  assert.equal(budget.json.budget.category, "production");
  assert.ok(budget.json.budget_summary.planned_amount >= 25000);

  const crew = await postJson("/v3/production-management/crew", {
    project_id: project.json.project.id,
    name: "Maya Hart",
    role: "director",
    status: "active"
  }, headers);
  assertJsonResponse(crew, 201);
  assert.equal(crew.json.crew_member.role, "director");

  const asset = await postJson("/v3/production-management/assets", {
    project_id: project.json.project.id,
    title: "Opening stills",
    asset_type: "still",
    status: "review",
    owner: "Maya Hart"
  }, headers);
  assertJsonResponse(asset, 201);
  assert.equal(asset.json.asset.asset_type, "still");

  const summary = await requestJson("/v3/production-management/summary", { headers });
  assertJsonResponse(summary, 200);
  assert.ok(summary.json.films.some((record) => record.id === film.json.film.id));
  assert.ok(summary.json.series.some((record) => record.id === series.json.series.id));
  assert.ok(summary.json.projects.some((record) => record.id === project.json.project.id));
  assert.ok(summary.json.schedules.some((record) => record.id === schedule.json.schedule.id));
  assert.ok(summary.json.budgets.some((record) => record.id === budget.json.budget.id));
  assert.ok(summary.json.crew.some((record) => record.id === crew.json.crew_member.id));
  assert.ok(summary.json.assets.some((record) => record.id === asset.json.asset.id));
});

test("v3 production management: viewer cannot access production management", async () => {
  const viewer = await session("viewer");
  const summary = await requestJson("/v3/production-management/summary", {
    headers: { authorization: viewer.authorization }
  });
  assertJsonResponse(summary, 403);
  assert.equal(summary.json.error, "creator_role_required");

  const project = await postJson("/v3/production-management/projects", {
    title: "Viewer Project"
  }, { authorization: viewer.authorization });
  assertJsonResponse(project, 403);
  assert.equal(project.json.error, "creator_role_required");
});

test("v3 production management: OpenAPI exposes production paths", async () => {
  const spec = await requestJson("/openapi.json");
  assertJsonResponse(spec, 200);
  assert.ok(spec.json.paths["/v3/production-management/summary"]);
  assert.ok(spec.json.paths["/v3/production-management/films"]);
  assert.ok(spec.json.paths["/v3/production-management/series"]);
  assert.ok(spec.json.paths["/v3/production-management/projects"]);
  assert.ok(spec.json.paths["/v3/production-management/schedule"]);
  assert.ok(spec.json.paths["/v3/production-management/budgets"]);
  assert.ok(spec.json.paths["/v3/production-management/crew"]);
  assert.ok(spec.json.paths["/v3/production-management/assets"]);
});
