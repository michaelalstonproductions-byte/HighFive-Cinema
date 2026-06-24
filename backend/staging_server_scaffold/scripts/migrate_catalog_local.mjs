import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";

const root = resolve(import.meta.dirname, "..");
const migrationPath = resolve(root, "migrations/001_content_catalog.sql");
const seedPath = resolve(root, "seed/catalog.json");
const statePath = resolve(root, ".local/catalog_migration_state.json");

const migrationSql = readFileSync(migrationPath, "utf8");
const seed = JSON.parse(readFileSync(seedPath, "utf8"));
const requiredTables = [
  "users",
  "creators",
  "movies",
  "series",
  "seasons",
  "episodes",
  "collections",
  "collection_titles",
  "publishing_projects",
  "project_manifests",
  "asset_records",
  "processing_jobs",
  "library_records",
  "playback_progress"
];

const missingTables = requiredTables.filter((tableName) => !migrationSql.includes(`CREATE TABLE IF NOT EXISTS ${tableName}`));
if (missingTables.length > 0) {
  throw new Error(`Missing migration table definitions: ${missingTables.join(", ")}`);
}

mkdirSync(dirname(statePath), { recursive: true });
writeFileSync(statePath, JSON.stringify({
  status: "migrated",
  migration: "001_content_catalog.sql",
  schema: "postgresql_compatible_v1",
  seed: seed.generated_at,
  tables: requiredTables,
  updated_at: new Date().toISOString()
}, null, 2));

process.stdout.write(`catalog migration validated ${requiredTables.length} tables\n`);
