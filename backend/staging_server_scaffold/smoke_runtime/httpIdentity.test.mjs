import assert from "node:assert/strict";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

test("identity: development sign-in creates a creator session", async () => {
  const result = await postJson("/v1/identity/dev/sign-in", { role: "creator" });
  assertJsonResponse(result, 200);
  assert.equal(result.json.status, "authenticated");
  assert.equal(result.json.session.role, "creator");
  assert.equal(result.json.permissions.some((permission) => permission.id === "creator" && permission.status === "allowed"), true);
  assertNoCredentialMaterial(result.json);
});

test("identity: session refresh and sign-out lifecycle", async () => {
  const signIn = await postJson("/v1/identity/dev/sign-in", { role: "viewer" });
  assertJsonResponse(signIn, 200);
  const auth = { authorization: `HighFiveSession ${signIn.json.session.session_id}` };

  const me = await requestJson("/v1/identity/me", { headers: auth });
  assertJsonResponse(me, 200);
  assert.equal(me.json.session.role, "viewer");

  const refreshed = await postJson("/v1/identity/session/refresh", {}, auth);
  assertJsonResponse(refreshed, 200);
  assert.notEqual(refreshed.json.session.session_id, signIn.json.session.session_id);

  const signedOut = await postJson("/v1/identity/sign-out", {}, { authorization: `HighFiveSession ${refreshed.json.session.session_id}` });
  assertJsonResponse(signedOut, 200);
  assert.equal(signedOut.json.status, "signed_out");
  assertNoCredentialMaterial(signedOut.json);
});

test("identity: viewer cannot access creator workspace mutation", async () => {
  const signIn = await postJson("/v1/identity/dev/sign-in", { role: "viewer" });
  assertJsonResponse(signIn, 200);
  const result = await postJson("/v1/creator/workspace", {}, { authorization: `HighFiveSession ${signIn.json.session.session_id}` });
  assertJsonResponse(result, 403);
  assert.equal(result.json.error, "creator_role_required");
});

test("identity: creator can access creator workspace and request deletion review", async () => {
  const signIn = await postJson("/v1/identity/dev/sign-in", { role: "creator" });
  assertJsonResponse(signIn, 200);
  const auth = { authorization: `HighFiveSession ${signIn.json.session.session_id}` };

  const workspace = await postJson("/v1/creator/workspace", {}, auth);
  assertJsonResponse(workspace, 200);
  assert.equal(workspace.json.status, "authorized");

  const deletion = await postJson("/v1/identity/delete-request", {}, auth);
  assertJsonResponse(deletion, 200);
  assert.equal(deletion.json.status, "deletion_requested");

  const audit = await requestJson("/v1/identity/audit");
  assertJsonResponse(audit, 200);
  assert.equal(audit.json.events.some((event) => event.action === "delete_request"), true);
});
