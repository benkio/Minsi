#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

validate_project() {
  local project_dir="$1"
  local project_name="$2"

  echo "Validating ${project_name}..."

  if [[ ! -d "${ROOT_DIR}/${project_dir}" ]]; then
    echo "Error: missing directory '${project_dir}'." >&2
    return 1
  fi

  if [[ ! -f "${ROOT_DIR}/${project_dir}/package.json" ]]; then
    echo "Error: missing package.json in '${project_dir}'." >&2
    return 1
  fi

  if [[ ! -f "${ROOT_DIR}/${project_dir}/spago.yaml" ]]; then
    echo "Error: missing spago.yaml in '${project_dir}'." >&2
    return 1
  fi

  (
    cd "${ROOT_DIR}/${project_dir}"
    npm run format:purs
    spago build
    spago test
  )
}

validate_project "backend" "Backend"
validate_project "shared" "Shared"
validate_project "frontend" "Frontend"

echo "All projects validated successfully."
