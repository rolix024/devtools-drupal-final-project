#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$0")"

command -v docker >/dev/null 2>&1 || { echo "Error: Docker is not installed." >&2; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "Error: Docker Compose is not available." >&2; exit 1; }

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Created .env from .env.example."
fi

echo "Creating the network, pulling images, and starting MySQL and Drupal..."
docker compose up -d --build

echo "Waiting for Drupal installation to finish..."
for attempt in {1..60}; do
  if curl --fail --silent --output /dev/null http://localhost:8080/; then
    echo "The site is ready: http://localhost:8080"
    echo "Administrator login: demoadmin / secretpass"
    exit 0
  fi
  sleep 5
done

echo "The site did not become ready in time. Check: docker compose logs drupal" >&2
exit 1
