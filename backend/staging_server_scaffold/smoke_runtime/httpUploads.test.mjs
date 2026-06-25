import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

const fixtureBytes = Buffer.from("highfive-p33a-upload-fixture-poster", "utf8");
const checksum = createHash("sha256").update(fixtureBytes).digest("hex");

async function creatorAuth() {
  const signIn = await postJson("/v1/identity/dev/sign-in", { role: "creator" });
  assertJsonResponse(signIn, 200);
  return { authorization: `HighFiveSession ${signIn.json.session.session_id}` };
}

async function createUploadSession(auth, overrides = {}) {
  return postJson("/v1/creator/uploads/sessions", {
    project_id: "project-behind-the-vision",
    asset_kind: "poster",
    filename: "poster-fixture.txt",
    content_type: "text/plain",
    size_bytes: fixtureBytes.byteLength,
    checksum_sha256: checksum,
    ...overrides
  }, auth);
}

test("uploads: creator can create a signed session and upload verified bytes", async () => {
  const auth = await creatorAuth();
  const session = await createUploadSession(auth);
  assertJsonResponse(session, 201);
  assert.equal(session.json.status, "session_ready");
  assert.match(session.json.session.upload_url, /\/v1\/creator\/uploads\/.+\/blob$/);
  assertNoCredentialMaterial(session.json);

  const uploaded = await requestJson(new URL(session.json.session.upload_url).pathname, {
    method: "PUT",
    headers: {
      "content-type": "application/octet-stream",
      ...auth
    },
    body: fixtureBytes
  });
  assertJsonResponse(uploaded, 200);
  assert.equal(uploaded.json.status, "uploaded");
  assert.equal(uploaded.json.asset_record.size_bytes, fixtureBytes.byteLength);
  assert.equal(uploaded.json.asset_record.checksum_sha256, checksum);
  assert.equal(uploaded.json.asset_record.storage_provider, "local_object_store");
  assertNoCredentialMaterial(uploaded.json);

  const assets = await requestJson("/v1/creator/uploads/assets", { headers: auth });
  assertJsonResponse(assets, 200);
  assert.equal(assets.json.assets.some((asset) => asset.checksum_sha256 === checksum), true);
  assertNoCredentialMaterial(assets.json);
});

test("uploads: duplicate checksum is deterministic", async () => {
  const auth = await creatorAuth();
  const first = await createUploadSession(auth, { filename: "first-duplicate.txt" });
  assertJsonResponse(first, 201);
  const firstUpload = await requestJson(new URL(first.json.session.upload_url).pathname, {
    method: "PUT",
    headers: { "content-type": "application/octet-stream", ...auth },
    body: fixtureBytes
  });
  assertJsonResponse(firstUpload, 200);

  const second = await createUploadSession(auth, { filename: "second-duplicate.txt" });
  assertJsonResponse(second, 201);
  const secondUpload = await requestJson(new URL(second.json.session.upload_url).pathname, {
    method: "PUT",
    headers: { "content-type": "application/octet-stream", ...auth },
    body: fixtureBytes
  });
  assertJsonResponse(secondUpload, 200);
  assert.equal(secondUpload.json.duplicate_detected, true);
  assert.equal(typeof secondUpload.json.asset_record.duplicate_of, "string");
});

test("uploads: checksum mismatch is rejected", async () => {
  const auth = await creatorAuth();
  const session = await createUploadSession(auth, { checksum_sha256: "0".repeat(64) });
  assertJsonResponse(session, 201);
  const result = await requestJson(new URL(session.json.session.upload_url).pathname, {
    method: "PUT",
    headers: { "content-type": "application/octet-stream", ...auth },
    body: fixtureBytes
  });
  assertJsonResponse(result, 422);
  assert.equal(result.json.error, "upload_checksum_mismatch");
});

test("uploads: viewer cannot create upload sessions", async () => {
  const signIn = await postJson("/v1/identity/dev/sign-in", { role: "viewer" });
  assertJsonResponse(signIn, 200);
  const result = await createUploadSession({ authorization: `HighFiveSession ${signIn.json.session.session_id}` });
  assertJsonResponse(result, 403);
  assert.equal(result.json.error, "creator_role_required");
});

test("uploads: cancelled sessions reject later bytes", async () => {
  const auth = await creatorAuth();
  const session = await createUploadSession(auth, { filename: "cancelled-poster.txt" });
  assertJsonResponse(session, 201);
  const uploadPath = new URL(session.json.session.upload_url).pathname;
  const cancel = await postJson(uploadPath.replace(/\/blob$/, "/cancel"), {}, auth);
  assertJsonResponse(cancel, 200);
  assert.equal(cancel.json.status, "cancelled");

  const result = await requestJson(uploadPath, {
    method: "PUT",
    headers: { "content-type": "application/octet-stream", ...auth },
    body: fixtureBytes
  });
  assertJsonResponse(result, 409);
  assert.equal(result.json.error, "upload_session_cancelled");
});
