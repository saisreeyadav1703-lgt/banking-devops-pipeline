#!/bin/bash
# deploy.sh — Deployment automation script
# Usage: ./scripts/deploy.sh <image_tag> <environment>

set -euo pipefail

IMAGE_TAG="${1:-latest}"
ENVIRONMENT="${2:-staging}"
IMAGE_NAME="banking-app"
APP_PORT=8080
LOG_FILE="/var/log/banking-app/deployments.log"

mkdir -p "$(dirname $LOG_FILE)"

echo "=========================================="
echo " Deploying  : ${IMAGE_NAME}:${IMAGE_TAG}"
echo " Environment: ${ENVIRONMENT}"
echo " Timestamp  : $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="

if docker ps -a --format '{{.Names}}' | grep -q "^${IMAGE_NAME}$"; then
    echo "[INFO] Stopping existing container..."
    docker stop "${IMAGE_NAME}" && docker rm "${IMAGE_NAME}"
fi

echo "[INFO] Starting new container..."
docker run -d \
    --name "${IMAGE_NAME}" \
    --restart unless-stopped \
    -p "${APP_PORT}:${APP_PORT}" \
    -e APP_ENV="${ENVIRONMENT}" \
    -e APP_VERSION="${IMAGE_TAG}" \
    "${IMAGE_NAME}:${IMAGE_TAG}"

echo "[INFO] Running health check..."
sleep 5
for i in {1..10}; do
    if curl -sf "http://localhost:${APP_PORT}/health" > /dev/null; then
        echo "[OK] Health check passed on attempt ${i}"
        echo "${IMAGE_NAME}:${IMAGE_TAG} deployed to ${ENVIRONMENT} at $(date)" >> "${LOG_FILE}"
        exit 0
    fi
    echo "[WAIT] Attempt ${i}/10..."
    sleep 3
done

echo "[ERROR] Health check failed — rolling back"
docker stop "${IMAGE_NAME}" && docker rm "${IMAGE_NAME}"
exit 1
