#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$ROOT_DIR/.env.production"
COMPOSE_FILE="$ROOT_DIR/docker-compose.production.yml"
BACKUP_DIR="$ROOT_DIR/backups/$(date -u +%Y%m%dT%H%M%SZ)"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE" >&2
  exit 2
fi
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required to run LP1 backups." >&2
  exit 3
fi

mkdir -p "$BACKUP_DIR"
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" exec -T postgres pg_dump -U "${HIGHFIVE_POSTGRES_USER:-highfive_app}" "${HIGHFIVE_POSTGRES_DB:-highfive_cinema}" > "$BACKUP_DIR/catalog.sql"
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" exec -T object-storage sh -lc 'find /data -maxdepth 3 -type f | sort' > "$BACKUP_DIR/object-storage-manifest.txt"
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" ps > "$BACKUP_DIR/compose-status.txt"
echo "Backup written to $BACKUP_DIR"

