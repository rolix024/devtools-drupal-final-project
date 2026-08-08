#!/usr/bin/env bash
set -Eeuo pipefail

cd /opt/drupal
settings_file="web/sites/default/settings.php"

if [[ ! -f "$settings_file" ]]; then
  echo "[Drupal] Waiting for MySQL..."
  until php -r 'try { new PDO("mysql:host=database;port=3306;dbname=".getenv("MYSQL_DATABASE"), getenv("MYSQL_USER"), getenv("MYSQL_PASSWORD")); exit(0); } catch (Throwable $e) { exit(1); }'; do
    sleep 3
  done

  echo "[Drupal] Installing the site..."
  vendor/bin/drush site:install standard -y \
    --db-url="mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@database:3306/${MYSQL_DATABASE}" \
    --account-name="${DRUPAL_ADMIN_USER}" \
    --account-pass="${DRUPAL_ADMIN_PASSWORD}" \
    --account-mail="${DRUPAL_ADMIN_EMAIL}" \
    --site-name="${DRUPAL_SITE_NAME}" \
    --site-mail="${DRUPAL_ADMIN_EMAIL}"

  vendor/bin/drush en -y language locale
  vendor/bin/drush language:add he || true
  vendor/bin/drush config:set -y system.site default_langcode he
  vendor/bin/drush theme:enable -y devtools_hebrew
  vendor/bin/drush config:set -y system.theme default devtools_hebrew
  vendor/bin/drush en -y devtools_content
  vendor/bin/drush user:create "${TEAM_USER_1}" --password="${TEAM_PASSWORD_1}"
  vendor/bin/drush user:create "${TEAM_USER_2}" --password="${TEAM_PASSWORD_2}"
  vendor/bin/drush cache:rebuild
  chown -R www-data:www-data web/sites/default
  echo "[Drupal] Installation complete: http://localhost:8080"
else
  echo "[Drupal] Existing installation detected."
fi

exec docker-php-entrypoint "$@"
