#!/bin/bash
# restart-check.sh — Validate service and restart if down, inject env vars
# Usage: ./scripts/restart-check.sh <service_name>
# Cron: */5 * * * * /opt/scripts/restart-check.sh banking-app

set -euo pipefail

SERVICE="${1:-banking-app}"
HEALTH_URL="http://localhost:8080/health"
LOG_FILE="/var/log/banking-app/restart-check.log"
ENV_FILE="/opt/banking-app/.env"

mkdir -p "$(dirname ${LOG_FILE}")"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOG_FILE}"; }

log "Checking service: ${SERVICE}"

if ! docker ps --format '{{.Names}}' | grep -q "^${SERVICE}$"; then
    log "WARNING: ${SERVICE} not running — attempting restart..."

    if [ -f "${ENV_FILE}" ]; then
        log "Loading environment from ${ENV_FILE}"
        set -a; source "${ENV_FILE}"; set +a
    fi

    docker start "${SERVICE}" 2>/dev/null || { log "ERROR: Restart failed"; exit 1; }
    sleep 5

    if curl -sf "${HEALTH_URL}" > /dev/null; then
        log "OK: ${SERVICE} restarted and is healthy"
    else
        log "ERROR: ${SERVICE} restarted but health check failed"
        exit 1
    fi
else
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${HEALTH_URL}" || echo "000")
    log "OK: ${SERVICE} is running — HTTP ${HTTP_CODE}"
fi
