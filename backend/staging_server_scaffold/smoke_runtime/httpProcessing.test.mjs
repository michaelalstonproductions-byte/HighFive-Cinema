import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import test from "node:test";
import { assertJsonResponse, assertNoCredentialMaterial, postJson, requestJson } from "./testHelpers.mjs";

const sourceBytes = Buffer.from("highfive-p34a-source-video-fixture", "utf8");
const checksum = createHash("sha256").update(sourceBytes).digest("hex");

async function creatorAuth() {
  const signIn = await postJson("/v1/identity/dev/sign-in", { role: "creator" });
  assertJsonResponse(signIn, 200);
  return { authorization: `HighFiveSession ${signIn.json.session.session_id}` };
}

async function uploadSourceVideo(auth, filename = "source-fixture.mp4") {
  const session = await postJson("/v1/creator/uploads/sessions", {
    project_id: "project-behind-the-vision",
    asset_kind: "source_video",
    filename,
    content_type: "video/mp4",
    size_bytes: sourceBytes.byteLength,
    checksum_sha256: checksum
  }, auth);
  assertJsonResponse(session, 201);
  const uploaded = await requestJson(new URL(session.json.session.upload_url).pathname, {
    method: "PUT",
    headers: { "content-type": "application/octet-stream", ...auth },
    body: sourceBytes
  });
  assertJsonResponse(uploaded, 200);
  return uploaded.json.asset_record;
}

test("processing: uploaded source asset creates HLS output records", async () => {
  const auth = await creatorAuth();
  const asset = await uploadSourceVideo(auth);
  const result = await postJson("/v1/creator/processing/jobs", { asset_id: asset.id }, auth);
  assertJsonResponse(result, 201);
  assert.equal(result.json.status, "completed");
  assert.equal(result.json.job.state, "completed");
  assert.equal(result.json.job.asset_id, asset.id);
  assert.equal(result.json.job.inspection.has_video_track, true);
  assert.equal(result.json.job.output.output_state, "playback_ready");
  assert.match(result.json.job.output.hls_master_object_key, /master\.m3u8$/);
  assert.equal(result.json.job.output.variants[0].quality, "1080p");
  assert.equal(result.json.job.progress, 100);
  assertNoCredentialMaterial(result.json);
});

test("processing: repeated request is idempotent", async () => {
  const auth = await creatorAuth();
  const asset = await uploadSourceVideo(auth, "source-idempotent.mp4");
  const first = await postJson("/v1/creator/processing/jobs", { asset_id: asset.id }, auth);
  assertJsonResponse(first, 201);
  const second = await postJson("/v1/creator/processing/jobs", { asset_id: asset.id }, auth);
  assertJsonResponse(second, 201);
  assert.equal(second.json.idempotent, true);
  assert.equal(second.json.job.id, first.json.job.id);
});

test("processing: jobs list and retry are creator scoped", async () => {
  const auth = await creatorAuth();
  const asset = await uploadSourceVideo(auth, "source-list.mp4");
  const created = await postJson("/v1/creator/processing/jobs", { asset_id: asset.id }, auth);
  assertJsonResponse(created, 201);

  const list = await requestJson("/v1/creator/processing/jobs", { headers: auth });
  assertJsonResponse(list, 200);
  assert.equal(list.json.jobs.some((job) => job.id === created.json.job.id), true);

  const retry = await postJson(`/v1/creator/processing/jobs/${created.json.job.id}/retry`, {}, auth);
  assertJsonResponse(retry, 200);
  assert.equal(retry.json.status, "completed");
  assert.equal(retry.json.job.retry_count, 1);
});

test("processing: viewer cannot process creator assets", async () => {
  const creator = await creatorAuth();
  const asset = await uploadSourceVideo(creator, "source-forbidden.mp4");
  const viewerSignIn = await postJson("/v1/identity/dev/sign-in", { role: "viewer" });
  assertJsonResponse(viewerSignIn, 200);
  const result = await postJson("/v1/creator/processing/jobs", { asset_id: asset.id }, {
    authorization: `HighFiveSession ${viewerSignIn.json.session.session_id}`
  });
  assertJsonResponse(result, 403);
  assert.equal(result.json.error, "creator_role_required");
});
