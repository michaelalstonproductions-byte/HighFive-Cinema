import type { PlaybackDescriptorRequest } from "../contracts.js";
import type { DescriptorSigningResult, PlaybackDescriptorSigner } from "./providerInterfaces.js";

export class CloudflareSignerPlaceholder implements PlaybackDescriptorSigner {
  async createDescriptorReference(_request: PlaybackDescriptorRequest): Promise<DescriptorSigningResult> {
    return {
      playback_url_or_token_reference: null,
      expires_at: null,
      refresh_after: null
    };
  }
}
