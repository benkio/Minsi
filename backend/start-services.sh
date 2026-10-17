#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

PUNCT_HOST="${MINSI_PUNCTUATION_HOST:-127.0.0.1}"
PUNCT_PORT="${MINSI_PUNCTUATION_PORT:-8090}"
PUNCT_APP_DIR="${MINSI_PUNCTUATION_APP_DIR:-${SCRIPT_DIR}/../punctuation-service}"
PUNCT_VENV_PYTHON="${PUNCT_APP_DIR}/.venv/bin/python"
PUNCT_PYTHON="${MINSI_PUNCTUATION_PYTHON:-}"
PUNCT_PID=""

resolve_punctuation_python() {
  if [[ -n "${PUNCT_PYTHON}" ]]; then
    echo "${PUNCT_PYTHON}"
  elif [[ -x "${PUNCT_VENV_PYTHON}" ]]; then
    # Prefer project-local venv when available.
    echo "${PUNCT_VENV_PYTHON}"
  else
    echo "python3"
  fi
}

start_punctuation_service() {
  local py
  py="$(resolve_punctuation_python)"

  if ! command -v "${py}" >/dev/null 2>&1 && [[ ! -x "${py}" ]]; then
    echo "[start-services] python runtime '${py}' not found, skipping punctuation service."
    return 0
  fi

  if ! "${py}" -c "import uvicorn" >/dev/null 2>&1; then
    echo "[start-services] uvicorn is not installed, skipping punctuation service."
    echo "[start-services] backend will continue; transcript restoration falls back to raw transcript."
    return 0
  fi

  if ! "${py}" -c "import punctuators" >/dev/null 2>&1; then
    echo "[start-services] python module 'punctuators' is not installed, skipping punctuation service."
    echo "[start-services] install with: cd ../punctuation-service && python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt"
    echo "[start-services] backend will continue; transcript restoration falls back to raw transcript."
    return 0
  fi

  if [[ ! -f "${PUNCT_APP_DIR}/app.py" ]]; then
    echo "[start-services] punctuation app not found at ${PUNCT_APP_DIR}/app.py, skipping punctuation service."
    echo "[start-services] backend will continue; transcript restoration falls back to raw transcript."
    return 0
  fi

  echo "[start-services] starting punctuation service on ${PUNCT_HOST}:${PUNCT_PORT}"
  "${py}" -m uvicorn app:app \
    --host "${PUNCT_HOST}" \
    --port "${PUNCT_PORT}" \
    --app-dir "${PUNCT_APP_DIR}" &
  PUNCT_PID=$!

  # Give uvicorn a moment to fail fast (bad imports/deps) and continue gracefully.
  sleep 1
  if ! kill -0 "${PUNCT_PID}" >/dev/null 2>&1; then
    echo "[start-services] punctuation service failed to start (check python deps in ${PUNCT_APP_DIR})."
    echo "[start-services] backend will continue; transcript restoration falls back to raw transcript."
    PUNCT_PID=""
  fi
}

cleanup() {
  echo "[start-services] shutting down services"
  if [[ -n "${PUNCT_PID}" ]] && kill -0 "${PUNCT_PID}" >/dev/null 2>&1; then
    kill "${PUNCT_PID}" || true
  fi
}
trap cleanup EXIT INT TERM

start_punctuation_service

echo "[start-services] starting minsi backend"
node run.js
