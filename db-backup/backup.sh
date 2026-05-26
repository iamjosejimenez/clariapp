#!/usr/bin/env bash
set -euo pipefail

# Configuration (all from environment, set in config/deploy.yml).
: "${PGHOST:?PGHOST required}"
: "${PGPORT:=5432}"
: "${PGDATABASE:?PGDATABASE required}"
: "${PGUSER:?PGUSER required}"
: "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD required}"
: "${S3_BUCKET:?S3_BUCKET required}"
: "${AWS_DEFAULT_REGION:=us-east-1}"
: "${BACKUP_RETENTION_DAYS:=7}"
: "${BACKUP_WEEKLY_RETENTION:=4}"

export PGPASSWORD="$POSTGRES_PASSWORD"

backup_dir="/var/backups/postgres"
mkdir -p "$backup_dir"

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
dow="$(date -u +%u)"   # 1..7, where 7 = Sunday
filename="claria_${timestamp}.dump"
local_path="${backup_dir}/${filename}"

# Sundays get tagged as weekly so the S3 lifecycle policy keeps them longer.
if [ "$dow" = "7" ]; then
  s3_prefix="weekly"
  s3_tagging="kind=weekly"
else
  s3_prefix="daily"
  s3_tagging="kind=daily"
fi

s3_key="${s3_prefix}/${filename}"

echo "[$(date -u +%FT%TZ)] starting backup ${filename}"

pg_dump \
  --host="$PGHOST" \
  --port="$PGPORT" \
  --username="$PGUSER" \
  --dbname="$PGDATABASE" \
  --format=custom \
  --compress=9 \
  --no-owner \
  --no-acl \
  --file="$local_path"

size="$(stat -c %s "$local_path")"
echo "[$(date -u +%FT%TZ)] dump complete (${size} bytes), uploading to s3://${S3_BUCKET}/${s3_key}"

aws s3 cp "$local_path" "s3://${S3_BUCKET}/${s3_key}" \
  --tagging "$s3_tagging" \
  --only-show-errors

echo "[$(date -u +%FT%TZ)] uploaded ${s3_key}"

# Local retention: keep the most recent ${BACKUP_RETENTION_DAYS} dumps on disk
# as a fallback if S3 is unreachable. Older dumps are pruned.
find "$backup_dir" -maxdepth 1 -type f -name 'claria_*.dump' \
  -mtime "+${BACKUP_RETENTION_DAYS}" -delete || true

echo "[$(date -u +%FT%TZ)] done"
