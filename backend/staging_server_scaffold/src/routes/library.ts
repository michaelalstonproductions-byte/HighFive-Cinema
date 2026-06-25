import { catalogSeed, type CatalogMovie } from "../catalog/catalogSeed.js";
import { ContractError } from "../errors.js";
import { recordAnalyticsEvent } from "./analytics.js";
import { requireIdentitySession, type IdentitySession } from "./identity.js";

type ViewerLibraryState = "saved" | "favorite" | "watch_later" | "history";

type ViewerLibraryRecord = {
  id: string;
  user_id: string;
  movie_id: string;
  state: ViewerLibraryState;
  updated_at: string;
};

export type ViewerLibraryRecommendationContext = {
  user_id: string;
  saved_movie_ids: string[];
  progress_movie_ids: string[];
  completed_movie_ids: string[];
  offline_movie_ids: string[];
};

type ViewerProgressRecord = {
  id: string;
  user_id: string;
  movie_id: string;
  progress: number;
  completed: boolean;
  updated_at: string;
};

type ViewerOfflineRecord = {
  id: string;
  user_id: string;
  movie_id: string;
  state: "queued" | "downloading" | "downloaded" | "paused" | "cancelled" | "deleted" | "expired";
  storage_state: "available" | "low_space" | "released";
  entitlement_state: "active" | "expired";
  bytes: number;
  updated_at: string;
};

const libraryRecords: ViewerLibraryRecord[] = catalogSeed.library_records.map((record) => ({
  id: record.id,
  user_id: record.user_id,
  movie_id: record.movie_id,
  state: normalizeLibraryState(record.state),
  updated_at: catalogSeed.generated_at
}));

const progressRecords: ViewerProgressRecord[] = catalogSeed.playback_progress.map((record) => ({
  ...record,
  updated_at: catalogSeed.generated_at
}));

const offlineRecords: ViewerOfflineRecord[] = catalogSeed.movies
  .filter((movie) => movie.is_downloaded)
  .map((movie) => ({
    id: `offline-${movie.id}`,
    user_id: "local-viewer",
    movie_id: movie.id,
    state: "downloaded",
    storage_state: "available",
    entitlement_state: "active",
    bytes: 18_874_368,
    updated_at: catalogSeed.generated_at
  }));

export function viewerLibrarySnapshot(authorizationHeader: string | undefined) {
  const session = requireViewerSession(authorizationHeader);
  return snapshotFor(session);
}

export function saveViewerLibraryTitle(authorizationHeader: string | undefined, body: unknown) {
  const session = requireViewerSession(authorizationHeader);
  const movieID = movieIDFromBody(body);
  const saved = booleanFromBody(body, "saved") ?? true;
  const state = stateFromBody(body) ?? "saved";
  const movie = movieForID(movieID);
  const existingIndex = libraryRecords.findIndex((record) => record.user_id === session.user_id && record.movie_id === movieID && record.state === state);
  if (!saved) {
    if (existingIndex >= 0) libraryRecords.splice(existingIndex, 1);
  } else if (existingIndex >= 0) {
    libraryRecords[existingIndex] = { ...libraryRecords[existingIndex], updated_at: nowISO() };
  } else {
    libraryRecords.push({
      id: `library-${session.user_id}-${movieID}-${state}`,
      user_id: session.user_id,
      movie_id: movieID,
      state,
      updated_at: nowISO()
    });
  }
  recordAnalyticsEvent(state === "favorite" ? "favorite" : "save", {
    movie_id: movieID,
    state,
    saved
  }, { authorizationHeader, contentID: movieID, source: "viewer_library_save" });
  return {
    status: saved ? "saved" : "removed",
    record: libraryRecords.find((record) => record.user_id === session.user_id && record.movie_id === movieID && record.state === state) ?? null,
    movie,
    snapshot: snapshotFor(session)
  };
}

export function updateViewerProgress(authorizationHeader: string | undefined, body: unknown) {
  const session = requireViewerSession(authorizationHeader);
  const movieID = movieIDFromBody(body);
  movieForID(movieID);
  const progress = clampedProgress(numberFromBody(body, "progress") ?? 0);
  const completed = booleanFromBody(body, "completed") ?? progress >= 0.95;
  const existingIndex = progressRecords.findIndex((record) => record.user_id === session.user_id && record.movie_id === movieID);
  const record: ViewerProgressRecord = {
    id: existingIndex >= 0 ? progressRecords[existingIndex].id : `progress-${session.user_id}-${movieID}`,
    user_id: session.user_id,
    movie_id: movieID,
    progress,
    completed,
    updated_at: nowISO()
  };
  if (existingIndex >= 0) {
    progressRecords[existingIndex] = record;
  } else {
    progressRecords.push(record);
  }
  ensureHistoryRecord(session.user_id, movieID);
  recordAnalyticsEvent(completed ? "playback_complete" : progress > 0 ? "playback_progress" : "playback_start", {
    movie_id: movieID,
    progress,
    completed
  }, { authorizationHeader, contentID: movieID, source: "viewer_library_progress" });
  return {
    status: "progress_saved",
    record,
    next_episode: nextEpisodeFor(movieID, progress),
    snapshot: snapshotFor(session)
  };
}

export function updateViewerOfflineState(authorizationHeader: string | undefined, body: unknown) {
  const session = requireViewerSession(authorizationHeader);
  const movieID = movieIDFromBody(body);
  movieForID(movieID);
  const requestedState = offlineStateFromBody(body) ?? "downloaded";
  const existingIndex = offlineRecords.findIndex((record) => record.user_id === session.user_id && record.movie_id === movieID);
  if (requestedState === "deleted" || requestedState === "cancelled") {
    if (existingIndex >= 0) offlineRecords.splice(existingIndex, 1);
    return {
      status: requestedState,
      record: null,
      snapshot: snapshotFor(session)
    };
  }
  const record: ViewerOfflineRecord = {
    id: existingIndex >= 0 ? offlineRecords[existingIndex].id : `offline-${session.user_id}-${movieID}`,
    user_id: session.user_id,
    movie_id: movieID,
    state: requestedState,
    storage_state: "available",
    entitlement_state: "active",
    bytes: numberFromBody(body, "bytes") ?? 24_117_248,
    updated_at: nowISO()
  };
  if (existingIndex >= 0) {
    offlineRecords[existingIndex] = record;
  } else {
    offlineRecords.push(record);
  }
  return {
    status: "offline_state_saved",
    record,
    snapshot: snapshotFor(session)
  };
}

export function viewerLibraryReadinessSummary() {
  return {
    viewer_library_enabled: true,
    saved_titles: true,
    playback_progress: true,
    offline_records: true,
    per_profile_progress: true,
    conflict_policy: "newest_record_wins",
    local_cache_fallback: true
  };
}

export function viewerLibraryRecommendationContext(authorizationHeader: string | undefined): ViewerLibraryRecommendationContext | null {
  if (!authorizationHeader) return null;
  const session = requireViewerSession(authorizationHeader);
  const saved = libraryRecords.filter((record) => record.user_id === session.user_id);
  const progress = progressRecords.filter((record) => record.user_id === session.user_id);
  const offline = offlineRecords.filter((record) => record.user_id === session.user_id);
  return {
    user_id: session.user_id,
    saved_movie_ids: saved.map((record) => record.movie_id),
    progress_movie_ids: progress.map((record) => record.movie_id),
    completed_movie_ids: progress.filter((record) => record.completed || record.progress >= 0.95).map((record) => record.movie_id),
    offline_movie_ids: offline.map((record) => record.movie_id)
  };
}

function snapshotFor(session: IdentitySession) {
  const saved = libraryRecords.filter((record) => record.user_id === session.user_id);
  const progress = progressRecords.filter((record) => record.user_id === session.user_id);
  const offline = offlineRecords.filter((record) => record.user_id === session.user_id);
  return {
    status: "ready",
    user_id: session.user_id,
    profile_id: session.workspace_id,
    saved_titles: saved,
    favorites: saved.filter((record) => record.state === "favorite"),
    watch_later: saved.filter((record) => record.state === "watch_later" || record.state === "saved"),
    viewing_history: progress
      .slice()
      .sort((lhs, rhs) => rhs.updated_at.localeCompare(lhs.updated_at)),
    continue_watching: progress.filter((record) => !record.completed && record.progress > 0 && record.progress < 0.95),
    completed: progress.filter((record) => record.completed || record.progress >= 0.95),
    offline_records: offline,
    recommendations: recommendationsFor(progress, saved),
    conflict_policy: "newest_record_wins",
    updated_at: nowISO()
  };
}

function requireViewerSession(authorizationHeader: string | undefined): IdentitySession {
  const session = requireIdentitySession(authorizationHeader);
  if (session.role !== "viewer" && session.role !== "admin") {
    const error = new Error("viewer_role_required");
    error.name = "ForbiddenIdentityAccess";
    throw error;
  }
  return session;
}

function movieIDFromBody(body: unknown): string {
  if (!isRecord(body) || typeof body.movie_id !== "string") {
    throw new ContractError("invalid_library_request", "Library mutation requires movie_id", 400);
  }
  return body.movie_id;
}

function stateFromBody(body: unknown): ViewerLibraryState | null {
  if (!isRecord(body) || typeof body.state !== "string") return null;
  return normalizeLibraryState(body.state);
}

function normalizeLibraryState(state: string): ViewerLibraryState {
  if (state === "favorite" || state === "watch_later" || state === "history") return state;
  return "saved";
}

function offlineStateFromBody(body: unknown): ViewerOfflineRecord["state"] | null {
  if (!isRecord(body) || typeof body.state !== "string") return null;
  const allowed: ViewerOfflineRecord["state"][] = ["queued", "downloading", "downloaded", "paused", "cancelled", "deleted", "expired"];
  return allowed.includes(body.state as ViewerOfflineRecord["state"]) ? body.state as ViewerOfflineRecord["state"] : null;
}

function booleanFromBody(body: unknown, key: string): boolean | null {
  if (!isRecord(body)) return null;
  return typeof body[key] === "boolean" ? body[key] : null;
}

function numberFromBody(body: unknown, key: string): number | null {
  if (!isRecord(body)) return null;
  return typeof body[key] === "number" && Number.isFinite(body[key]) ? body[key] : null;
}

function movieForID(movieID: string): CatalogMovie {
  const movie = catalogSeed.movies.find((candidate) => candidate.id === movieID);
  if (!movie) {
    throw new ContractError("content_not_found", "Library content was not found", 404);
  }
  return movie;
}

function ensureHistoryRecord(userID: string, movieID: string): void {
  if (libraryRecords.some((record) => record.user_id === userID && record.movie_id === movieID && record.state === "history")) return;
  libraryRecords.push({
    id: `library-${userID}-${movieID}-history`,
    user_id: userID,
    movie_id: movieID,
    state: "history",
    updated_at: nowISO()
  });
}

function recommendationsFor(progress: ViewerProgressRecord[], saved: ViewerLibraryRecord[]) {
  const watchedGenres = new Set(
    progress
      .map((record) => movieForID(record.movie_id))
      .flatMap((movie) => movie.genres)
  );
  const savedIDs = new Set(saved.map((record) => record.movie_id));
  return catalogSeed.movies
    .filter((movie) => !savedIDs.has(movie.id) && movie.genres.some((genre) => watchedGenres.has(genre)))
    .slice(0, 6)
    .map((movie) => ({
      movie_id: movie.id,
      title: movie.title,
      reason: `Because you watched ${Array.from(watchedGenres).slice(0, 2).join(" / ") || "HighFive"}`
    }));
}

function nextEpisodeFor(movieID: string, progress: number) {
  const series = catalogSeed.series.find((candidate) => candidate.hero_movie_id === movieID || candidate.id === movieID);
  const episode = series?.seasons.flatMap((season) => season.episodes).find((candidate) => (candidate.progress ?? progress) < 0.95);
  return episode
    ? {
        episode_id: episode.id,
        series_id: episode.series_id,
        title: episode.title,
        season_number: episode.season_number,
        episode_number: episode.episode_number
      }
    : null;
}

function clampedProgress(value: number): number {
  return Math.max(0, Math.min(1, value));
}

function nowISO(): string {
  return new Date().toISOString();
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
