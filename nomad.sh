#!/usr/bin/env bash
set -euo pipefail

usage() { cat <<'EOF'
Restart containers of a Nomad job sequentially (one allocation at a time).

Usage:
  seq_nomad_restart.sh --job <JOB_ID> [--task <TASK_NAME>] [--ns <NAMESPACE>] [--timeout 300] [--sleep 5]

Options:
  --job       Nomad job ID or unique prefix (required)
  --task      Specific task (container) name to restart inside each allocation (optional).
              If omitted, the whole allocation is restarted.
  --ns        Nomad namespace (optional)
  --timeout   Seconds to wait for the task/allocation to return to "running/healthy" (default: 300)
  --sleep     Seconds between status checks (default: 5)

Requires: nomad CLI, jq
EOF
}

# ---------- args ----------
JOB=""; TASK=""; NS=""; TIMEOUT=300; SLEEP=5
while [[ $# -gt 0 ]]; do
  case "$1" in
    --job) JOB="${2:-}"; shift 2 ;;
    --task) TASK="${2:-}"; shift 2 ;;
    --ns) NS="${2:-}"; shift 2 ;;
    --timeout) TIMEOUT="${2:-}"; shift 2 ;;
    --sleep) SLEEP="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1"; usage; exit 1 ;;
  esac
done

[[ -z "$JOB" ]] && { echo "Error: --job is required"; usage; exit 1; }
command -v nomad >/dev/null || { echo "Error: nomad CLI not found"; exit 1; }
command -v jq >/dev/null || { echo "Error: jq not found"; exit 1; }

# Namespace flag for CLI (used by alloc restart)
NS_FLAG=()
[[ -n "$NS" ]] && NS_FLAG=( -namespace="$NS" )

# ---------- helpers ----------
now() { date +%s; }

api() {
  # Wrapper over Nomad HTTP API via CLI; respects NOMAD_ADDR/NOMAD_TOKEN
  # Usage: api /v1/path (namespace is appended when set)
  local path="$1"
  if [[ -n "$NS" ]]; then
    # Add ?namespace=... or &namespace=... depending on existing query
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
  # One-line jq to avoid multiline quoting problems
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

is_task_healthy() {
  local alloc="$1" task="$2"
  local js
  js=$(api "/v1/allocation/$alloc" || true)
  [[ -z "$js" ]] && return 1

  local state healthy failed
  state=$(jq -r --arg t "$task" '.TaskStates[$t].State // ""' <<<"$js")
  healthy=$(jq -r --arg t "$task" '.TaskStates[$t].Healthy // true' <<<"$js")
  failed=$(jq -r --arg t "$task" '.TaskStates[$t].Failed // false' <<<"$js")

  [[ "$state" == "running" && "$healthy" != "false" && "$failed" != "true" ]]
}

wait_for_task() {
  local alloc="$1" task="$2"
  local start_ts=$(now)
  while true; do
    if is_task_healthy "$alloc" "$task"; then
      echo "✅ Allocation $alloc task $task is running/healthy."
      return 0
    fi
    if (( $(now) - start_ts > TIMEOUT )); then
      echo "❌ Timeout waiting for allocation $alloc task $task to become healthy."
      return 1
    fi
    sleep "$SLEEP"
  done
}

wait_for_all_tasks_in_alloc() {
  local alloc="$1"
  local start_ts=$(now)

  while true; do
    local js
    js=$(api "/v1/allocation/$alloc" || true)
    [[ -z "$js" ]] && {
      if (( $(now) - start_ts > TIMEOUT )); then
        echo "❌ Timeout waiting for allocation $alloc to be queryable."
        return 1
      fi
      sleep "$SLEEP"; continue
    }

    local all_ok
    all_ok=$(jq -r '.TaskStates as $ts | [ keys[] as $k | ($ts[$k].State=="running") and (($ts[$k].Failed // false)==false) and (($ts[$k].Healthy // true)!=false) ] | all' <<<"$js")

    if [[ "$all_ok" == "true" ]]; then
      echo "✅ Allocation $alloc is running/healthy."
      return 0
    fi

    if (( $(now) - start_ts > TIMEOUT )); then
      echo "❌ Timeout waiting for allocation $alloc to become healthy."
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
echo "Timeout: ${TIMEOUT}s, Sleep: ${SLEEP}s"
echo

# Use mapfile to avoid word-splitting issues
mapfile -t allocs < <(get_allocations)

if [[ ${#allocs[@]} -eq 0 ]]; then
  echo "No running allocations found for job '$JOB'."
  exit 1
fi

echo "Found ${#allocs[@]} running allocation(s):"
printf ' - %s\n' "${allocs[@]}"; echo

for alloc in "${allocs[@]}"; do
  restart_alloc_task "$alloc" "$TASK"
done

echo
echo "🎉 Done. Sequential restarts completed for job '$JOB'."
