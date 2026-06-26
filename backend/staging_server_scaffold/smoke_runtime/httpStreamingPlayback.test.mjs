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
  assert.equal(descriptor.json.resume_policy, "server_progress");
  assert.equal(descriptor.json.player_controls.bitrate_switching, true);
  assert.equal(descriptor.json.player_controls.audio_selection, true);
  assert.equal(descriptor.json.player_controls.captions, true);
  assert.equal(descriptor.json.player_controls.next_episode, true);
  assert.ok(descriptor.json.bitrate_variants.length >= 2);
  assert.equal(descriptor.json.bitrate_variants[0].quality, "1080p");
  assert.equal(descriptor.json.bitrate_variants[1].quality, "720p");
  assert.equal(descriptor.json.audio_tracks[0].language, "en");
  assert.equal(descriptor.json.audio_tracks[0].channels, 2);
  assert.equal(descriptor.json.caption_tracks[0].format, "webvtt");
  assert.equal(descriptor.json.next_episode.autoplay, true);
  assert.equal(descriptor.json.next_episode.episode_number, 2);
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
  assert.match(manifest.text, /variant-720p\.m3u8/);
  assert.match(manifest.text, /TYPE=AUDIO/);
  assert.match(manifest.text, /TYPE=SUBTITLES/);
  assert.match(manifest.text, /captions-en\.vtt/);
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

test("streaming playback: readiness advertises player runtime capabilities", async () => {
  const readiness = await requestJson("/ready");
  assertJsonResponse(readiness, 200);
  assert.equal(readiness.json.streaming_playback_runtime, true);
  assert.equal(readiness.json.signed_playback_urls, true);
  assert.equal(readiness.json.playback_resume_positions, true);
  assert.equal(readiness.json.playback_caption_tracks, true);
  assert.equal(readiness.json.playback_audio_tracks, true);
  assert.equal(readiness.json.playback_bitrate_switching, true);
  assert.equal(readiness.json.playback_series_autoplay, true);
  assert.equal(readiness.json.playback_next_episode, true);
});
