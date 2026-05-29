#!/usr/bin/env bash
set -euo pipefail

PI_REAL_BIN="__PI_REAL_BIN__"

resolve_project_root() {
  if command -v git >/dev/null 2>&1; then
    local git_root
    git_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
    if [ -n "$git_root" ] && [ -d "$git_root" ]; then
      printf '%s\n' "$git_root"
      return 0
    fi
  fi

  pwd -P
}

PROJECT_ROOT="$(resolve_project_root)"
export XDG_DATA_HOME="${PROJECT_ROOT}/.eurecat-data"

exec "$PI_REAL_BIN" "$@"
