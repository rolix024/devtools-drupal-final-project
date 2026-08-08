#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$0")"
[[ -f .env ]] && set -a && source .env && set +a
mkdir -p backups
stamp="$(date +%Y%m%d-%H%M%S)"
db_file="backups/drupal-db-${stamp}.sql.gz"
files_file="backups/drupal-files-${stamp}.tar.gz"

echo "Backing up the MySQL database..."
docker compose exec -T database sh -c 'exec mysqldump --single-transaction --routines --triggers --events --set-gtid-purged=OFF --all-databases -uroot -p"$MYSQL_ROOT_PASSWORD"' | gzip > "$db_file"

echo "Backing up the Drupal volume files..."
docker compose exec -T drupal tar -C /opt/drupal/web -czf - sites modules themes > "$files_file"

printf 'Backup completed:\n- %s\n- %s\n' "$db_file" "$files_file"
