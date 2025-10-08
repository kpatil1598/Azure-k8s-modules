#!/usr/bin/env bash
set -euo pipefail

usage() { cat <<'EOF'
Sequential Nomad allocation restarter.

Usage:
  seq_nomad_restart.sh --job <JOB_ID> [--task <TASK_NAME>] [--ns <NAMESPACE>]
                       [--timeout 300] [--sleep 5]
                       [--wait-after 0]

Notes:
- Readiness = task state "running" (state-only).
- If you have sidecars with flaky states, prefer --task <MAIN_TASK_NAME> so readiness is gated only on that task.

Options:
  --job               Nomad job ID or unique prefix (required)
  --task              Restart only this task in each allocation (optional).
                      If omitted, the whole allocation is restarted and ALL tasks must be running to proceed.
  --ns                Nomad namespace (optional)
  --timeout           Seconds to wait for readiness (default: 300)
  --sleep             Seconds between status checks (default: 5)
  --wait-after        Seconds to pause after each allocation before restarting the next (default: 0)
EOF
}

# ---------- args ----------
JOB=""; TASK=""; NS=""; TIMEOUT=300; SLEEP=5
WAIT_AFTER=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --job) JOB="${2:-}"; shift 2 ;;
    --task) TASK="${2:-}"; shift 2 ;;
    --ns) NS="${2:-}"; shift 2 ;;
    --timeout) TIMEOUT="${2:-}"; shift 2 ;;
    --sleep) SLEEP="${2:-}"; shift 2 ;;
    --wait-after) WAIT_AFTER="${2:-0}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1"; usage; exit 1 ;;
  esac
done

[[ -z "$JOB" ]] && { echo "Error: --job is required"; usage; exit 1; }
command -v nomad >/dev/null || { echo "Error: nomad CLI not found"; exit 1; }

# Namespace flag for CLI
NS_FLAG=()
[[ -n "$NS" ]] && NS_FLAG=( -namespace="$NS" )

now() { date +%s; }

# ---- Parsers for old human-readable CLI output ----
# Parse Allocations table from `nomad job status` and emit allocation IDs with Desired=run and Status=running.
get_allocations() {
  local out
  out=$(nomad job status "${NS_FLAG[@]}" "$JOB" 2>/dev/null || true)
  [[ -z "$out" ]] && return 0

  awk '
    BEGIN { in_alloc=0 }
    /^Allocations/ { in_alloc=1; next }
    in_alloc && NF==0 { exit }
    in_alloc {
      if ($1=="ID" || $1 ~ /^-+$/) next
      # 1:ID  2:EvalID  3:NodeID  4:TaskGroup  5:Desired  6:Status
      id=$1; desired=$5; status=$6
      if (desired=="run" && status=="running") print id
    }
  ' <<<"$out"
}

# From `nomad alloc status <alloc>` parse "Task States" and print: task<TAB>state
emit_task_states() {
  local alloc="$1"
  local out
  out=$(nomad alloc status "${NS_FLAG[@]}" "$alloc" 2>/dev/null || true)
  [[ -z "$out" ]] && return 0

  awk '
    BEGIN { in_tasks=0 }
    /^Task States/ { in_tasks=1; header_seen=0; next }
    in_tasks && NF==0 { exit }
    in_tasks {
      if (!header_seen) { header_seen=1; next }  # skip column header row
      t=$1; s=$2
      if (t!="" && s!="") printf("%s\t%s\n", t, s)
    }
  ' <<<"$out"
}

task_exists_in_alloc() {
  local alloc="$1" task="$2"
  emit_task_states "$alloc" | awk -F'\t' -v t="$task" '$1==t{found=1} END{exit found?0:1}'
}

# Readiness checks (state-only)
is_task_ready() {
  local alloc="$1" task="$2"
  local line
  line=$(emit_task_states "$alloc" | awk -F'\t' -v t="$task" '$1==t{print; found=1} END{if(!found) exit 1}') || return 1
  local state
  state=$(awk -F'\t' '{print $2}' <<<"$line")
  [[ "$state" == "running" ]]
}

is_alloc_ready() {
  local alloc="$1"
  local ok=true
  while IFS=$'\t' read -r tname state; do
    [[ -z "$tname" ]] && continue
    if [[ "$state" != "running" ]]; then ok=false; break; fi
  done < <(emit_task_states "$alloc")
  $ok
}

# ---------- waiters ----------
wait_for_task() {
  local alloc="$1" task="$2"
  local start_ts; start_ts=$(now)
  while true; do
    if is_task_ready "$alloc" "$task"; then
      echo "Allocation $alloc task $task is ready."
      return 0
    fi
    if (( $(now) - start_ts > TIMEOUT )); then
      echo "Timeout waiting for allocation $alloc task $task."
      nomad alloc status "${NS_FLAG[@]}" "$alloc" || true
      return 1
    fi
    sleep "$SLEEP"
  done
}

wait_for_all_tasks_in_alloc() {
  local alloc="$1"
  local start_ts; start_ts=$(now)
  while true; do
    if is_alloc_ready "$alloc"; then
      echo "Allocation $alloc is ready."
      return 0
    fi
    if (( $(now) - start_ts > TIMEOUT )); then
      echo "Timeout waiting for allocation $alloc."
      nomad alloc status "${NS_FLAG[@]}" "$alloc" || true
      return 1
    fi
    sleep "$SLEEP"
  done
}

# ---------- restart ----------
restart_alloc_task() {
  local alloc="$1" task="$2"
  if [[ -n "$task" ]]; then
    if ! task_exists_in_alloc "$alloc" "$task"; then
      echo "Allocation $alloc does not contain task '$task' — skipping."
      return 0
    fi
    echo "Restarting allocation $alloc task '$task'…"
    nomad alloc restart "${NS_FLAG[@]}" -task "$task" "$alloc"
    wait_for_task "$alloc" "$task"
  else
    echo "Restarting entire allocation $alloc…"
    nomad alloc restart "${NS_FLAG[@]}" "$alloc"
    wait_for_all_tasks_in_alloc "$alloc"
  fi
}

# ---------- main ----------
echo "Job: $JOB"
[[ -n "$TASK" ]] && echo "Task: $TASK"
[[ -n "$NS" ]] && echo "Namespace: $NS"
echo "Timeout: ${TIMEOUT}s, Sleep: ${SLEEP}s, WaitAfter: ${WAIT_AFTER}s"
echo

mapfile -t allocs < <(get_allocations)
if [[ ${#allocs[@]} -eq 0 ]]; then
  echo "No running allocations found for job '$JOB'."
  echo "nomad job status ${NS:+-namespace=\"$NS\"} $JOB"
  exit 1
fi

echo "Found ${#allocs[@]} running allocation(s):"
printf ' - %s\n' "${allocs[@]}"; echo

for i in "${!allocs[@]}"; do
  alloc="${allocs[$i]}"
  restart_alloc_task "$alloc" "$TASK"

  # Pause after each allocation except the last
  if (( WAIT_AFTER > 0 )) && (( i < ${#allocs[@]} - 1 )); then
    echo "Waiting ${WAIT_AFTER}s before restarting next allocation..."
    sleep "$WAIT_AFTER"
  fi
done

echo
echo "Done. Sequential restarts completed for job '$JOB'."
