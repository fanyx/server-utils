#!/bin/bash

CONTAINER_APP="nextcloud-app"
CONTAINER_DB="nextcloud-db"
NC_ENV_FILE="/srv/docker/nextcloud/.env-db"

echo "Set Nextcloud maintenance mode: on"
docker exec -it -u www-data $CONTAINER_APP php occ maintenance:mode --on

echo "Backup MySQL database using LOCK script"
docker-mysqlbackup $CONTAINER_DB $NC_ENV_FILE

echo "Set Nextcloud maintenance mode: off"
docker exec -it -u www-data $CONTAINER_APP php occ maintenance:mode --off
