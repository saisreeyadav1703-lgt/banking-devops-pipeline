#!/bin/bash
# log-rotation.sh — Rotate application logs to prevent disk fill
# Cron: 0 2 * * * /opt/scripts/log-rotation.sh

set -euo pipefail

LOG_DIR="/var/log/banking-app"
ARCHIVE_DIR="${LOG_DIR}/archive"
RETENTION_DAYS=7
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

mkdir -p "${ARCHIVE_DIR}"
echo "[$(date)] Starting log rotation..."

find "${LOG_DIR}" -maxdepth 1 -name "*.log" -mtime +0 | while read -r logfile; do
    filename=$(basename "${logfile}" .log)
    archive="${ARCHIVE_DIR}/${filename}_${TIMESTAMP}.log.gz"
    gzip -c "${logfile}" > "${archive}"
    > "${logfile}"
    echo "[INFO] Rotated: ${logfile} -> ${archive}"
done

find "${ARCHIVE_DIR}" -name "*.log.gz" -mtime "+${RETENTION_DAYS}" -delete
echo "[$(date)] Log rotation complete — archives older than ${RETENTION_DAYS} days removed"
