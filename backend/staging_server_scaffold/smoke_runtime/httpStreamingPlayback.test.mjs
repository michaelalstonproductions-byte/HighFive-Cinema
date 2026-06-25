import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import test from "node:test";
import {
  assertIsoDate,
  assertJsonResponse,
  assertNoCredentialMaterial,
  assertShortLived,
  friendlyRequest,
  playbackRequest,
  postJson,
  requestJson
} from "./testHelpers.mjs";

const sourceBytes = Buffer.from("highfive-p35a-streaming-playback-source", "utf8");
const checksum = createHash("sha256").update(sourceBytes).digest("hex");

async function creatorAuth() {
  const signIn = await postJson("/v1/identity/dev/sign-in", { role: "creator" });
  assertJsonResponse(signIn, 200);
  return { authorization: `HighFiveSession ${signIn.json.session.session_id}` };
}

async function createProcessedHLSOutput() {
  const auth = await creatorAuth();
  const session = await postJson("/v1/creator/uploads/sessions", {
    project_id: "project-behind-the-vision",
    asset_kind: "source_video",
    filename: "playback-source.mp4",
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
  const processed = await postJson("/v1/creator/processing/jobs", { asset_id: uploaded.json.asset_record.id }, auth);
  assertJsonResponse(processed, 201);
  assert.equal(processed.json.job.output.output_state, "playback_ready");
  return processed.json.job;
}

async function approvedEntitlement() {
  const result = await postJson("/entitlements/validate", friendlyRequest(), {
    "x-highfive-smoke-entitlement-mode": "approved"
  });
  assertJsonResponse(result, 200);
  assert.equal(result.json.entitlement_status, "entitlement_approved");
  return result.json;
}

test("streaming playback: processed HLS output resolves through playback descriptor", async () => {
  const now = Date.now();
  const job = await createProcessedHLSOutput();
  const entitlement = await approvedEntitlement();
  const descriptor = await postJson("/playback/descriptor", playbackRequest(entitlement.audit_id), {
    "x-highfive-smoke-descriptor-mode": "ready"
  });
  assertJsonResponse(descriptor, 200);
  assert.equal(descriptor.json.playback_descriptor_status, "descriptor_ready");
  assert.equal(descriptor.json.playback_format, "hls");
  assert.equal(descriptor.json.playback_source, "processed_hls");
  assert.equal(descriptor.json.processing_job_id, job.id);
  assert.match(descriptor.json.playback_url_or_token_reference, /\/v1\/playback\/hls\//);
  assertIsoDate(descriptor.json.expires_at);
  assertShortLived(descriptor.json.expires_at, now);
  assertNoCredentialMaterial(descriptor.json);

  const hlsURL = new URL(descriptor.json.playback_url_or_token_reference);
  const manifest = await requestJson(`${hlsURL.pathname}${hlsURL.search}`);
  assert.equal(manifest.status, 200);
  assert.match(manifest.contentType, /application\/vnd\.apple\.mpegurl/);
  assert.match(manifest.text, /#EXTM3U/);
  assert.match(manifest.text, /variant-1080p\.m3u8/);
});

test("streaming playback: HLS manifest rejects tampered signatures", async () => {
  await createProcessedHLSOutput();
  const entitlement = await approvedEntitlement();
  const descriptor = await postJson("/playback/descriptor", playbackRequest(entitlement.audit_id), {
    "x-highfive-smoke-descriptor-mode": "ready"
  });
  assertJsonResponse(descriptor, 200);
  const hlsURL = new URL(descriptor.json.playback_url_or_token_reference);
  hlsURL.searchParams.set("signature", "tampered");
  const result = await requestJson(`${hlsURL.pathname}${hlsURL.search}`);
  assert.equal(result.status, 403);
  assert.match(result.contentType, /application\/json/);
  assert.equal(result.json.error, "playback_signature_invalid_or_expired");
});
