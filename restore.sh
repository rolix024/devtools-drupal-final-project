#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$0")"
[[ -f .env ]] && set -a && source .env && set +a
db_file="${1:-$(ls -1t backups/drupal-db-*.sql.gz 2>/dev/null | head -n1 || true)}"
files_file="${2:-$(ls -1t backups/drupal-files-*.tar.gz 2>/dev/null | head -n1 || true)}"

[[ -n "$db_file" && -f "$db_file" ]] || { echo "No database backup was found." >&2; exit 1; }
[[ -n "$files_file" && -f "$files_file" ]] || { echo "No Drupal files backup was found." >&2; exit 1; }

echo "Starting the services and waiting for MySQL..."
docker compose up -d --build
until docker compose exec -T database mysqladmin ping -h localhost -uroot -p"${MYSQL_ROOT_PASSWORD:-my-secret-pw}" --silent; do sleep 3; done

echo "Restoring MySQL from $db_file..."
gzip -dc "$db_file" | docker compose exec -T database mysql -uroot -p"${MYSQL_ROOT_PASSWORD:-my-secret-pw}"

echo "Restoring Drupal files from $files_file..."
docker compose exec -T drupal tar -C /opt/drupal/web -xzf - < "$files_file"
docker compose exec -T drupal chown -R www-data:www-data /opt/drupal/web/sites /opt/drupal/web/modules /opt/drupal/web/themes
docker compose restart drupal
echo "Restore completed: http://localhost:8080"
