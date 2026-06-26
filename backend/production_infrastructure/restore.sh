#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$ROOT_DIR/.env.production"
COMPOSE_FILE="$ROOT_DIR/docker-compose.production.yml"
BACKUP_DIR="${1:-}"

if [[ -z "$BACKUP_DIR" || ! -s "$BACKUP_DIR/catalog.sql" ]]; then
  echo "Usage: restore.sh <backup-directory-containing-catalog.sql>" >&2
  exit 2
fi
if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE" >&2
  exit 2
fi
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required to run LP1 restores." >&2
  exit 3
fi

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" exec -T postgres psql -U "${HIGHFIVE_POSTGRES_USER:-highfive_app}" "${HIGHFIVE_POSTGRES_DB:-highfive_cinema}" < "$BACKUP_DIR/catalog.sql"
echo "Restore applied from $BACKUP_DIR"

