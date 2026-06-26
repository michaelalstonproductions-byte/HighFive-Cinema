# HighFive Cinema LP1 Production Infrastructure

LP1 defines the production deployment shape for HighFive Cinema without committing credentials or replacing the existing backend architecture.

## One-Command Deploy

From the repository root:

```bash
./backend/production_infrastructure/deploy.sh up
```

The command validates the production configuration, requires Docker Compose for a real deployment, and starts:

- HighFive API backend
- PostgreSQL-compatible database
- S3-compatible object storage
- Media processing worker
- CDN/reverse proxy
- Monitoring
- Logging sink
- Health dashboard

For environments without Docker, verify the deploy plan with:

```bash
./backend/production_infrastructure/deploy.sh verify
```

## Configuration

Copy the example file locally:

```bash
cp backend/production_infrastructure/env.production.example backend/production_infrastructure/.env.production
```

Then set secret file paths that exist only on the deployment host. Never commit `.env.production` or files under `secrets/`.

## Health

After deployment:

- API: `GET /health`
- Readiness: `GET /ready`
- Dashboard: local dashboard container on the configured dashboard port
- Monitoring: Prometheus-compatible scrape config in `monitoring/prometheus.yml`

## Backup And Disaster Recovery

Use:

```bash
./backend/production_infrastructure/backup.sh
./backend/production_infrastructure/restore.sh <backup-directory>
```

The scripts are safety wrappers. They require Docker Compose and write only under the ignored local `backups/` and `state/` directories.

