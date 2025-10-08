#!/usr/bin/env bash
set -euo pipefail

usage() { cat <<'EOF'
Sequential Nomad allocation restarter (CLI-only; no HTTP API).

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

Requires: nomad CLI. curl is required only if --ready-http-url is used. jq is used only for optional debug output.
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
if [[ -n "$READY_HTTP_URL" ]]; then
  command -v curl >/dev/null || { echo "Error: curl not found (needed for --ready-http-url)"; exit 1; }
fi

# Namespace flag for CLI
NS_FLAG=()
[[ -n "$NS" ]] && NS_FLAG=( -namespace="$NS" )

now() { date +%s; }

http_ready() {
  [[ -z "$READY_HTTP_URL" ]] && return 0
  local code
  code=$(curl -fsS --max-time "$READY_HTTP_TIMEOUT" -o /dev/null -w '%{http_code}' "$READY_HTTP_URL" || true)
  [[ "$code" == "$READY_HTTP_CODE" ]]
}

# ---- Introspection via CLI templates (TSV) ----
# get_allocations: prints allocation IDs (one per line), filtered and sorted by CreateTime.
get_allocations() {
  # Fields: ID, DesiredStatus, ClientStatus, CreateTime
  local tmpl='{{range .Allocations}}{{.ID}}\t{{.DesiredStatus}}\t{{.ClientStatus}}\t{{.CreateTime}}{{"\n"}}{{end}}'
  local out
  if ! out=$(nomad job status "${NS_FLAG[@]}" -t "$tmpl" "$JOB" 2>/dev/null || true); then
    out=""
  fi
  # Filter run/running, sort by CreateTime numeric, print ID
  awk -F'\t' '$2=="run" && $3=="running" {print $0}' <<<"$out" | sort -n -k4 | awk -F'\t' '{print $1}'
}

# emit_task_states: prints TSV lines for tasks in an allocation:
# taskName \t State \t Healthy \t Failed
emit_task_states() {
  local alloc="$1"
  local tmpl='{{- range $k,$v := .TaskStates -}}{{$k}}{{"\t"}}{{$v.State}}{{"\t"}}{{if ne $v.Healthy nil}}{{$v.Healthy}}{{else}}NA{{end}}{{"\t"}}{{if ne $v.Failed nil}}{{$v.Failed}}{{else}}false{{end}}{{"\n"}}{{- end -}}'
  nomad alloc status "${NS_FLAG[@]}" -t "$tmpl" "$alloc" 2>/dev/null || true
}

task_exists_in_alloc() {
  local alloc="$1" task="$2"
  emit_task_states "$alloc" | awk -F'\t' -v t="$task" '$1==t{found=1} END{exit found?0:1}'
}

# readiness for a single task line (given columns)
_task_line_ready() {
  # args: state healthy failed
  local state="$1" healthy="$2" failed="$3"
  [[ "$state" == "running" ]] || return 1
  if $STRICT_HEALTH; then
    [[ "$failed" == "true" ]] && return 1
    [[ "$healthy" == "false" ]] && return 1
  fi
  return 0
}

# is_task_ready: check target task in alloc
is_task_ready() {
  local alloc="$1" task="$2"
  local line
  line=$(emit_task_states "$alloc" | awk -F'\t' -v t="$task" '$1==t{print; found=1} END{if(!found) exit 1}')
  [[ -z "${line:-}" ]] && return 1
  local state healthy failed
  state=$(awk -F'\t' '{print $2}' <<<"$line")
  healthy=$(awk -F'\t' '{print $3}' <<<"$line")
  failed=$(awk -F'\t' '{print $4}' <<<"$line")
  _task_line_ready "$state" "$healthy" "$failed" || return 1
  http_ready
}

# is_alloc_ready: ALL tasks in the allocation must be ready (state-only or strict-health); then optional HTTP probe
is_alloc_ready() {
  local alloc="$1"
  local ok=true
  while IFS=$'\t' read -r tname state healthy failed; do
    [[ -z "$tname" ]] && continue
    if ! _task_line_ready "$state" "$healthy" "$failed"; then
      ok=false; break
    fi
  done < <(emit_task_states "$alloc")
  $ok || return 1
  http_ready
}

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
      echo "❌ Timeout waiting for allocation $alloc task $task (state/health/http). Snapshot:"
      # Best-effort snapshot (human format)
      nomad alloc status "${NS_FLAG[@]}" "$alloc" || true
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
      echo "✅ Allocation $alloc is ready."
      return 0
    fi
    if (( $(now) - start_ts > TIMEOUT )); then
      echo "❌ Timeout waiting for allocation $alloc (state/health/http). Snapshot:"
      nomad alloc status "${NS_FLAG[@]}" "$alloc" || true
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

for alloc in "${allocs[@]}"; do
  restart_alloc_task "$alloc" "$TASK"
done

echo
echo "🎉 Done. Sequential restarts completed for job '$JOB'."
