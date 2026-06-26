import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

async function developmentSession(role = "admin") {
  const result = await postJson("/v1/identity/dev/sign-in", { role });
  assertJsonResponse(result, 200);
  return result.json.session.session_id;
}

function auth(sessionID) {
  return { authorization: `HighFiveSession ${sessionID}` };
}

test("operations: admin can inspect rights, moderation, health, and audit summary", async () => {
  const adminSession = await developmentSession("admin");
  const headers = auth(adminSession);

  const summary = await requestJson("/v1/admin/operations/summary", { headers });
  assertJsonResponse(summary, 200);
  assert.equal(summary.json.status, "ready");
  assert.ok(summary.json.rights_windows.length >= 1);
  assert.ok(summary.json.platform_health.some((record) => record.id === "catalog"));
  assertNoCredentialMaterial(summary.json);

  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.rights_windows_enabled, true);
  assert.equal(ready.json.availability_enforcement_enabled, true);
  assert.equal(ready.json.moderation_queue_enabled, true);
});

test("operations: viewer cannot administer platform operations", async () => {
  const viewerSession = await developmentSession("viewer");
  const rights = await requestJson("/v1/admin/operations/rights", { headers: auth(viewerSession) });
  assertJsonResponse(rights, 403);
  assert.equal(rights.json.error, "admin_role_required");
});

test("operations: rights window expiration removes catalog availability and restore returns it", async () => {
  const adminSession = await developmentSession("admin");
  const headers = auth(adminSession);

  const before = await requestJson("/v1/content/friendly", { headers });
  assertJsonResponse(before, 200);

  const expired = await postJson("/v1/admin/operations/rights/friendly/expire", { ends_at: "2026-01-01T00:00:00.000Z" }, headers);
  assertJsonResponse(expired, 200);
  assert.equal(expired.json.status, "expired");
  assert.equal(expired.json.availability.available, false);

  const unavailable = await requestJson("/v1/content/friendly", { headers });
  assertJsonResponse(unavailable, 404);

  const restored = await postJson("/v1/admin/operations/rights/friendly/restore", {}, headers);
  assertJsonResponse(restored, 200);
  assert.equal(restored.json.status, "restored");
  assert.equal(restored.json.availability.available, true);

  const after = await requestJson("/v1/content/friendly", { headers });
  assertJsonResponse(after, 200);
  assert.equal(after.json.id, "friendly");
});

test("operations: moderation takedown removes content until restored", async () => {
  const adminSession = await developmentSession("admin");
  const headers = auth(adminSession);

  const flagged = await postJson("/v1/admin/operations/moderation/flags", {
    content_id: "behind-the-vision",
    category: "Policy Review",
    note: "Smoke test flag for moderation takedown."
  }, headers);
  assertJsonResponse(flagged, 201);
  const caseID = flagged.json.moderation_case.id;

  const takedown = await postJson(`/v1/admin/operations/moderation/${caseID}/takedown`, { note: "Temporarily unavailable for policy review." }, headers);
  assertJsonResponse(takedown, 200);
  assert.equal(takedown.json.status, "takedown");
  assert.equal(takedown.json.availability.available, false);

  const hidden = await requestJson("/v1/content/behind-the-vision", { headers });
  assertJsonResponse(hidden, 404);

  const restored = await postJson(`/v1/admin/operations/moderation/${caseID}/restore`, { note: "Restored after admin review." }, headers);
  assertJsonResponse(restored, 200);
  assert.equal(restored.json.status, "restored");

  const visible = await requestJson("/v1/content/behind-the-vision", { headers });
  assertJsonResponse(visible, 200);
  assert.equal(visible.json.id, "behind-the-vision");

  const audit = await requestJson("/v1/admin/operations/audit", { headers });
  assertJsonResponse(audit, 200);
  assert.equal(audit.json.audit_records.some((record) => record.action === "moderation_takedown"), true);
  assertNoCredentialMaterial(audit.json);
});
