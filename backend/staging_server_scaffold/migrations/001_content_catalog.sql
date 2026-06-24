CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  display_name TEXT NOT NULL,
  role TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS creators (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  role TEXT NOT NULL,
  avatar_asset_name TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS movies (
  id TEXT PRIMARY KEY,
  creator_id TEXT NOT NULL REFERENCES creators(id),
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL,
  synopsis TEXT NOT NULL,
  year TEXT NOT NULL,
  rating TEXT NOT NULL,
  duration TEXT NOT NULL,
  genres JSONB NOT NULL DEFAULT '[]'::jsonb,
  poster_asset_name TEXT,
  backdrop_asset_name TEXT,
  is_original BOOLEAN NOT NULL DEFAULT false,
  is_coming_soon BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS series (
  id TEXT PRIMARY KEY,
  creator_id TEXT NOT NULL REFERENCES creators(id),
  hero_movie_id TEXT REFERENCES movies(id),
  title TEXT NOT NULL,
  synopsis TEXT NOT NULL,
  genre TEXT NOT NULL,
  release_state TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS seasons (
  id TEXT PRIMARY KEY,
  series_id TEXT NOT NULL REFERENCES series(id),
  season_number INTEGER NOT NULL,
  title TEXT NOT NULL,
  UNIQUE(series_id, season_number)
);

CREATE TABLE IF NOT EXISTS episodes (
  id TEXT PRIMARY KEY,
  series_id TEXT NOT NULL REFERENCES series(id),
  season_id TEXT NOT NULL REFERENCES seasons(id),
  season_number INTEGER NOT NULL,
  episode_number INTEGER NOT NULL,
  title TEXT NOT NULL,
  synopsis TEXT NOT NULL,
  runtime TEXT NOT NULL,
  release_state TEXT NOT NULL,
  UNIQUE(series_id, season_number, episode_number)
);

CREATE TABLE IF NOT EXISTS collections (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  subtitle TEXT
);

CREATE TABLE IF NOT EXISTS collection_titles (
  collection_id TEXT NOT NULL REFERENCES collections(id),
  movie_id TEXT NOT NULL REFERENCES movies(id),
  position INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY(collection_id, movie_id)
);

CREATE TABLE IF NOT EXISTS publishing_projects (
  id TEXT PRIMARY KEY,
  creator_id TEXT NOT NULL REFERENCES creators(id),
  content_id TEXT REFERENCES movies(id),
  title TEXT NOT NULL,
  release_state TEXT NOT NULL,
  poster_status TEXT NOT NULL,
  trailer_status TEXT NOT NULL,
  metadata_status TEXT NOT NULL,
  artwork_status TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS project_manifests (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL REFERENCES publishing_projects(id),
  manifest_version TEXT NOT NULL,
  status TEXT NOT NULL,
  manifest JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE IF NOT EXISTS asset_records (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL REFERENCES publishing_projects(id),
  kind TEXT NOT NULL,
  lifecycle TEXT NOT NULL,
  readiness TEXT NOT NULL,
  storage_key TEXT,
  checksum TEXT
);

CREATE TABLE IF NOT EXISTS processing_jobs (
  id TEXT PRIMARY KEY,
  asset_id TEXT NOT NULL REFERENCES asset_records(id),
  status TEXT NOT NULL,
  detail TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS library_records (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  movie_id TEXT NOT NULL REFERENCES movies(id),
  state TEXT NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS playback_progress (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  movie_id TEXT NOT NULL REFERENCES movies(id),
  progress NUMERIC NOT NULL DEFAULT 0,
  completed BOOLEAN NOT NULL DEFAULT false,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
