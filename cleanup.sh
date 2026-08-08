#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$0")"
echo "This will remove the project containers, local image, network, and all project volumes."
read -r -p "Continue? [y/N] " answer
[[ "$answer" =~ ^[Yy]$ ]] || { echo "Cleanup cancelled."; exit 0; }
docker compose down --volumes --remove-orphans --rmi local
echo "Project environment cleaned. Backup files in the backups directory were preserved."
