import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

const fixtureBytes = Buffer.from("highfive-lp5-upload-fixture-poster", "utf8");
const checksum = checksumFor(fixtureBytes);
const uploadMatrix = [
  {
    kind: "poster",
    filename: "lp5-poster-fixture.png",
    contentType: "image/png",
    bytes: Buffer.from("highfive-lp5-poster-bytes", "utf8")
  },
  {
    kind: "trailer",
    filename: "lp5-trailer-fixture.mov",
    contentType: "video/quicktime",
    bytes: Buffer.from("highfive-lp5-trailer-bytes", "utf8")
  },
  {
    kind: "source_video",
    filename: "lp5-source-fixture.mp4",
    contentType: "video/mp4",
    bytes: Buffer.from("highfive-lp5-source-video-bytes", "utf8")
  }
];

async function creatorAuth() {
  const signIn = await postJson("/v1/identity/dev/sign-in", { role: "creator" });
  assertJsonResponse(signIn, 200);
  return { authorization: `HighFiveSession ${signIn.json.session.session_id}` };
}

async function createUploadSession(auth, overrides = {}) {
  const bytes = overrides.bytes ?? fixtureBytes;
  return postJson("/v1/creator/uploads/sessions", {
    project_id: "project-behind-the-vision",
    asset_kind: "poster",
    filename: "poster-fixture.txt",
    content_type: "text/plain",
    size_bytes: bytes.byteLength,
    checksum_sha256: checksumFor(bytes),
    ...withoutBytes(overrides)
  }, auth);
}

async function uploadBytes(session, auth, bytes) {
  return requestJson(new URL(session.json.session.upload_url).pathname, {
    method: "PUT",
    headers: {
      "content-type": "application/octet-stream",
      ...auth
    },
    body: bytes
  });
}

function checksumFor(bytes) {
  return createHash("sha256").update(bytes).digest("hex");
}

function withoutBytes(input) {
  const { bytes: _bytes, ...rest } = input;
  return rest;
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

test("uploads: poster, trailer, and source assets store real bytes", async () => {
  const auth = await creatorAuth();
  const uploadedAssetIDs = [];

  for (const fixture of uploadMatrix) {
    const session = await createUploadSession(auth, {
      asset_kind: fixture.kind,
      filename: fixture.filename,
      content_type: fixture.contentType,
      bytes: fixture.bytes
    });
    assertJsonResponse(session, 201);
    assert.equal(session.json.session.asset_kind, fixture.kind);
    assert.equal(session.json.session.filename, fixture.filename);
    assert.equal(session.json.session.content_type, fixture.contentType);

    const uploaded = await uploadBytes(session, auth, fixture.bytes);
    assertJsonResponse(uploaded, 200);
    assert.equal(uploaded.json.status, "uploaded");
    assert.equal(uploaded.json.asset_record.asset_kind, fixture.kind);
    assert.equal(uploaded.json.asset_record.content_type, fixture.contentType);
    assert.equal(uploaded.json.asset_record.size_bytes, fixture.bytes.byteLength);
    assert.equal(uploaded.json.asset_record.checksum_sha256, checksumFor(fixture.bytes));
    assert.equal(uploaded.json.asset_record.upload_state, "uploaded");
    assertNoCredentialMaterial(uploaded.json);
    uploadedAssetIDs.push(uploaded.json.asset_record.id);
  }

  const assets = await requestJson("/v1/creator/uploads/assets", { headers: auth });
  assertJsonResponse(assets, 200);
  for (const assetID of uploadedAssetIDs) {
    assert.equal(assets.json.assets.some((asset) => asset.id === assetID), true);
  }
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

test("uploads: creator can retry after validation failure with a new signed session", async () => {
  const auth = await creatorAuth();
  const retryBytes = Buffer.from("highfive-lp5-retry-after-validation", "utf8");
  const invalid = await createUploadSession(auth, {
    filename: "retry-validation.mov",
    asset_kind: "trailer",
    content_type: "video/quicktime",
    bytes: retryBytes,
    checksum_sha256: "0".repeat(64)
  });
  assertJsonResponse(invalid, 201);
  const rejected = await uploadBytes(invalid, auth, retryBytes);
  assertJsonResponse(rejected, 422);
  assert.equal(rejected.json.error, "upload_checksum_mismatch");

  const retry = await createUploadSession(auth, {
    filename: "retry-validation.mov",
    asset_kind: "trailer",
    content_type: "video/quicktime",
    bytes: retryBytes
  });
  assertJsonResponse(retry, 201);
  const uploaded = await uploadBytes(retry, auth, retryBytes);
  assertJsonResponse(uploaded, 200);
  assert.equal(uploaded.json.asset_record.asset_kind, "trailer");
  assert.equal(uploaded.json.asset_record.checksum_sha256, checksumFor(retryBytes));
});

test("uploads: readiness advertises LP5 asset coverage", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.upload_poster_assets, true);
  assert.equal(ready.json.upload_trailer_assets, true);
  assert.equal(ready.json.upload_source_assets, true);
  assert.equal(ready.json.upload_retry_supported, true);
  assert.equal(ready.json.upload_resume_policy, "new_signed_session_after_validation_failure");
  assert.equal(typeof ready.json.upload_max_size_bytes, "number");
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
