import { requestPlaybackDescriptor } from "../playback/requestPlaybackDescriptor.js";
import type { PlaybackDescriptorSigner } from "../providers/providerInterfaces.js";

export function createPlaybackRoute(signer: PlaybackDescriptorSigner) {
  return async (body: unknown) => requestPlaybackDescriptor(body, signer);
}
