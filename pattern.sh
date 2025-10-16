#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  remote_find_keystore.sh --host <HOST> --container <NAME_PATTERN>

What it does (on the remote host, as root):
  1) sudo bash
  2) find the container ID matching <NAME_PATTERN>
  3) docker exec into it and run:
       cd / && find . | grep client-keystore
  4) prints matches (paths) to stdout

Notes:
- <NAME_PATTERN> can be a substring of the container name shown by `docker ps`.
- If multiple containers match, it uses the first match. See comments for exact match.
EOF
}

HOST=""; CONTAINER_NAME=""

# ---- args ----
while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)      HOST="${2:-}"; shift 2;;
    --container) CONTAINER_NAME="${2:-}"; shift 2;;
    -h|--help)   usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done

[[ -z "$HOST" || -z "$CONTAINER_NAME" ]] && { usage; exit 1; }

# Force TTY in case sudo needs it
ssh -tt "$HOST" "sudo bash -s -- $(printf %q "$CONTAINER_NAME")" <<'REMOTE'
set -euo pipefail
NAME_PATTERN="$1"

echo "Searching for container matching: ${NAME_PATTERN}" >&2

# Get first matching container by name (substring match).
# For exact match, change: '$2 ~ n'  ->  '$2 == n'
cid="$(docker ps --format '{{.ID}} {{.Names}}' | awk -v n="$NAME_PATTERN" '$2 ~ n {print $1; exit}')"

if [[ -z "${cid:-}" ]]; then
  echo "ERROR: No running container matches: $NAME_PATTERN" >&2
  exit 1
fi

echo "Using container ID: $cid" >&2

# Run inside the container
docker exec -i "$cid" bash -lc 'cd / && find . | grep "client-keystore"' \
  | sed 's#^\./##'
REMOTE
