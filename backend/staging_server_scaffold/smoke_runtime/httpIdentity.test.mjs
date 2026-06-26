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

test("identity: Apple exchange creates a redacted viewer session", async () => {
  const result = await postJson("/v1/identity/apple/exchange", {
    role: "viewer",
    identity_credential: "apple-identity-credential-smoke-value",
    authorization_credential: "apple-authorization-credential-smoke-value",
    user_identifier: "apple-user-smoke-123",
    email: "viewer@example.test",
    full_name: "Apple Viewer"
  });
  assertJsonResponse(result, 200);
  assert.equal(result.json.status, "authenticated");
  assert.equal(result.json.session.provider, "apple");
  assert.equal(result.json.session.role, "viewer");
  assert.equal(result.json.session.display_name, "Apple Viewer");
  assert.equal(result.json.credential_storage, "not_stored");
  assertNoCredentialMaterial(result.json);
  assert.doesNotMatch(JSON.stringify(result.json), /apple-identity-credential-smoke-value/);
  assert.doesNotMatch(JSON.stringify(result.json), /apple-authorization-credential-smoke-value/);
});

test("identity: Apple exchange rejects missing credential material", async () => {
  const result = await postJson("/v1/identity/apple/exchange", { role: "viewer" });
  assertJsonResponse(result, 400);
  assert.equal(result.json.error, "apple_identity_credential_required");
  assertNoCredentialMaterial(result.json);
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

test("identity: admin role authorizes creator workspace mutation", async () => {
  const signIn = await postJson("/v1/identity/dev/sign-in", { role: "admin" });
  assertJsonResponse(signIn, 200);
  const auth = { authorization: `HighFiveSession ${signIn.json.session.session_id}` };

  const workspace = await postJson("/v1/creator/workspace", {}, auth);
  assertJsonResponse(workspace, 200);
  assert.equal(workspace.json.status, "authorized");
  assert.equal(workspace.json.role, "admin");
  assertNoCredentialMaterial(workspace.json);
});
