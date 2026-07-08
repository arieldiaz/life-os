# gate: shared "is now a good time for heavy work?" check for ops jobs.
# Heavy jobs (sync, transcribe, backup) call `defer_if_busy <job>` right after
# loading config; if the machine is busy the job logs one line and exits 0 —
# the work simply happens on a later launchd tick. Interactive performance
# always wins; nothing is lost by waiting.
#
# Tunables (override in stream-paths.env; defaults are safe on any machine):
#   PERF_GATE_APPS       space-separated process names that block heavy work
#                        (default "OBS"). Set to "" to disable.
#   PERF_IDLE_SECS       user must be idle this many seconds before heavy work
#                        runs (default 300). 0 disables the idle gate. On a
#                        headless machine idle is effectively infinite, so
#                        this gate only bites where someone is typing.
#   PERF_GATE_ON_BATTERY defer heavy work on battery power (default 1).
#   PERF_GATE_DISPLAY    also defer while any app holds a display-sleep
#                        assertion — video calls, playing media (default 0;
#                        aggressive, catches more than it should).

_gate_reason() {
  local app
  for app in ${PERF_GATE_APPS-OBS}; do
    if pgrep -x "$app" >/dev/null 2>&1; then
      echo "$app running"
      return 0
    fi
  done

  local need="${PERF_IDLE_SECS:-300}"
  if [ "$need" -gt 0 ]; then
    local idle
    idle="$(ioreg -c IOHIDSystem 2>/dev/null | awk '/HIDIdleTime/ {print int($NF/1000000000); exit}')"
    if [ -n "$idle" ] && [ "$idle" -lt "$need" ]; then
      echo "user active (idle ${idle}s < ${need}s)"
      return 0
    fi
  fi

  if [ "${PERF_GATE_ON_BATTERY:-1}" = "1" ] && pmset -g batt 2>/dev/null | grep -q "Battery Power"; then
    echo "on battery"
    return 0
  fi

  if [ "${PERF_GATE_DISPLAY:-0}" = "1" ] && pmset -g assertions 2>/dev/null | grep -Eq "PreventUserIdleDisplaySleep[[:space:]]+1"; then
    echo "display held awake (call or media)"
    return 0
  fi

  return 1
}

defer_if_busy() {
  local job="${1:-job}" reason
  if reason="$(_gate_reason)"; then
    echo "$(date '+%F %T') $job deferred: $reason"
    exit 0
  fi
}
