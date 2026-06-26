#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$ROOT_DIR/docker-compose.production.yml"
ENV_FILE="$ROOT_DIR/.env.production"

usage() {
  cat <<'USAGE'
Usage:
  deploy.sh verify
  deploy.sh up
  deploy.sh down
  deploy.sh status

LP1 uses Docker Compose for the production stack. Secrets must be supplied as
host-local files referenced by .env.production. No credentials belong in git.
USAGE
}

require_env_file() {
  if [[ ! -f "$ENV_FILE" ]]; then
    echo "Missing $ENV_FILE" >&2
    echo "Create it from env.production.example and set host-local secret file paths." >&2
    exit 2
  fi
}

require_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is required for a real LP1 deploy on this host." >&2
    exit 3
  fi
  if ! docker compose version >/dev/null 2>&1; then
    echo "Docker Compose is required for a real LP1 deploy on this host." >&2
    exit 3
  fi
}

verify_static() {
  "$ROOT_DIR/verify.sh"
}

case "${1:-}" in
  verify)
    verify_static
    ;;
  up)
    require_env_file
    verify_static
    require_docker
    docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" up -d --build
    docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" ps
    ;;
  down)
    require_env_file
    require_docker
    docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" down
    ;;
  status)
    require_env_file
    require_docker
    docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" ps
    ;;
  *)
    usage
    exit 1
    ;;
esac

