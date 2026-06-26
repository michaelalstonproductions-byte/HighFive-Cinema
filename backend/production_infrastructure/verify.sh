#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REQUIRED_FILES=(
  "$ROOT_DIR/docker-compose.production.yml"
  "$ROOT_DIR/env.production.example"
  "$ROOT_DIR/nginx/highfive-cdn.conf"
  "$ROOT_DIR/monitoring/prometheus.yml"
  "$ROOT_DIR/monitoring/health-dashboard.html"
  "$ROOT_DIR/logging/fluent-bit.conf"
  "$ROOT_DIR/backup.sh"
  "$ROOT_DIR/restore.sh"
  "$ROOT_DIR/disaster-recovery.md"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -s "$file" ]]; then
    echo "Missing or empty LP1 file: $file" >&2
    exit 1
  fi
done

grep -q "api:" "$ROOT_DIR/docker-compose.production.yml"
grep -q "postgres:" "$ROOT_DIR/docker-compose.production.yml"
grep -q "object-storage:" "$ROOT_DIR/docker-compose.production.yml"
grep -q "media-worker:" "$ROOT_DIR/docker-compose.production.yml"
grep -q "monitoring:" "$ROOT_DIR/docker-compose.production.yml"
grep -q "logging:" "$ROOT_DIR/docker-compose.production.yml"
grep -q "dashboard:" "$ROOT_DIR/docker-compose.production.yml"
grep -q "HIGHFIVE_SERVER_HOST=0.0.0.0" "$ROOT_DIR/env.production.example"
grep -q "POSTGRES_PASSWORD_FILE" "$ROOT_DIR/docker-compose.production.yml"
grep -q "MINIO_ROOT_PASSWORD_FILE" "$ROOT_DIR/docker-compose.production.yml"

SECRET_PATTERN='(BEGIN .*PRIVATE KEY|Bear'"er |access_[t]oken|refresh_[t]oken|client_[s]ecret"')'
if grep -R --exclude='verify.sh' -nE "$SECRET_PATTERN" "$ROOT_DIR" >/tmp/highfive-lp1-secret-scan.txt; then
  cat /tmp/highfive-lp1-secret-scan.txt >&2
  exit 1
fi

echo "LP1 production infrastructure static verification passed."
