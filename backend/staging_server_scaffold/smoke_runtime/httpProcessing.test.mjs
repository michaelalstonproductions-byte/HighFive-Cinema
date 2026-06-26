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

async function uploadPoster(auth, filename = "poster-invalid-for-hls.png") {
  const bytes = Buffer.from("highfive-lp6-poster-not-video", "utf8");
  const posterChecksum = createHash("sha256").update(bytes).digest("hex");
  const session = await postJson("/v1/creator/uploads/sessions", {
    project_id: "project-behind-the-vision",
    asset_kind: "poster",
    filename,
    content_type: "image/png",
    size_bytes: bytes.byteLength,
    checksum_sha256: posterChecksum
  }, auth);
  assertJsonResponse(session, 201);
  const uploaded = await requestJson(new URL(session.json.session.upload_url).pathname, {
    method: "PUT",
    headers: { "content-type": "application/octet-stream", ...auth },
    body: bytes
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
  assert.equal(result.json.job.output.variants.some((variant) => variant.quality === "720p"), true);
  assert.equal(result.json.job.output.segment_count, 2);
  assert.match(result.json.job.output.generated_poster_object_key, /poster-1080\.jpg$/);
  assert.match(result.json.job.output.trailer_derivative_object_key, /trailer-preview\.m3u8$/);
  assert.match(result.json.job.output.poster_variant_object_key, /thumbnail-manifest\.json$/);
  assert.equal(result.json.job.progress, 100);
  assertNoCredentialMaterial(result.json);
});

test("processing: poster assets fail preflight before HLS output", async () => {
  const auth = await creatorAuth();
  const asset = await uploadPoster(auth);
  const result = await postJson("/v1/creator/processing/jobs", { asset_id: asset.id }, auth);
  assertJsonResponse(result, 201);
  assert.equal(result.json.status, "failed");
  assert.equal(result.json.job.state, "failed");
  assert.equal(result.json.job.inspection.has_video_track, false);
  assert.equal(result.json.job.output, null);
  assert.match(result.json.job.failure_reason, /usable video track/);
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

test("processing: readiness advertises LP6 worker capabilities", async () => {
  const ready = await requestJson("/ready");
  assertJsonResponse(ready, 200);
  assert.equal(ready.json.media_processing_enabled, true);
  assert.equal(ready.json.processing_worker_service, "local_ffmpeg_scaffold");
  assert.equal(ready.json.processing_queue_enabled, true);
  assert.equal(ready.json.processing_hls_variants, "1080p,720p");
  assert.equal(ready.json.processing_poster_generation, true);
  assert.equal(ready.json.processing_thumbnail_generation, true);
  assert.equal(ready.json.processing_trailer_derivative, true);
  assert.equal(ready.json.processing_failure_reasons, true);
  assert.equal(ready.json.processing_timeout_policy, "local_worker_30_seconds");
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
