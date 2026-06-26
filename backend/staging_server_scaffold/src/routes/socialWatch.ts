import { catalogSeed, type CatalogMovie } from "../catalog/catalogSeed.js";
import { ContractError } from "../errors.js";
import { recordAnalyticsEvent } from "./analytics.js";
import { requireIdentitySession, type IdentitySession } from "./identity.js";

type FriendRecord = {
  id: string;
  user_id: string;
  friend_user_id: string;
  display_name: string;
  state: "active";
  created_at: string;
};

type SharedLibraryRecord = {
  id: string;
  owner_user_id: string;
  shared_with_user_id: string;
  movie_ids: string[];
  updated_at: string;
};

type PlaybackState = "playing" | "paused";

type WatchPartyRecord = {
  id: string;
  host_user_id: string;
  movie_id: string;
  title: string;
  state: "scheduled" | "active" | "ended";
  playback_position_seconds: number;
  playback_state: PlaybackState;
  invited_user_ids: string[];
  participant_user_ids: string[];
  created_at: string;
  updated_at: string;
};

type WatchInviteRecord = {
  id: string;
  party_id: string;
  from_user_id: string;
  to_user_id: string;
  status: "pending" | "accepted" | "declined";
  created_at: string;
  updated_at: string;
};

type WatchReactionRecord = {
  id: string;
  party_id: string;
  user_id: string;
  emoji: string;
  label: string;
  playback_position_seconds: number;
  created_at: string;
};

type WatchCommentRecord = {
  id: string;
  party_id: string;
  user_id: string;
  message: string;
  playback_position_seconds: number;
  created_at: string;
};

type VoiceRoomRecord = {
  id: string;
  party_id: string;
  state: "open" | "muted" | "closed";
  participant_user_ids: string[];
  active_speaker_user_id: string | null;
  updated_at: string;
};

const friends: FriendRecord[] = [];
const sharedLibraries: SharedLibraryRecord[] = [];
const parties: WatchPartyRecord[] = [];
const invites: WatchInviteRecord[] = [];
const reactions: WatchReactionRecord[] = [];
const comments: WatchCommentRecord[] = [];
const voiceRooms: VoiceRoomRecord[] = [];

let friendCounter = 1;
let sharedLibraryCounter = 1;
let partyCounter = 1;
let inviteCounter = 1;
let reactionCounter = 1;
let commentCounter = 1;
let voiceRoomCounter = 1;

export function socialWatchReadinessSummary() {
  return {
    social_watch_enabled: true,
    watch_parties: true,
    invites: true,
    friends: true,
    shared_libraries: true,
    synchronized_playback: true,
    voice_rooms: true,
    comments: true,
    reactions: true,
    transport: "local_http_contract"
  };
}

export function socialWatchSummary(authorizationHeader: string | undefined) {
  const session = requireSocialSession(authorizationHeader);
  return {
    status: "ready",
    user_id: session.user_id,
    friends: friends.filter((record) => record.user_id === session.user_id),
    shared_libraries: sharedLibraries.filter((record) => record.owner_user_id === session.user_id || record.shared_with_user_id === session.user_id),
    watch_parties: parties.filter((party) => canAccessParty(session, party)),
    invites: invites.filter((invite) => invite.from_user_id === session.user_id || invite.to_user_id === session.user_id),
    reactions: reactions.filter((reaction) => canAccessParty(session, partyForID(reaction.party_id))),
    comments: comments.filter((comment) => canAccessParty(session, partyForID(comment.party_id))),
    voice_rooms: voiceRooms.filter((room) => canAccessParty(session, partyForID(room.party_id))),
    generated_at: nowISO()
  };
}

export function createFriend(authorizationHeader: string | undefined, body: unknown) {
  const session = requireSocialSession(authorizationHeader);
  const friendUserID = stringFromBody(body, "friend_user_id", "invalid_friend_request");
  const displayName = optionalStringFromBody(body, "display_name") ?? friendUserID;
  if (friendUserID === session.user_id) {
    throw new ContractError("invalid_friend_request", "Friend relationship requires a different user", 400);
  }
  const existing = friends.find((record) => record.user_id === session.user_id && record.friend_user_id === friendUserID);
  const record = existing ?? {
    id: `friend-${friendCounter++}`,
    user_id: session.user_id,
    friend_user_id: friendUserID,
    display_name: trimmed(displayName, 80),
    state: "active" as const,
    created_at: nowISO()
  };
  if (!existing) friends.push(record);
  return {
    status: existing ? "ready" : "created",
    friend: record,
    friends: friends.filter((candidate) => candidate.user_id === session.user_id)
  };
}

export function shareLibrary(authorizationHeader: string | undefined, body: unknown) {
  const session = requireSocialSession(authorizationHeader);
  const sharedWithUserID = stringFromBody(body, "shared_with_user_id", "invalid_shared_library_request");
  const requestedMovieIDs = stringArrayFromBody(body, "movie_ids");
  const movieIDs = requestedMovieIDs.length > 0 ? requestedMovieIDs.map((id) => movieForID(id).id) : catalogSeed.movies.slice(0, 2).map((movie) => movie.id);
  const existingIndex = sharedLibraries.findIndex((record) => record.owner_user_id === session.user_id && record.shared_with_user_id === sharedWithUserID);
  const record: SharedLibraryRecord = {
    id: existingIndex >= 0 ? sharedLibraries[existingIndex].id : `shared-library-${sharedLibraryCounter++}`,
    owner_user_id: session.user_id,
    shared_with_user_id: sharedWithUserID,
    movie_ids: [...new Set(movieIDs)],
    updated_at: nowISO()
  };
  if (existingIndex >= 0) {
    sharedLibraries[existingIndex] = record;
  } else {
    sharedLibraries.push(record);
  }
  recordAnalyticsEvent("collection_open", {
    collection_id: "shared-library",
    movie_count: record.movie_ids.length
  }, { authorizationHeader, source: "social_watch_shared_library" });
  return {
    status: "shared",
    shared_library: record
  };
}

export function createWatchParty(authorizationHeader: string | undefined, body: unknown) {
  const session = requireSocialSession(authorizationHeader);
  const movie = movieForID(stringFromBody(body, "movie_id", "invalid_watch_party_request"));
  const invitedUserIDs = stringArrayFromBody(body, "invited_user_ids");
  const now = nowISO();
  const party: WatchPartyRecord = {
    id: `party-${partyCounter++}`,
    host_user_id: session.user_id,
    movie_id: movie.id,
    title: optionalStringFromBody(body, "title") ?? `${movie.title} Watch Party`,
    state: optionalPartyState(body) ?? "active",
    playback_position_seconds: 0,
    playback_state: "paused",
    invited_user_ids: invitedUserIDs,
    participant_user_ids: [...new Set([session.user_id])],
    created_at: now,
    updated_at: now
  };
  parties.push(party);
  for (const userID of invitedUserIDs) {
    invites.push({
      id: `invite-${inviteCounter++}`,
      party_id: party.id,
      from_user_id: session.user_id,
      to_user_id: userID,
      status: "pending",
      created_at: now,
      updated_at: now
    });
  }
  ensureVoiceRoom(party);
  recordAnalyticsEvent("collection_open", {
    collection_id: "watch-party",
    movie_id: movie.id
  }, { authorizationHeader, contentID: movie.id, source: "social_watch_party_create" });
  return {
    status: "created",
    watch_party: party,
    invites: invites.filter((invite) => invite.party_id === party.id),
    voice_room: ensureVoiceRoom(party)
  };
}

export function sendWatchInvite(authorizationHeader: string | undefined, partyID: string, body: unknown) {
  const session = requireSocialSession(authorizationHeader);
  const party = requirePartyAccess(session, partyID);
  if (party.host_user_id !== session.user_id && session.role !== "admin") {
    throw new ContractError("watch_party_host_required", "Only the host can invite viewers to this party", 403);
  }
  const toUserID = stringFromBody(body, "to_user_id", "invalid_watch_invite_request");
  const now = nowISO();
  const invite: WatchInviteRecord = {
    id: `invite-${inviteCounter++}`,
    party_id: party.id,
    from_user_id: session.user_id,
    to_user_id: toUserID,
    status: "pending",
    created_at: now,
    updated_at: now
  };
  invites.push(invite);
  party.invited_user_ids = [...new Set([...party.invited_user_ids, toUserID])];
  party.updated_at = now;
  return {
    status: "invited",
    invite,
    watch_party: party
  };
}

export function respondWatchInvite(authorizationHeader: string | undefined, inviteID: string, body: unknown) {
  const session = requireSocialSession(authorizationHeader);
  const invite = inviteForID(inviteID);
  if (invite.to_user_id !== session.user_id && session.role !== "admin") {
    throw new ContractError("watch_invite_recipient_required", "Only the invite recipient can update this invite", 403);
  }
  const status = inviteStatusFromBody(body) ?? "accepted";
  invite.status = status;
  invite.updated_at = nowISO();
  const party = partyForID(invite.party_id);
  if (status === "accepted") {
    party.participant_user_ids = [...new Set([...party.participant_user_ids, invite.to_user_id])];
    party.updated_at = invite.updated_at;
    const voiceRoom = ensureVoiceRoom(party);
    voiceRoom.participant_user_ids = [...new Set([...voiceRoom.participant_user_ids, invite.to_user_id])];
    voiceRoom.updated_at = invite.updated_at;
  }
  return {
    status: "updated",
    invite,
    watch_party: party,
    voice_room: ensureVoiceRoom(party)
  };
}

export function syncWatchPlayback(authorizationHeader: string | undefined, partyID: string, body: unknown) {
  const session = requireSocialSession(authorizationHeader);
  const party = requirePartyAccess(session, partyID);
  const position = clampedSeconds(numberFromBody(body, "playback_position_seconds") ?? 0);
  const playbackState = playbackStateFromBody(body) ?? "paused";
  party.playback_position_seconds = position;
  party.playback_state = playbackState;
  party.updated_at = nowISO();
  recordAnalyticsEvent(playbackState === "playing" ? "playback_start" : "playback_pause", {
    movie_id: party.movie_id,
    party_id: party.id,
    playback_position_seconds: position
  }, { authorizationHeader, contentID: party.movie_id, source: "social_watch_playback_sync" });
  return {
    status: "synced",
    watch_party: party
  };
}

export function addWatchReaction(authorizationHeader: string | undefined, partyID: string, body: unknown) {
  const session = requireSocialSession(authorizationHeader);
  requirePartyAccess(session, partyID);
  const label = optionalStringFromBody(body, "label") ?? "Applause";
  const reaction: WatchReactionRecord = {
    id: `reaction-${reactionCounter++}`,
    party_id: partyID,
    user_id: session.user_id,
    emoji: optionalStringFromBody(body, "emoji") ?? "applause",
    label: trimmed(label, 40),
    playback_position_seconds: clampedSeconds(numberFromBody(body, "playback_position_seconds") ?? 0),
    created_at: nowISO()
  };
  reactions.push(reaction);
  return {
    status: "recorded",
    reaction,
    recent_reactions: reactions.filter((candidate) => candidate.party_id === partyID).slice(-12)
  };
}

export function addWatchComment(authorizationHeader: string | undefined, partyID: string, body: unknown) {
  const session = requireSocialSession(authorizationHeader);
  requirePartyAccess(session, partyID);
  const message = trimmed(stringFromBody(body, "message", "invalid_watch_comment_request"), 240);
  const comment: WatchCommentRecord = {
    id: `comment-${commentCounter++}`,
    party_id: partyID,
    user_id: session.user_id,
    message,
    playback_position_seconds: clampedSeconds(numberFromBody(body, "playback_position_seconds") ?? 0),
    created_at: nowISO()
  };
  comments.push(comment);
  return {
    status: "recorded",
    comment,
    recent_comments: comments.filter((candidate) => candidate.party_id === partyID).slice(-20)
  };
}

export function updateVoiceRoom(authorizationHeader: string | undefined, partyID: string, body: unknown) {
  const session = requireSocialSession(authorizationHeader);
  const party = requirePartyAccess(session, partyID);
  const voiceRoom = ensureVoiceRoom(party);
  voiceRoom.state = voiceRoomStateFromBody(body) ?? "open";
  voiceRoom.active_speaker_user_id = optionalStringFromBody(body, "active_speaker_user_id") ?? session.user_id;
  voiceRoom.participant_user_ids = [...new Set([...voiceRoom.participant_user_ids, ...party.participant_user_ids, session.user_id])];
  voiceRoom.updated_at = nowISO();
  return {
    status: "updated",
    voice_room: voiceRoom
  };
}

function requireSocialSession(authorizationHeader: string | undefined): IdentitySession {
  return requireIdentitySession(authorizationHeader);
}

function requirePartyAccess(session: IdentitySession, partyID: string): WatchPartyRecord {
  const party = partyForID(partyID);
  if (!canAccessParty(session, party)) {
    throw new ContractError("watch_party_access_denied", "This session cannot access the requested watch party", 403);
  }
  return party;
}

function canAccessParty(session: IdentitySession, party: WatchPartyRecord): boolean {
  return session.role === "admin" ||
    party.host_user_id === session.user_id ||
    party.participant_user_ids.includes(session.user_id) ||
    party.invited_user_ids.includes(session.user_id);
}

function partyForID(partyID: string): WatchPartyRecord {
  const party = parties.find((candidate) => candidate.id === partyID);
  if (!party) {
    throw new ContractError("watch_party_not_found", "Watch party was not found", 404);
  }
  return party;
}

function inviteForID(inviteID: string): WatchInviteRecord {
  const invite = invites.find((candidate) => candidate.id === inviteID);
  if (!invite) {
    throw new ContractError("watch_invite_not_found", "Watch invite was not found", 404);
  }
  return invite;
}

function ensureVoiceRoom(party: WatchPartyRecord): VoiceRoomRecord {
  const existing = voiceRooms.find((room) => room.party_id === party.id);
  if (existing) return existing;
  const room: VoiceRoomRecord = {
    id: `voice-room-${voiceRoomCounter++}`,
    party_id: party.id,
    state: "open",
    participant_user_ids: [...party.participant_user_ids],
    active_speaker_user_id: party.participant_user_ids[0] ?? null,
    updated_at: nowISO()
  };
  voiceRooms.push(room);
  return room;
}

function movieForID(movieID: string): CatalogMovie {
  const movie = catalogSeed.movies.find((candidate) => candidate.id === movieID);
  if (!movie) {
    throw new ContractError("content_not_found", `Movie ${movieID} was not found`, 404);
  }
  return movie;
}

function stringFromBody(body: unknown, key: string, code: string): string {
  if (!isRecord(body) || typeof body[key] !== "string" || body[key].trim().length === 0) {
    throw new ContractError(code, `${key} is required`, 400);
  }
  return body[key].trim();
}

function optionalStringFromBody(body: unknown, key: string): string | null {
  if (!isRecord(body) || typeof body[key] !== "string" || body[key].trim().length === 0) return null;
  return body[key].trim();
}

function stringArrayFromBody(body: unknown, key: string): string[] {
  if (!isRecord(body) || !Array.isArray(body[key])) return [];
  return body[key]
    .filter((value): value is string => typeof value === "string" && value.trim().length > 0)
    .map((value) => value.trim());
}

function numberFromBody(body: unknown, key: string): number | null {
  if (!isRecord(body) || typeof body[key] !== "number" || !Number.isFinite(body[key])) return null;
  return body[key];
}

function optionalPartyState(body: unknown): WatchPartyRecord["state"] | null {
  const state = optionalStringFromBody(body, "state");
  return state === "scheduled" || state === "active" || state === "ended" ? state : null;
}

function playbackStateFromBody(body: unknown): PlaybackState | null {
  const state = optionalStringFromBody(body, "playback_state");
  return state === "playing" || state === "paused" ? state : null;
}

function inviteStatusFromBody(body: unknown): WatchInviteRecord["status"] | null {
  const status = optionalStringFromBody(body, "status");
  return status === "accepted" || status === "declined" || status === "pending" ? status : null;
}

function voiceRoomStateFromBody(body: unknown): VoiceRoomRecord["state"] | null {
  const state = optionalStringFromBody(body, "state");
  return state === "open" || state === "muted" || state === "closed" ? state : null;
}

function clampedSeconds(value: number): number {
  return Math.max(0, Math.min(Math.round(value), 24 * 60 * 60));
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
