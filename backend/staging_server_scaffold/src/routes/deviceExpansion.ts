import { catalogSeed } from "../catalog/catalogSeed.js";
import type { JsonObject } from "../contracts.js";
import { ContractError } from "../errors.js";
import { recordAnalyticsEvent } from "./analytics.js";
import { requireIdentitySession, type IdentitySession } from "./identity.js";

type DevicePlatform = "iphone" | "ipad" | "apple_tv" | "mac" | "carplay";
type InputMode = "touch" | "remote" | "keyboard_pointer" | "voice_safe";
type LayoutMode = "compact_phone" | "expanded_tablet" | "ten_foot_tv" | "desktop_resizable" | "driving_safe_audio";

type DeviceProfileRecord = {
  id: DevicePlatform;
  display_name: string;
  supported: boolean;
  layout_mode: LayoutMode;
  input_mode: InputMode;
  playback_surface: string;
  navigation_density: "compact" | "standard" | "expanded";
  poster_columns: number;
  airplay_supported: boolean;
  offline_supported: boolean;
  captions_supported: boolean;
  audio_route_supported: boolean;
  handoff_supported: boolean;
  restrictions: string[];
};

type AirPlaySessionRecord = {
  id: string;
  user_id: string;
  movie_id: string;
  source_platform: DevicePlatform;
  target_name: string;
  state: "planned" | "ready" | "ended";
  playback_position_seconds: number;
  created_at: string;
  updated_at: string;
};

type DeviceHandoffRecord = {
  id: string;
  user_id: string;
  movie_id: string;
  from_platform: DevicePlatform;
  to_platform: DevicePlatform;
  context: "continue_watching" | "library" | "premiere" | "creator";
  playback_position_seconds: number;
  created_at: string;
};

const profiles: DeviceProfileRecord[] = [
  {
    id: "iphone",
    display_name: "iPhone",
    supported: true,
    layout_mode: "compact_phone",
    input_mode: "touch",
    playback_surface: "premium_player_compact",
    navigation_density: "compact",
    poster_columns: 2,
    airplay_supported: true,
    offline_supported: true,
    captions_supported: true,
    audio_route_supported: true,
    handoff_supported: true,
    restrictions: []
  },
  {
    id: "ipad",
    display_name: "iPad",
    supported: true,
    layout_mode: "expanded_tablet",
    input_mode: "touch",
    playback_surface: "premium_player_split_context",
    navigation_density: "expanded",
    poster_columns: 4,
    airplay_supported: true,
    offline_supported: true,
    captions_supported: true,
    audio_route_supported: true,
    handoff_supported: true,
    restrictions: []
  },
  {
    id: "apple_tv",
    display_name: "Apple TV",
    supported: true,
    layout_mode: "ten_foot_tv",
    input_mode: "remote",
    playback_surface: "premium_player_ten_foot",
    navigation_density: "standard",
    poster_columns: 5,
    airplay_supported: true,
    offline_supported: false,
    captions_supported: true,
    audio_route_supported: true,
    handoff_supported: true,
    restrictions: ["requires_tv_target_before_store_release"]
  },
  {
    id: "mac",
    display_name: "Mac",
    supported: true,
    layout_mode: "desktop_resizable",
    input_mode: "keyboard_pointer",
    playback_surface: "premium_player_windowed",
    navigation_density: "expanded",
    poster_columns: 6,
    airplay_supported: true,
    offline_supported: true,
    captions_supported: true,
    audio_route_supported: true,
    handoff_supported: true,
    restrictions: ["requires_mac_distribution_review"]
  },
  {
    id: "carplay",
    display_name: "CarPlay Consideration",
    supported: false,
    layout_mode: "driving_safe_audio",
    input_mode: "voice_safe",
    playback_surface: "audio_only_consideration",
    navigation_density: "compact",
    poster_columns: 0,
    airplay_supported: false,
    offline_supported: false,
    captions_supported: false,
    audio_route_supported: true,
    handoff_supported: false,
    restrictions: ["video_browsing_not_supported", "driving_safe_audio_only_consideration"]
  }
];

const airPlaySessions: AirPlaySessionRecord[] = [];
const handoffRecords: DeviceHandoffRecord[] = [];

let airPlayCounter = 1;
let handoffCounter = 1;

export function deviceExpansionReadinessSummary(): JsonObject {
  return {
    device_expansion_enabled: true,
    apple_tv_profile: Boolean(profileFor("apple_tv")),
    ipad_profile: Boolean(profileFor("ipad")),
    mac_profile: Boolean(profileFor("mac")),
    carplay_consideration: Boolean(profileFor("carplay")),
    airplay_session_planning: true,
    handoff_records: true,
    external_device_services: false,
    profile_count: profiles.length,
    airplay_sessions: airPlaySessions.length,
    handoffs: handoffRecords.length
  };
}

export function deviceExpansionSummary(authorizationHeader: string | undefined): JsonObject {
  const session = requireDeviceSession(authorizationHeader);
  return {
    status: "ready",
    user_id: session.user_id,
    profiles,
    supported_profiles: profiles.filter((profile) => profile.supported),
    constrained_profiles: profiles.filter((profile) => profile.restrictions.length > 0),
    airplay_sessions: airPlaySessions.filter((record) => record.user_id === session.user_id),
    handoffs: handoffRecords.filter((record) => record.user_id === session.user_id),
    generated_at: nowISO()
  };
}

export function deviceProfiles(authorizationHeader: string | undefined): JsonObject {
  requireDeviceSession(authorizationHeader);
  return {
    status: "ready",
    profiles
  };
}

export function deviceProfileDetail(authorizationHeader: string | undefined, platformID: string): JsonObject {
  requireDeviceSession(authorizationHeader);
  const profile = profileForPlatform(platformID);
  return {
    status: "ready",
    profile,
    recommendations: layoutRecommendations(profile)
  };
}

export function createAirPlaySession(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireDeviceSession(authorizationHeader);
  const movieID = optionalStringFromBody(body, "movie_id") ?? catalogSeed.movies[0]?.id ?? "friendly";
  movieForID(movieID);
  const sourcePlatform = platformFromBody(body, "source_platform") ?? "iphone";
  const sourceProfile = profileFor(sourcePlatform);
  if (!sourceProfile.airplay_supported) {
    throw new ContractError("airplay_not_supported", `${sourceProfile.display_name} does not support AirPlay session planning`, 400);
  }
  const now = nowISO();
  const record: AirPlaySessionRecord = {
    id: `airplay-session-${airPlayCounter++}`,
    user_id: session.user_id,
    movie_id: movieID,
    source_platform: sourcePlatform,
    target_name: trimmed(optionalStringFromBody(body, "target_name") ?? "Living Room Screen", 120),
    state: "ready",
    playback_position_seconds: clampedSeconds(numberFromBody(body, "playback_position_seconds") ?? 0),
    created_at: now,
    updated_at: now
  };
  airPlaySessions.push(record);
  recordAnalyticsEvent("playback_start", {
    movie_id: movieID,
    source_platform: sourcePlatform,
    target_name: record.target_name,
    device_expansion: "airplay"
  }, {
    authorizationHeader,
    identitySession: session,
    contentID: movieID,
    source: "device_expansion_airplay"
  });
  return {
    status: "ready",
    airplay_session: record
  };
}

export function createDeviceHandoff(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireDeviceSession(authorizationHeader);
  const movieID = optionalStringFromBody(body, "movie_id") ?? catalogSeed.movies[0]?.id ?? "friendly";
  movieForID(movieID);
  const fromPlatform = platformFromBody(body, "from_platform") ?? "iphone";
  const toPlatform = platformFromBody(body, "to_platform") ?? "ipad";
  const fromProfile = profileFor(fromPlatform);
  const toProfile = profileFor(toPlatform);
  if (!fromProfile.handoff_supported || !toProfile.handoff_supported) {
    throw new ContractError("handoff_not_supported", "Requested device profile does not support handoff", 400);
  }
  const record: DeviceHandoffRecord = {
    id: `device-handoff-${handoffCounter++}`,
    user_id: session.user_id,
    movie_id: movieID,
    from_platform: fromPlatform,
    to_platform: toPlatform,
    context: handoffContextFromBody(body) ?? "continue_watching",
    playback_position_seconds: clampedSeconds(numberFromBody(body, "playback_position_seconds") ?? 0),
    created_at: nowISO()
  };
  handoffRecords.push(record);
  return {
    status: "recorded",
    handoff: record,
    source_profile: fromProfile,
    target_profile: toProfile
  };
}

function requireDeviceSession(authorizationHeader: string | undefined): IdentitySession {
  return requireIdentitySession(authorizationHeader);
}

function profileForPlatform(platformID: string): DeviceProfileRecord {
  const profile = profiles.find((record) => record.id === platformID);
  if (!profile) {
    throw new ContractError("device_profile_not_found", "Device profile was not found", 404);
  }
  return profile;
}

function profileFor(platform: DevicePlatform): DeviceProfileRecord {
  return profileForPlatform(platform);
}

function layoutRecommendations(profile: DeviceProfileRecord): JsonObject {
  return {
    layout_mode: profile.layout_mode,
    input_mode: profile.input_mode,
    poster_columns: profile.poster_columns,
    playback_surface: profile.playback_surface,
    navigation_density: profile.navigation_density,
    use_safe_title_area: profile.id === "apple_tv",
    prefer_split_detail: profile.id === "ipad" || profile.id === "mac",
    avoid_video_browsing: profile.id === "carplay"
  };
}

function movieForID(movieID: string): void {
  const movie = catalogSeed.movies.find((candidate) => candidate.id === movieID);
  if (!movie) {
    throw new ContractError("content_not_found", `Movie ${movieID} was not found`, 404);
  }
}

function platformFromBody(body: unknown, key: string): DevicePlatform | null {
  const value = optionalStringFromBody(body, key);
  const allowed: DevicePlatform[] = ["iphone", "ipad", "apple_tv", "mac", "carplay"];
  return allowed.includes(value as DevicePlatform) ? value as DevicePlatform : null;
}

function handoffContextFromBody(body: unknown): DeviceHandoffRecord["context"] | null {
  const value = optionalStringFromBody(body, "context");
  const allowed: DeviceHandoffRecord["context"][] = ["continue_watching", "library", "premiere", "creator"];
  return allowed.includes(value as DeviceHandoffRecord["context"]) ? value as DeviceHandoffRecord["context"] : null;
}

function optionalStringFromBody(body: unknown, key: string): string | null {
  if (!isRecord(body) || typeof body[key] !== "string" || body[key].trim().length === 0) return null;
  return body[key].trim();
}

function numberFromBody(body: unknown, key: string): number | null {
  if (!isRecord(body) || typeof body[key] !== "number" || !Number.isFinite(body[key])) return null;
  return body[key];
}

function clampedSeconds(value: number): number {
  return Math.max(0, Math.min(Math.round(value), 7 * 24 * 60 * 60));
}

function trimmed(value: string, limit: number): string {
  return value.trim().slice(0, limit);
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function nowISO(): string {
  return new Date().toISOString();
}
