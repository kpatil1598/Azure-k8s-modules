#!/usr/bin/env bash
set -euo pipefail

usage() { cat <<'EOF'
Sequential Nomad allocation restarter (one allocation at a time).

Usage:
  seq_nomad_restart.sh --job <JOB_ID> [--task <TASK_NAME>] [--ns <NAMESPACE>]
                       [--timeout 300] [--sleep 5] [--strict-health]
                       [--ready-http-url URL] [--ready-http-code 200] [--ready-http-timeout 5]

Options:
  --job              Nomad job ID or unique prefix (required)
  --task             Specific task (container) name to restart inside each allocation (optional).
                     If omitted, the whole allocation is restarted.
  --ns               Nomad namespace (optional)
  --timeout          Seconds to wait for readiness (default: 300)
  --sleep            Seconds between status checks (default: 5)
  --strict-health    Require Nomad health to pass (Healthy != false and Failed != true)
  --ready-http-url   HTTP URL to probe for readiness (optional). Example: http://127.0.0.1:11850/health
  --ready-http-code  Expected HTTP status code (default: 200)
  --ready-http-timeout Seconds per HTTP request (default: 5)

Requires: nomad CLI, jq. curl is required only if --ready-http-url is used.
EOF
}

# ---------- args ----------
JOB=""; TASK=""; NS=""; TIMEOUT=300; SLEEP=5; STRICT_HEALTH=false
READY_HTTP_URL=""; READY_HTTP_CODE="200"; READY_HTTP_TIMEOUT=5

while [[ $# -gt 0 ]]; do
  case "$1" in
    --job) JOB="${2:-}"; shift 2 ;;
    --task) TASK="${2:-}"; shift 2 ;;
    --ns) NS="${2:-}"; shift 2 ;;
    --timeout) TIMEOUT="${2:-}"; shift 2 ;;
    --sleep) SLEEP="${2:-}"; shift 2 ;;
    --strict-health) STRICT_HEALTH=true; shift 1 ;;
    --ready-http-url) READY_HTTP_URL="${2:-}"; shift 2 ;;
    --ready-http-code) READY_HTTP_CODE="${2:-}"; shift 2 ;;
    --ready-http-timeout) READY_HTTP_TIMEOUT="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1"; usage; exit 1 ;;
  esac
done

[[ -z "$JOB" ]] && { echo "Error: --job is required"; usage; exit 1; }
command -v nomad >/dev/null || { echo "Error: nomad CLI not found"; exit 1; }
command -v jq >/dev/null || { echo "Error: jq not found"; exit 1; }
if [[ -n "$READY_HTTP_URL" ]]; then
  command -v curl >/dev/null || { echo "Error: curl not found (needed for --ready-http-url)"; exit 1; }
fi

# Namespace flag for CLI (used by alloc restart)
NS_FLAG=()
[[ -n "$NS" ]] && NS_FLAG=( -namespace="$NS" )

# ---------- helpers ----------
now() { date +%s; }

api() {
  # Wrapper over Nomad HTTP API via CLI; respects NOMAD_ADDR/NOMAD_TOKEN
  # Usage: api /v1/path
  local path="$1"
  if [[ -n "$NS" ]]; then
    if [[ "$path" == *\?* ]]; then
      nomad operator api "${path}&namespace=${NS}"
    else
      nomad operator api "${path}?namespace=${NS}"
    fi
  else
    nomad operator api "$path"
  fi
}

get_allocations() {
  # Return running alloc IDs for the job, in creation order
  api "/v1/job/$JOB/allocations" \
  | jq -r 'sort_by(.CreateTime // 0) | .[] | select((.DesiredStatus=="run") and (.ClientStatus=="running")) | .ID'
}

task_exists_in_alloc() {
  local alloc="$1" task="$2"
  local js
  js=$(api "/v1/allocation/$alloc" || true)
  [[ -z "$js" ]] && return 1
  jq -e --arg t "$task" '.TaskStates | has($t)' >/dev/null <<<"$js"
}

http_ready() {
  # Uses global READY_HTTP_* vars; no-op if URL is empty
  [[ -z "$READY_HTTP_URL" ]] && return 0
  local code
  code=$(curl -fsS --max-time "$READY_HTTP_TIMEOUT" -o /dev/null -w '%{http_code}' "$READY_HTTP_URL" || true)
  [[ "$code" == "$READY_HTTP_CODE" ]]
}

# ---- Readiness checks ----
is_task_ready() {
  local alloc="$1" task="$2"
  local js state healthy failed
  js=$(api "/v1/allocation/$alloc" || true)
  [[ -z "$js" ]] && return 1

  state=$(jq -r --arg t "$task" '.TaskStates[$t].State // ""' <<<"$js")
  healthy=$(jq -r --arg t "$task" '.TaskStates[$t].Healthy // empty' <<<"$js")
  failed=$(jq -r --arg t "$task" '.TaskStates[$t].Failed // false' <<<"$js")

  # Always require state==running
  [[ "$state" == "running" ]] || return 1

  # If strict, require positive health
  if $STRICT_HEALTH; then
    [[ "$failed" == "true" ]] && return 1
    [[ "$healthy" == "false" ]] && return 1
  fi

  # Optional HTTP probe
  http_ready
}

is_alloc_ready() {
  local alloc="$1"
  local js
  js=$(api "/v1/allocation/$alloc" || true)
  [[ -z "$js" ]] && return 1

  if $STRICT_HEALTH; then
    jq -e '
      .TaskStates as $ts
      | [ keys[] as $k
          | ($ts[$k].State=="running")
            and (($ts[$k].Failed // false)==false)
            and (($ts[$k].Healthy // true)!=false)
        ] | all
    ' >/dev/null <<<"$js"
  else
    jq -e '
      .TaskStates as $ts
      | [ keys[] as $k | ($ts[$k].State=="running") ] | all
    ' >/dev/null <<<"$js"
  fi
}

# ---- Waiters ----
wait_for_task() {
  local alloc="$1" task="$2"
  local start_ts
  start_ts=$(now)

  while true; do
    if is_task_ready "$alloc" "$task"; then
      echo "✅ Allocation $alloc task $task is ready."
      return 0
    fi
    if (( $(now) - start_ts > TIMEOUT )); then
      echo "❌ Timeout waiting for allocation $alloc task $task (state/health/http)."
      api "/v1/allocation/$alloc" | jq '{ClientStatus, DesiredStatus, TaskStates}'
      return 1
    fi
    sleep "$SLEEP"
  done
}

wait_for_all_tasks_in_alloc() {
  local alloc="$1"
  local start_ts
  start_ts=$(now)

  while true; do
    if is_alloc_ready "$alloc"; then
      # Optional HTTP probe (if you want alloc-wide HTTP probe, reuse READY_HTTP_URL)
      if http_ready; then
        echo "✅ Allocation $alloc is ready."
        return 0
      fi
    fi
    if (( $(now) - start_ts > TIMEOUT )); then
      echo "❌ Timeout waiting for allocation $alloc (state/health/http)."
      api "/v1/allocation/$alloc" | jq '{ClientStatus, DesiredStatus, TaskStates}'
      return 1
    fi
    sleep "$SLEEP"
  done
}

restart_alloc_task() {
  local alloc="$1" task="$2"
  if [[ -n "$task" ]]; then
    if ! task_exists_in_alloc "$alloc" "$task"; then
      echo "⚠️  Allocation $alloc does not contain task '$task' — skipping."
      return 0
    fi
    echo "→ Restarting allocation $alloc task '$task'…"
    nomad alloc restart "${NS_FLAG[@]}" -task "$task" "$alloc"
    wait_for_task "$alloc" "$task"
  else
    echo "→ Restarting entire allocation $alloc…"
    nomad alloc restart "${NS_FLAG[@]}" "$alloc"
    wait_for_all_tasks_in_alloc "$alloc"
  fi
}

# ---------- main ----------
echo "Job: $JOB"
[[ -n "$TASK" ]] && echo "Task: $TASK"
[[ -n "$NS" ]] && echo "Namespace: $NS"
echo "Timeout: ${TIMEOUT}s, Sleep: ${SLEEP}s, StrictHealth: ${STRICT_HEALTH}"
[[ -n "$READY_HTTP_URL" ]] && echo "HTTP probe: ${READY_HTTP_URL} expect ${READY_HTTP_CODE} (timeout ${READY_HTTP_TIMEOUT}s)"
echo

mapfile -t allocs < <(get_allocations)
if [[ ${#allocs[@]} -eq 0 ]]; then
  echo "No running allocations found for job '$JOB'."
  exit 1
fi

echo "Found ${#allocs[@]} running allocation(s):"
printf ' - %s\n' "${allocs[@]}"; echo

# Safety: ensure at least 2 allocs if you're touching prod; comment out if not desired.
# if [[ ${#allocs[@]} -lt 2 ]]; then
#   echo "⚠️ Only ${#allocs[@]} allocation(s) found; consider ensuring redundancy before rolling restart."
# fi

for alloc in "${allocs[@]}"; do
  restart_alloc_task "$alloc" "$TASK"
done

echo
echo "🎉 Done. Sequential restarts completed for job '$JOB'."
