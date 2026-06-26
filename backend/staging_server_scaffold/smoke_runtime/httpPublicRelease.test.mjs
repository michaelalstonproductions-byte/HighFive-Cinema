import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

async function adminSession() {
  const result = await postJson("/v1/identity/dev/sign-in", { role: "admin" });
  assertJsonResponse(result, 200);
  return { authorization: `HighFiveSession ${result.json.session.session_id}` };
}

async function viewerSession() {
  const result = await postJson("/v1/identity/dev/sign-in", { role: "viewer" });
  assertJsonResponse(result, 200);
  return { authorization: `HighFiveSession ${result.json.session.session_id}` };
}

test("public release: readiness exposes release operations and manual external submission state", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.public_release_operations_enabled, true);
  assert.equal(ready.json.public_release_submission_record_enabled, true);
  assert.equal(ready.json.public_release_cutover_enabled, true);
  assert.equal(ready.json.public_release_monitoring_enabled, true);
  assert.equal(ready.json.public_release_hotfix_tracking_enabled, true);
  assert.equal(ready.json.public_release_launch_analytics_enabled, true);
  assert.equal(ready.json.public_release_creator_onboarding_enabled, true);
  assert.equal(ready.json.public_release_audit_trail_enabled, true);
  assert.equal(ready.json.public_release_external_submission_required, true);
});

test("public release: non-admin identities cannot run release operations", async () => {
  const viewer = await viewerSession();
  const summary = await requestJson("/v1/release/public/summary", { headers: viewer });
  assertJsonResponse(summary, 403);
  assert.equal(summary.json.error, "admin_role_required");
});

test("public release: admin records submit, cutover, monitor, hotfix, onboarding, and audit", async () => {
  const admin = await adminSession();

  const initial = await requestJson("/v1/release/public/summary", { headers: admin });
  assertJsonResponse(initial, 200);
  assert.equal(initial.json.release.state, "candidate");

  const submitted = await postJson("/v1/release/public/submit", {
    external_submission_confirmed: true
  }, admin);
  assertJsonResponse(submitted, 200);
  assert.equal(submitted.json.status, "submission_confirmed");
  assert.equal(submitted.json.release.state, "submitted");

  const released = await postJson("/v1/release/public/cutover", {
    public_release_confirmed: true
  }, admin);
  assertJsonResponse(released, 200);
  assert.equal(released.json.status, "released");
  assert.equal(released.json.release.state, "released");
  assert.equal(released.json.monitoring.rollback_ready, true);

  const hotfix = await postJson("/v1/release/public/hotfixes", {
    title: "Launch telemetry follow-up",
    severity: "medium"
  }, admin);
  assertJsonResponse(hotfix, 201);
  assert.equal(hotfix.json.status, "hotfix_opened");
  assert.equal(hotfix.json.monitoring.app_health, "watching");

  const hotfixClosed = await postJson(`/v1/release/public/hotfixes/${hotfix.json.hotfix.id}/update`, {
    state: "closed"
  }, admin);
  assertJsonResponse(hotfixClosed, 200);
  assert.equal(hotfixClosed.json.status, "closed");
  assert.equal(hotfixClosed.json.monitoring.app_health, "stable");

  const creator = await postJson("/v1/release/public/creator-onboarding", {
    creator_id: "maya-hart",
    title: "Maya Hart launch creator",
    activated: true,
    checklist: ["profile reviewed", "release published", "support owner assigned"]
  }, admin);
  assertJsonResponse(creator, 201);
  assert.equal(creator.json.status, "activated");
  assert.equal(creator.json.analytics.creator_onboarded_count >= 1, true);

  const monitor = await requestJson("/v1/release/public/monitor", { headers: admin });
  assertJsonResponse(monitor, 200);
  assert.equal(monitor.json.status, "monitoring");
  assert.equal(monitor.json.release.state, "released");
  assert.equal(monitor.json.monitoring.app_health, "stable");
  assertNoCredentialMaterial(monitor.json);

  const audit = await requestJson("/v1/release/public/audit", { headers: admin });
  assertJsonResponse(audit, 200);
  assert.equal(audit.json.audit_records.some((record) => record.action === "public_release_cutover"), true);
});

test("public release: cutover requires explicit manual confirmation", async () => {
  const admin = await adminSession();
  await postJson("/v1/release/public/submit", { external_submission_confirmed: true }, admin);
  const result = await postJson("/v1/release/public/cutover", { public_release_confirmed: false }, admin);
  assertJsonResponse(result, 422);
  assert.equal(result.json.error, "public_release_confirmation_required");
});
