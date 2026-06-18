import type {
  EntitlementValidationRequest,
  EntitlementStatus,
  PlaybackDescriptorRequest
} from "../contracts.js";

export type EntitlementProviderResult = {
  status: EntitlementStatus;
  denial_reason: string | null;
};

export interface EntitlementProvider {
  validate(request: EntitlementValidationRequest): Promise<EntitlementProviderResult>;
}

export type DescriptorSigningResult = {
  playback_url_or_token_reference: string | null;
  expires_at: string | null;
  refresh_after: string | null;
};

export interface PlaybackDescriptorSigner {
  createDescriptorReference(request: PlaybackDescriptorRequest): Promise<DescriptorSigningResult>;
}
