import { catalogSeed, type CatalogMovie } from "../catalog/catalogSeed.js";
import type { JsonObject } from "../contracts.js";
import { ContractError } from "../errors.js";
import { recordAnalyticsEvent } from "./analytics.js";
import { requireIdentitySession, type IdentitySession } from "./identity.js";
import { recordProductNotification } from "./notifications.js";

type LivePremiereState = "scheduled" | "countdown" | "premiere" | "afterparty" | "replay";
type PremiereRoomState = "lobby" | "open" | "qa" | "replay";

type LivePremiereEventRecord = {
  id: string;
  movie_id: string;
  title: string;
  creator_id: string;
  host_user_id: string;
  state: LivePremiereState;
  starts_at: string;
  countdown_seconds: number;
  room_id: string;
  created_at: string;
  updated_at: string;
};

type LivePremiereRoomRecord = {
  id: string;
  event_id: string;
  state: PremiereRoomState;
  participant_user_ids: string[];
  max_capacity: number;
  updated_at: string;
};

type LivePremiereIntroRecord = {
  id: string;
  event_id: string;
  creator_id: string;
  title: string;
  message: string;
  duration_seconds: number;
  created_at: string;
};

type LivePremiereChatRecord = {
  id: string;
  event_id: string;
  user_id: string;
  message: string;
  playback_position_seconds: number;
  created_at: string;
};

type LivePremiereQuestionRecord = {
  id: string;
  event_id: string;
  user_id: string;
  question: string;
  status: "open" | "answered";
  answer: string | null;
  answered_by_user_id: string | null;
  created_at: string;
  answered_at: string | null;
};

type LivePremiereReplayRecord = {
  id: string;
  event_id: string;
  title: string;
  available: boolean;
  replay_position_seconds: number;
  published_at: string;
};

const events: LivePremiereEventRecord[] = [];
const rooms: LivePremiereRoomRecord[] = [];
const intros: LivePremiereIntroRecord[] = [];
const chatMessages: LivePremiereChatRecord[] = [];
const questions: LivePremiereQuestionRecord[] = [];
const replays: LivePremiereReplayRecord[] = [];

let eventCounter = 1;
let roomCounter = 1;
let introCounter = 1;
let chatCounter = 1;
let questionCounter = 1;
let replayCounter = 1;

seedLivePremieres();

export function livePremiereReadinessSummary(): JsonObject {
  return {
    live_premieres_enabled: true,
    countdowns: true,
    premiere_rooms: true,
    creator_introductions: true,
    qa: true,
    chat: true,
    replay: true,
    synchronized_transport: "local_http_contract",
    external_services: false,
    events: events.length,
    rooms: rooms.length
  };
}

export function livePremiereSummary(authorizationHeader: string | undefined): JsonObject {
  const session = requireLivePremiereSession(authorizationHeader);
  const visibleEvents = events.filter((event) => canAccessEvent(session, event));
  return {
    status: "ready",
    user_id: session.user_id,
    events: visibleEvents,
    rooms: rooms.filter((room) => visibleEvents.some((event) => event.id === room.event_id)),
    introductions: intros.filter((intro) => visibleEvents.some((event) => event.id === intro.event_id)).slice(-20),
    chat_messages: chatMessages.filter((message) => visibleEvents.some((event) => event.id === message.event_id)).slice(-40),
    qa: questions.filter((question) => visibleEvents.some((event) => event.id === question.event_id)).slice(-40),
    replays: replays.filter((replay) => visibleEvents.some((event) => event.id === replay.event_id)).slice(-20),
    generated_at: nowISO()
  };
}

export function createLivePremiereEvent(authorizationHeader: string | undefined, body: unknown): JsonObject {
  const session = requireCreatorOrAdmin(authorizationHeader);
  const movie = movieForID(optionalStringFromBody(body, "movie_id") ?? catalogSeed.movies[0]?.id ?? "friendly");
  const now = nowISO();
  const roomID = `live-premiere-room-${roomCounter++}`;
  const startsAt = optionalStringFromBody(body, "starts_at") ?? minutesFromNowISO(30);
  const countdown = clampedSeconds(numberFromBody(body, "countdown_seconds") ?? secondsUntil(startsAt));
  const event: LivePremiereEventRecord = {
    id: `live-premiere-${eventCounter++}`,
    movie_id: movie.id,
    title: trimmed(optionalStringFromBody(body, "title") ?? `${movie.title} Premiere`, 120),
    creator_id: session.creator_id ?? catalogSeed.creators[0]?.id ?? "maya-hart",
    host_user_id: session.user_id,
    state: "scheduled",
    starts_at: startsAt,
    countdown_seconds: countdown,
    room_id: roomID,
    created_at: now,
    updated_at: now
  };
  const room: LivePremiereRoomRecord = {
    id: roomID,
    event_id: event.id,
    state: "lobby",
    participant_user_ids: [session.user_id],
    max_capacity: clampedCapacity(numberFromBody(body, "max_capacity") ?? 500),
    updated_at: now
  };
  events.push(event);
  rooms.push(room);
  recordAnalyticsEvent("collection_open", {
    collection_id: "live-premiere",
    movie_id: movie.id,
    live_premiere_id: event.id
  }, {
    authorizationHeader,
    identitySession: session,
    contentID: movie.id,
    creatorID: event.creator_id,
    collectionID: "live-premiere",
    source: "live_premiere_create"
  });
  return {
    status: "created",
    event,
    room
  };
}

export function updateLivePremiereRoom(authorizationHeader: string | undefined, eventID: string, body: unknown): JsonObject {
  const session = requireLivePremiereSession(authorizationHeader);
  const event = requireEventAccess(session, eventID);
  const room = roomForEvent(event.id);
  if (isEventHost(session, event)) {
    room.state = roomStateFromBody(body) ?? room.state;
  }
  room.participant_user_ids = [...new Set([...room.participant_user_ids, session.user_id, ...stringArrayFromBody(body, "participant_user_ids")])];
  room.updated_at = nowISO();
  event.state = eventStateForRoom(room.state, event.state);
  event.updated_at = room.updated_at;
  return {
    status: "updated",
    event,
    room
  };
}

export function updateLivePremiereCountdown(authorizationHeader: string | undefined, eventID: string, body: unknown): JsonObject {
  const session = requireCreatorHostOrAdmin(authorizationHeader, eventID);
  const event = eventForID(eventID);
  event.countdown_seconds = clampedSeconds(numberFromBody(body, "countdown_seconds") ?? event.countdown_seconds);
  event.starts_at = optionalStringFromBody(body, "starts_at") ?? event.starts_at;
  event.state = event.countdown_seconds > 0 ? "countdown" : "premiere";
  event.updated_at = nowISO();
  return {
    status: "updated",
    event
  };
}

export function postLivePremiereChat(authorizationHeader: string | undefined, eventID: string, body: unknown): JsonObject {
  const session = requireLivePremiereSession(authorizationHeader);
  const event = requireEventAccess(session, eventID);
  const room = roomForEvent(event.id);
  room.participant_user_ids = [...new Set([...room.participant_user_ids, session.user_id])];
  room.updated_at = nowISO();
  const message: LivePremiereChatRecord = {
    id: `live-premiere-chat-${chatCounter++}`,
    event_id: event.id,
    user_id: session.user_id,
    message: trimmed(stringFromBody(body, "message", "invalid_live_premiere_chat"), 240),
    playback_position_seconds: clampedSeconds(numberFromBody(body, "playback_position_seconds") ?? 0),
    created_at: room.updated_at
  };
  chatMessages.push(message);
  return {
    status: "recorded",
    message,
    recent_messages: chatMessages.filter((record) => record.event_id === event.id).slice(-20)
  };
}

export function postLivePremiereIntro(authorizationHeader: string | undefined, eventID: string, body: unknown): JsonObject {
  const session = requireCreatorHostOrAdmin(authorizationHeader, eventID);
  const event = eventForID(eventID);
  const intro: LivePremiereIntroRecord = {
    id: `live-premiere-intro-${introCounter++}`,
    event_id: event.id,
    creator_id: event.creator_id,
    title: trimmed(optionalStringFromBody(body, "title") ?? `${event.title} creator introduction`, 120),
    message: trimmed(stringFromBody(body, "message", "invalid_live_premiere_intro"), 360),
    duration_seconds: clampedSeconds(numberFromBody(body, "duration_seconds") ?? 90),
    created_at: nowISO()
  };
  intros.push(intro);
  event.updated_at = intro.created_at;
  recordProductNotification({
    userID: event.host_user_id,
    role: "creator",
    category: "release",
    title: "Creator intro added",
    body: `${intro.title} is ready for the premiere room.`,
    deepLink: "highfive://creator/live-premieres"
  });
  return {
    status: "recorded",
    introduction: intro,
    event
  };
}

export function postLivePremiereQuestion(authorizationHeader: string | undefined, eventID: string, body: unknown): JsonObject {
  const session = requireLivePremiereSession(authorizationHeader);
  const event = requireEventAccess(session, eventID);
  const question: LivePremiereQuestionRecord = {
    id: `live-premiere-question-${questionCounter++}`,
    event_id: event.id,
    user_id: session.user_id,
    question: trimmed(stringFromBody(body, "question", "invalid_live_premiere_question"), 280),
    status: "open",
    answer: null,
    answered_by_user_id: null,
    created_at: nowISO(),
    answered_at: null
  };
  questions.push(question);
  return {
    status: "recorded",
    question,
    open_questions: questions.filter((record) => record.event_id === event.id && record.status === "open")
  };
}

export function answerLivePremiereQuestion(
  authorizationHeader: string | undefined,
  eventID: string,
  questionID: string,
  body: unknown
): JsonObject {
  const session = requireCreatorHostOrAdmin(authorizationHeader, eventID);
  const event = eventForID(eventID);
  const question = questions.find((record) => record.id === questionID && record.event_id === event.id);
  if (!question) {
    throw new ContractError("live_premiere_question_not_found", "Live premiere question was not found", 404);
  }
  question.status = "answered";
  question.answer = trimmed(stringFromBody(body, "answer", "invalid_live_premiere_answer"), 360);
  question.answered_by_user_id = session.user_id;
  question.answered_at = nowISO();
  roomForEvent(event.id).state = "qa";
  return {
    status: "answered",
    question
  };
}

export function publishLivePremiereReplay(authorizationHeader: string | undefined, eventID: string, body: unknown): JsonObject {
  const session = requireCreatorHostOrAdmin(authorizationHeader, eventID);
  const event = eventForID(eventID);
  event.state = "replay";
  event.updated_at = nowISO();
  roomForEvent(event.id).state = "replay";
  const replay: LivePremiereReplayRecord = {
    id: `live-premiere-replay-${replayCounter++}`,
    event_id: event.id,
    title: trimmed(optionalStringFromBody(body, "title") ?? `${event.title} Replay`, 120),
    available: true,
    replay_position_seconds: clampedSeconds(numberFromBody(body, "replay_position_seconds") ?? 0),
    published_at: event.updated_at
  };
  replays.push(replay);
  recordAnalyticsEvent("playback_complete", {
    movie_id: event.movie_id,
    live_premiere_id: event.id,
    replay_available: true
  }, {
    authorizationHeader,
    identitySession: session,
    contentID: event.movie_id,
    creatorID: event.creator_id,
    source: "live_premiere_replay"
  });
  return {
    status: "published",
    event,
    replay
  };
}

function seedLivePremieres(): void {
  if (events.length > 0) return;
  const movie = catalogSeed.movies[0];
  const createdAt = catalogSeed.generated_at;
  const event: LivePremiereEventRecord = {
    id: "live-premiere-opening-night",
    movie_id: movie?.id ?? "friendly",
    title: `${movie?.title ?? "The Friendly"} Opening Night Premiere`,
    creator_id: catalogSeed.creators[0]?.id ?? "maya-hart",
    host_user_id: "local-creator",
    state: "countdown",
    starts_at: minutesFromNowISO(45),
    countdown_seconds: 45 * 60,
    room_id: "live-premiere-room-opening-night",
    created_at: createdAt,
    updated_at: createdAt
  };
  const room: LivePremiereRoomRecord = {
    id: event.room_id,
    event_id: event.id,
    state: "lobby",
    participant_user_ids: ["local-creator", "local-admin"],
    max_capacity: 500,
    updated_at: createdAt
  };
  events.push(event);
  rooms.push(room);
  intros.push({
    id: "live-premiere-intro-opening-night",
    event_id: event.id,
    creator_id: event.creator_id,
    title: "Opening Night Creator Introduction",
    message: "Welcome to the local HighFive premiere room.",
    duration_seconds: 90,
    created_at: createdAt
  });
}

function requireLivePremiereSession(authorizationHeader: string | undefined): IdentitySession {
  return requireIdentitySession(authorizationHeader);
}

function requireCreatorOrAdmin(authorizationHeader: string | undefined): IdentitySession {
  const session = requireLivePremiereSession(authorizationHeader);
  if (session.role !== "creator" && session.role !== "admin") {
    throw new ContractError("creator_role_required", "Live premiere management requires a creator or admin session", 403);
  }
  return session;
}

function requireCreatorHostOrAdmin(authorizationHeader: string | undefined, eventID: string): IdentitySession {
  const session = requireCreatorOrAdmin(authorizationHeader);
  const event = eventForID(eventID);
  if (!isEventHost(session, event)) {
    throw new ContractError("live_premiere_host_required", "Live premiere action requires the event host or an admin", 403);
  }
  return session;
}

function requireEventAccess(session: IdentitySession, eventID: string): LivePremiereEventRecord {
  const event = eventForID(eventID);
  if (!canAccessEvent(session, event)) {
    throw new ContractError("live_premiere_access_denied", "Session cannot access this live premiere", 403);
  }
  return event;
}

function canAccessEvent(_session: IdentitySession, _event: LivePremiereEventRecord): boolean {
  return true;
}

function isEventHost(session: IdentitySession, event: LivePremiereEventRecord): boolean {
  return session.role === "admin" || event.host_user_id === session.user_id || event.creator_id === session.creator_id;
}

function eventForID(eventID: string): LivePremiereEventRecord {
  const event = events.find((record) => record.id === eventID);
  if (!event) {
    throw new ContractError("live_premiere_not_found", "Live premiere event was not found", 404);
  }
  return event;
}

function roomForEvent(eventID: string): LivePremiereRoomRecord {
  const room = rooms.find((record) => record.event_id === eventID);
  if (!room) {
    throw new ContractError("live_premiere_room_not_found", "Live premiere room was not found", 404);
  }
  return room;
}

function movieForID(movieID: string): CatalogMovie {
  const movie = catalogSeed.movies.find((candidate) => candidate.id === movieID);
  if (!movie) {
    throw new ContractError("content_not_found", `Movie ${movieID} was not found`, 404);
  }
  return movie;
}

function eventStateForRoom(roomState: PremiereRoomState, fallback: LivePremiereState): LivePremiereState {
  if (roomState === "open") return "premiere";
  if (roomState === "qa") return "afterparty";
  if (roomState === "replay") return "replay";
  return fallback;
}

function roomStateFromBody(body: unknown): PremiereRoomState | null {
  const state = optionalStringFromBody(body, "state");
  return state === "lobby" || state === "open" || state === "qa" || state === "replay" ? state : null;
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

function clampedSeconds(value: number): number {
  return Math.max(0, Math.min(Math.round(value), 7 * 24 * 60 * 60));
}

function clampedCapacity(value: number): number {
  return Math.max(1, Math.min(Math.round(value), 100_000));
}

function secondsUntil(iso: string): number {
  const diff = Date.parse(iso) - Date.now();
  if (!Number.isFinite(diff)) return 0;
  return clampedSeconds(Math.ceil(diff / 1000));
}

function minutesFromNowISO(minutes: number): string {
  return new Date(Date.now() + minutes * 60 * 1000).toISOString();
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
