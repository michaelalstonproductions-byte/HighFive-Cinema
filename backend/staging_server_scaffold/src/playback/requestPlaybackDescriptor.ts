import {
  type PlaybackDescriptorRequest,
  type PlaybackDescriptorResponse,
  isPlaybackDescriptorRequest
} from "../contracts.js";
import { createAuditRecord, findAuditRecord } from "../audit.js";
import { ContractError } from "../errors.js";
import { productMatchesMovie } from "../productMapping.js";
import type { PlaybackDescriptorSigner } from "../providers/providerInterfaces.js";
import { recordAnalyticsEvent } from "../routes/analytics.js";
import { processedPlaybackDescriptorForMovie } from "../routes/processing.js";

export async function requestPlaybackDescriptor(
  body: unknown,
  signer: PlaybackDescriptorSigner,
  origin: string
): Promise<PlaybackDescriptorResponse> {
  if (!isPlaybackDescriptorRequest(body)) {
    throw new ContractError("invalid_playback_descriptor_request", "Playback descriptor request shape is invalid");
  }

  const request: PlaybackDescriptorRequest = body;
  if (!request.user_id && !request.anonymous_session_id) {
    throw new ContractError("identity_required", "user_id or anonymous_session_id is required");
  }

  if (!productMatchesMovie(request.movie_id, request.storekit_product_id)) {
    return unavailableResponse(request.audit_id, "product_mapping_mismatch");
  }

  const entitlementAudit = findAuditRecord(request.audit_id);
  if (
    !entitlementAudit ||
    entitlementAudit.event_name !== "entitlement_validation_approved" ||
    entitlementAudit.movie_id !== request.movie_id ||
    entitlementAudit.storekit_product_id !== request.storekit_product_id
  ) {
    return unavailableResponse(request.audit_id, "entitlement_audit_not_approved");
  }

  await createAuditRecord({
    event_name: "playback_descriptor_requested",
    movie_id: request.movie_id,
    storekit_product_id: request.storekit_product_id,
    detail: "Backend playback descriptor requested"
  });

  const signingResult = await signer.createDescriptorReference(request);
  if (!signingResult.playback_url_or_token_reference) {
    await createAuditRecord({
      event_name: "playback_descriptor_unavailable",
      movie_id: request.movie_id,
      storekit_product_id: request.storekit_product_id,
      detail: "Descriptor signer unavailable"
    });
    return unavailableResponse(request.audit_id, "descriptor_signer_unavailable");
  }

  const processedPlayback = processedPlaybackDescriptorForMovie(request.movie_id, origin);
  if (processedPlayback) {
    await createAuditRecord({
      event_name: "playback_descriptor_issued",
      movie_id: request.movie_id,
      storekit_product_id: request.storekit_product_id,
      detail: "Short-lived processed HLS playback descriptor issued"
    });
    recordAnalyticsEvent("playback_start", {
      movie_id: request.movie_id,
      playback_source: "processed_hls",
      playback_format: "hls"
    }, { contentID: request.movie_id, source: "playback_descriptor" });
    return {
      playback_descriptor_status: "descriptor_ready",
      playback_url_or_token_reference: processedPlayback.playback_url_or_token_reference,
      expires_at: processedPlayback.expires_at,
      refresh_after: processedPlayback.refresh_after,
      denial_reason: null,
      audit_id: request.audit_id,
      playback_format: "hls",
      playback_source: "processed_hls",
      processing_job_id: processedPlayback.processing_job_id,
      hls_master_object_key: processedPlayback.hls_master_object_key
    };
  }

  await createAuditRecord({
    event_name: "playback_descriptor_issued",
    movie_id: request.movie_id,
    storekit_product_id: request.storekit_product_id,
    detail: "Short-lived descriptor reference issued"
  });
  recordAnalyticsEvent("playback_start", {
    movie_id: request.movie_id,
    playback_source: "descriptor_reference"
  }, { contentID: request.movie_id, source: "playback_descriptor" });

  return {
    playback_descriptor_status: "descriptor_ready",
    playback_url_or_token_reference: signingResult.playback_url_or_token_reference,
    expires_at: signingResult.expires_at,
    refresh_after: signingResult.refresh_after,
    denial_reason: null,
    audit_id: request.audit_id
  };
}

function unavailableResponse(auditID: string, reason: string): PlaybackDescriptorResponse {
  return {
    playback_descriptor_status: "descriptor_unavailable",
    playback_url_or_token_reference: null,
    expires_at: null,
    refresh_after: null,
    denial_reason: reason,
    audit_id: auditID
  };
}
