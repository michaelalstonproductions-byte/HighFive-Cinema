import type { PlaybackDescriptorRequest } from "../contracts.js";
import type { DescriptorSigningResult, PlaybackDescriptorSigner } from "../providers/providerInterfaces.js";

export class MockCloudflareSigner implements PlaybackDescriptorSigner {
  constructor(private readonly mode: "ready" | "unavailable" = "unavailable") {}

  async createDescriptorReference(request: PlaybackDescriptorRequest): Promise<DescriptorSigningResult> {
    if (this.mode !== "ready") {
      return {
        playback_url_or_token_reference: null,
        expires_at: null,
        refresh_after: null
      };
    }

    return {
      playback_url_or_token_reference: `<MOCK_DESCRIPTOR_REFERENCE:${request.movie_id}>`,
      expires_at: new Date(Date.now() + 10 * 60 * 1000).toISOString(),
      refresh_after: new Date(Date.now() + 8 * 60 * 1000).toISOString()
    };
  }
}
