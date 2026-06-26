import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

async function session(role) {
  const result = await postJson("/v1/identity/dev/sign-in", { role });
  assertJsonResponse(result, 200);
  return {
    headers: { authorization: `HighFiveSession ${result.json.session.session_id}` },
    session: result.json.session
  };
}

test("beta: readiness advertises internal, external, and creator beta gates", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.beta_program_enabled, true);
  assert.equal(ready.json.internal_beta_ready, true);
  assert.equal(ready.json.external_beta_ready, true);
  assert.equal(ready.json.creator_beta_ready, true);
  assert.equal(ready.json.beta_feedback_enabled, true);
  assert.equal(ready.json.beta_crash_intake_enabled, true);
  assert.equal(ready.json.beta_resolution_workflow, true);
  assert.equal(ready.json.beta_audit_trail, true);
  assert.equal(ready.json.stable_beta, true);
});

test("beta: testers enroll into allowed cohorts and submit beta feedback", async () => {
  const viewer = await session("viewer");
  const creator = await session("creator");
  const admin = await session("admin");

  const viewerEnroll = await postJson("/v1/beta/enroll", { cohort: "external" }, viewer.headers);
  assertJsonResponse(viewerEnroll, 201);
  assert.equal(viewerEnroll.json.tester.cohort, "external");
  assert.equal(viewerEnroll.json.build.status, "beta_candidate");

  const creatorEnroll = await postJson("/v1/beta/enroll", { cohort: "creator" }, creator.headers);
  assertJsonResponse(creatorEnroll, 201);
  assert.equal(creatorEnroll.json.tester.cohort, "creator");

  const internalEnroll = await postJson("/v1/beta/enroll", { cohort: "internal" }, admin.headers);
  assertJsonResponse(internalEnroll, 201);
  assert.equal(internalEnroll.json.tester.cohort, "internal");

  const denied = await postJson("/v1/beta/enroll", { cohort: "creator" }, viewer.headers);
  assertJsonResponse(denied, 403);
  assert.equal(denied.json.error, "creator_beta_requires_creator");

  const feedback = await postJson("/v1/beta/feedback", {
    cohort: "external",
    category: "Playback",
    severity: "high",
    route: "player",
    message: "Playback resumed correctly after relaunch."
  }, viewer.headers);
  assertJsonResponse(feedback, 201);
  assert.equal(feedback.json.feedback.state, "open");
  assert.equal(feedback.json.stability.stable_beta, true);
  assertNoCredentialMaterial(feedback.json);
});

test("beta: crash reports block stability until admin resolves them", async () => {
  const creator = await session("creator");
  const admin = await session("admin");
  await postJson("/v1/beta/enroll", { cohort: "creator" }, creator.headers);

  const crash = await postJson("/v1/beta/crashes", {
    cohort: "creator",
    route: "creator_studio",
    exception_name: "CreatorWorkspaceRegression",
    app_version: "1.0.0-rc1"
  }, creator.headers);
  assertJsonResponse(crash, 201);
  assert.equal(crash.json.stability.stable_beta, false);
  assert.equal(crash.json.stability.blockers >= 1, true);

  const stabilityBefore = await requestJson("/v1/beta/stability", { headers: admin.headers });
  assertJsonResponse(stabilityBefore, 200);
  assert.equal(stabilityBefore.json.status, "needs_fixes");

  const resolved = await postJson(`/v1/beta/crashes/${crash.json.crash.id}/resolve`, { state: "fixed" }, admin.headers);
  assertJsonResponse(resolved, 200);
  assert.equal(resolved.json.status, "fixed");
  assert.equal(resolved.json.stability.stable_beta, true);

  const stabilityAfter = await requestJson("/v1/beta/stability", { headers: admin.headers });
  assertJsonResponse(stabilityAfter, 200);
  assert.equal(stabilityAfter.json.status, "stable_beta");
  assert.equal(stabilityAfter.json.stability.zero_blockers, true);
  assertNoCredentialMaterial(stabilityAfter.json);
});

test("beta: blocker feedback is visible to admins and can be resolved", async () => {
  const viewer = await session("viewer");
  const admin = await session("admin");
  await postJson("/v1/beta/enroll", { cohort: "external" }, viewer.headers);

  const feedback = await postJson("/v1/beta/feedback", {
    cohort: "external",
    category: "Library",
    severity: "blocker",
    route: "library",
    message: "Regression fixture for beta blocker triage."
  }, viewer.headers);
  assertJsonResponse(feedback, 201);
  assert.equal(feedback.json.stability.stable_beta, false);

  const program = await requestJson("/v1/beta/program", { headers: admin.headers });
  assertJsonResponse(program, 200);
  assert.equal(program.json.unresolved_feedback.some((record) => record.id === feedback.json.feedback.id), true);

  const resolved = await postJson(`/v1/beta/feedback/${feedback.json.feedback.id}/resolve`, { state: "resolved" }, admin.headers);
  assertJsonResponse(resolved, 200);
  assert.equal(resolved.json.status, "resolved");

  const audit = await requestJson("/v1/beta/audit", { headers: admin.headers });
  assertJsonResponse(audit, 200);
  assert.equal(audit.json.audit_records.some((record) => record.action === "beta_feedback_resolved"), true);
});
