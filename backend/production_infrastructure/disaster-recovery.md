# HighFive Cinema LP1 Disaster Recovery

## Recovery Objectives

- API recovery: restore a healthy `/health` and `/ready` response.
- Database recovery: restore latest verified `catalog.sql` backup.
- Object storage recovery: verify object manifest and media bucket integrity.
- Media worker recovery: restart workers only after object storage is healthy.
- CDN recovery: route traffic only after API health is green.

## Procedure

1. Freeze deploys.
2. Preserve logs and audit output.
3. Run `./backend/production_infrastructure/deploy.sh status`.
4. If database corruption is suspected, stop writers and run `restore.sh`.
5. If object storage corruption is suspected, compare the object manifest from the latest backup.
6. Restart services with `deploy.sh up`.
7. Verify `/health`, `/ready`, monitoring, dashboard, and smoke tests.

## Rollback

Use `docs/ROLLBACK_PLAN.md` for app/backend rollback sequencing. LP1 infrastructure rollback uses:

```bash
./backend/production_infrastructure/deploy.sh down
```

Then redeploy the previous tagged infrastructure commit.

