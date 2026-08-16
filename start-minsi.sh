#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Start Minsi with Docker and auto-export browser cookies.

Usage:
  ./start-minsi.sh [options]

Options:
  -o, --output <path>      Output cookies file path
                           (default: $HOME/.config/minsi/cookies.txt)
  -b, --browser <browser>  Browser source to try. Can be repeated.
                           Example: --browser chrome --browser firefox
  -u, --url <url>          URL used for a no-download probe
                           (default: https://www.youtube.com/watch?v=dQw4w9WgXcQ)
  --no-pull                Skip docker image pull
  --strict-cookies         Fail startup if cookies export fails
  --image <image>          Docker image to run (default: benkio/minsi:latest)
  --container <name>       Container name (default: minsi-app)
  --port <port>            Host port mapped to container 8080 (default: 8080)
  -h, --help               Show this help

Notes:
  - If no --browser is provided, this script tries:
    chrome, chromium, brave, firefox, edge, opera, vivaldi, safari
  - Cookies are exported on the host and mounted read-only when available.
EOF
}

OUTPUT_FILE="${HOME}/.config/minsi/cookies.txt"
TEST_URL="https://www.youtube.com/watch?v=dQw4w9WgXcQ"
NO_PULL=false
STRICT_COOKIES=false
IMAGE="benkio/minsi:latest"
CONTAINER_NAME="minsi-app"
HOST_PORT="8080"
declare -a BROWSERS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--output)
      OUTPUT_FILE="${2:?Missing output path}"
      shift 2
      ;;
    -b|--browser)
      BROWSERS+=("${2:?Missing browser value}")
      shift 2
      ;;
    -u|--url)
      TEST_URL="${2:?Missing url value}"
      shift 2
      ;;
    --no-pull)
      NO_PULL=true
      shift
      ;;
    --strict-cookies)
      STRICT_COOKIES=true
      shift
      ;;
    --image)
      IMAGE="${2:?Missing image value}"
      shift 2
      ;;
    --container)
      CONTAINER_NAME="${2:?Missing container name}"
      shift 2
      ;;
    --port)
      HOST_PORT="${2:?Missing port value}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo >&2
      usage >&2
      exit 1
      ;;
  esac
done

if ! command -v yt-dlp >/dev/null 2>&1; then
  echo "Error: yt-dlp not found in PATH." >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker not found in PATH." >&2
  exit 1
fi

if [[ ${#BROWSERS[@]} -eq 0 ]]; then
  BROWSERS=(chrome chromium brave firefox edge opera vivaldi safari)
fi

OUTPUT_DIR="$(dirname "$OUTPUT_FILE")"
TMP_FILE="${OUTPUT_FILE}.tmp"
mkdir -p "$OUTPUT_DIR"

cleanup() {
  rm -f "$TMP_FILE"
}
trap cleanup EXIT

cookie_exported=false
for browser in "${BROWSERS[@]}"; do
  echo "Trying browser cookies from: ${browser}"
  if yt-dlp \
    --cookies-from-browser "$browser" \
    --cookies "$TMP_FILE" \
    --skip-download \
    --no-warnings \
    "$TEST_URL" >/dev/null 2>&1; then
    if [[ -s "$TMP_FILE" ]]; then
      mv "$TMP_FILE" "$OUTPUT_FILE"
      chmod 600 "$OUTPUT_FILE"
      cookie_exported=true
      echo "Cookies exported successfully with browser source: ${browser}"
      echo "Saved to: ${OUTPUT_FILE}"
      break
    fi
  fi
done

if [[ "$cookie_exported" != true ]]; then
  message="Warning: failed to export cookies from browser sources: ${BROWSERS[*]}"
  if [[ "$STRICT_COOKIES" == true ]]; then
    echo "Error: ${message}" >&2
    exit 1
  fi
  echo "${message}" >&2
  echo "Continuing startup without refreshed cookies." >&2
fi

if [[ "$NO_PULL" != true ]]; then
  echo "Pulling latest image..."
  docker pull "$IMAGE"
fi

echo "Recreating container: ${CONTAINER_NAME}"
docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true

echo "Starting Minsi with Docker..."
DOCKER_ARGS=( -d --name "${CONTAINER_NAME}" -p "${HOST_PORT}:8080" )

if [[ -s "$OUTPUT_FILE" ]]; then
  DOCKER_ARGS+=( -v "${OUTPUT_FILE}:/run/secrets/minsi-cookies.txt:ro" )
  DOCKER_ARGS+=( -e "YTDLP_COOKIES_FILE=/run/secrets/minsi-cookies.txt" )
else
  echo "Warning: cookies file not found or empty, starting without YTDLP_COOKIES_FILE." >&2
fi

docker run "${DOCKER_ARGS[@]}" "$IMAGE"

echo "Minsi is up at http://localhost:${HOST_PORT}"
echo "Useful commands:"
echo "  docker logs -f ${CONTAINER_NAME}"
echo "  docker stop ${CONTAINER_NAME}"
echo "  docker rm ${CONTAINER_NAME}"
