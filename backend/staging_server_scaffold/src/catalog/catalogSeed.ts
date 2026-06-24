export type CatalogMovie = {
  id: string;
  title: string;
  subtitle: string;
  synopsis: string;
  year: string;
  rating: string;
  duration: string;
  genres: string[];
  poster_asset_name: string | null;
  backdrop_asset_name: string | null;
  creator_id: string;
  creator_name: string;
  is_original: boolean;
  is_coming_soon: boolean;
  is_downloaded: boolean;
  progress: number | null;
  collection_ids: string[];
};

export type CatalogCreator = {
  id: string;
  name: string;
  role: string;
  avatar_asset_name: string | null;
  featured_movie_ids: string[];
};

export type CatalogEpisode = {
  id: string;
  series_id: string;
  season_number: number;
  episode_number: number;
  title: string;
  synopsis: string;
  runtime: string;
  release_state: "draft" | "review" | "scheduled" | "published" | "archived";
  progress: number | null;
};

export type CatalogSeason = {
  id: string;
  series_id: string;
  season_number: number;
  title: string;
  episodes: CatalogEpisode[];
};

export type CatalogSeries = {
  id: string;
  title: string;
  synopsis: string;
  creator_id: string;
  creator_name: string;
  genre: string;
  release_state: "draft" | "review" | "scheduled" | "published" | "archived";
  hero_movie_id: string;
  seasons: CatalogSeason[];
};

export type CatalogCollection = {
  id: string;
  title: string;
  subtitle: string | null;
  movie_ids: string[];
};

export type CatalogSeed = {
  generated_at: string;
  users: { id: string; display_name: string; role: string }[];
  creators: CatalogCreator[];
  movies: CatalogMovie[];
  series: CatalogSeries[];
  collections: CatalogCollection[];
  publishing_projects: {
    id: string;
    title: string;
    creator_id: string;
    content_id: string;
    release_state: "draft" | "review" | "scheduled" | "published" | "archived";
    poster_status: string;
    trailer_status: string;
    metadata_status: string;
    artwork_status: string;
  }[];
  project_manifests: { id: string; project_id: string; manifest_version: string; status: string }[];
  asset_records: { id: string; project_id: string; kind: string; lifecycle: string; readiness: string }[];
  processing_jobs: { id: string; asset_id: string; status: "not_started"; detail: string }[];
  library_records: { id: string; user_id: string; movie_id: string; state: string }[];
  playback_progress: { id: string; user_id: string; movie_id: string; progress: number; completed: boolean }[];
};

export const catalogSeed: CatalogSeed = {
  generated_at: "2026-06-24T00:00:00.000Z",
  users: [
    { id: "local-viewer", display_name: "Local Viewer", role: "viewer" },
    { id: "local-creator", display_name: "HighFive Creator", role: "creator" }
  ],
  creators: [
    { id: "maya-hart", name: "Maya Hart", role: "Director", avatar_asset_name: null, featured_movie_ids: ["friendly", "behind-the-vision"] },
    { id: "noah-vale", name: "Noah Vale", role: "Showrunner", avatar_asset_name: null, featured_movie_ids: ["paranormall-s1"] }
  ],
  movies: [
    {
      id: "friendly",
      title: "The Friendly",
      subtitle: "HighFive Original",
      synopsis: "A cinematic local catalog title used to verify read-only backend catalog delivery.",
      year: "2026",
      rating: "PG-13",
      duration: "2h 04m",
      genres: ["Drama", "Premiere"],
      poster_asset_name: null,
      backdrop_asset_name: null,
      creator_id: "maya-hart",
      creator_name: "Maya Hart",
      is_original: true,
      is_coming_soon: false,
      is_downloaded: false,
      progress: 0.42,
      collection_ids: ["featured", "highfive-originals"]
    },
    {
      id: "paranormall-s1",
      title: "Paranormall",
      subtitle: "Series",
      synopsis: "A local episodic catalog record for series, episode, and continue watching queries.",
      year: "2026",
      rating: "TV-14",
      duration: "7 episodes",
      genres: ["Series", "Mystery"],
      poster_asset_name: null,
      backdrop_asset_name: null,
      creator_id: "noah-vale",
      creator_name: "Noah Vale",
      is_original: true,
      is_coming_soon: false,
      is_downloaded: true,
      progress: 0.28,
      collection_ids: ["featured", "series"]
    },
    {
      id: "behind-the-vision",
      title: "Behind the Vision: Studio Notes",
      subtitle: "Creator Published",
      synopsis: "A creator-published title used by publishing, marketplace, and repository smoke paths.",
      year: "2026",
      rating: "NR",
      duration: "38m",
      genres: ["Documentary", "Creator"],
      poster_asset_name: null,
      backdrop_asset_name: null,
      creator_id: "maya-hart",
      creator_name: "Maya Hart",
      is_original: true,
      is_coming_soon: false,
      is_downloaded: false,
      progress: null,
      collection_ids: ["creator-published", "documentary"]
    }
  ],
  series: [
    {
      id: "paranormall-s1",
      title: "Paranormall",
      synopsis: "A seven-episode local mystery series.",
      creator_id: "noah-vale",
      creator_name: "Noah Vale",
      genre: "Mystery",
      release_state: "published",
      hero_movie_id: "paranormall-s1",
      seasons: [
        {
          id: "paranormall-s1-season-1",
          series_id: "paranormall-s1",
          season_number: 1,
          title: "Season 1",
          episodes: [
            {
              id: "paranormall-s1-e1",
              series_id: "paranormall-s1",
              season_number: 1,
              episode_number: 1,
              title: "Cold Open",
              synopsis: "The series begins with a local signal.",
              runtime: "37m",
              release_state: "published",
              progress: 0.72
            },
            {
              id: "paranormall-s1-e2",
              series_id: "paranormall-s1",
              season_number: 1,
              episode_number: 2,
              title: "The House That Answered",
              synopsis: "The room answers back.",
              runtime: "41m",
              release_state: "published",
              progress: null
            }
          ]
        }
      ]
    }
  ],
  collections: [
    { id: "featured", title: "Featured", subtitle: "Backend seed catalog", movie_ids: ["friendly", "paranormall-s1"] },
    { id: "highfive-originals", title: "HighFive Originals", subtitle: "Original local titles", movie_ids: ["friendly", "paranormall-s1", "behind-the-vision"] },
    { id: "creator-published", title: "Creator Published", subtitle: "Published creator projects", movie_ids: ["behind-the-vision"] },
    { id: "documentary", title: "Documentary", subtitle: "Documentary titles", movie_ids: ["behind-the-vision"] },
    { id: "series", title: "Series", subtitle: "Episodic titles", movie_ids: ["paranormall-s1"] }
  ],
  publishing_projects: [
    {
      id: "project-behind-the-vision",
      title: "Behind the Vision: Studio Notes",
      creator_id: "maya-hart",
      content_id: "behind-the-vision",
      release_state: "published",
      poster_status: "ready",
      trailer_status: "ready",
      metadata_status: "ready",
      artwork_status: "ready"
    }
  ],
  project_manifests: [
    { id: "manifest-project-behind-the-vision", project_id: "project-behind-the-vision", manifest_version: "1.0.0", status: "ready" }
  ],
  asset_records: [
    { id: "asset-poster-behind-the-vision", project_id: "project-behind-the-vision", kind: "poster", lifecycle: "registered", readiness: "ready" },
    { id: "asset-trailer-behind-the-vision", project_id: "project-behind-the-vision", kind: "trailer", lifecycle: "registered", readiness: "ready" }
  ],
  processing_jobs: [
    { id: "job-source-behind-the-vision", asset_id: "asset-trailer-behind-the-vision", status: "not_started", detail: "Processing is intentionally out of scope for P29A." }
  ],
  library_records: [
    { id: "library-local-friendly", user_id: "local-viewer", movie_id: "friendly", state: "saved" },
    { id: "library-local-paranormall", user_id: "local-viewer", movie_id: "paranormall-s1", state: "history" }
  ],
  playback_progress: [
    { id: "progress-local-friendly", user_id: "local-viewer", movie_id: "friendly", progress: 0.42, completed: false },
    { id: "progress-local-paranormall", user_id: "local-viewer", movie_id: "paranormall-s1", progress: 0.28, completed: false }
  ]
};
