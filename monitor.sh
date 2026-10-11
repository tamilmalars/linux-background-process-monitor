
#!/usr/bin/env bash

set -u

# Linux Background Process Monitor
# Alerts only when a watched process instance first appears.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WATCHLIST="$SCRIPT_DIR/watchlist.txt"
LOG_FILE="$SCRIPT_DIR/monitor.log"
STATE_FILE="$SCRIPT_DIR/.previous_processes"

if [[ ! -f "$WATCHLIST" ]]; then
    echo "ERROR: Watchlist not found: $WATCHLIST" >&2
    exit 1
fi

# Create a temporary file for the current process list.
CURRENT_FILE="$(mktemp "$SCRIPT_DIR/.current.XXXXXX")"
trap 'rm -f "$CURRENT_FILE"' EXIT

timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
alerts=0

# Record currently running watched processes as process-name + PID.
while IFS= read -r process_name || [[ -n "$process_name" ]]; do
    [[ -z "$process_name" || "$process_name" == \#* ]] && continue

    while IFS= read -r pid; do
        [[ -z "$pid" ]] && continue
        printf '%s %s\n' "$process_name" "$pid" >> "$CURRENT_FILE"
    done < <(pgrep -x -- "$process_name" || true)
done < "$WATCHLIST"

# Alert only for process instances absent from the previous check.
while IFS= read -r process_entry; do
    [[ -z "$process_entry" ]] && continue

    if ! grep -Fqx -- "$process_entry" "$STATE_FILE" 2>/dev/null; then
        process_name="${process_entry% *}"
        pid="${process_entry##* }"
        message="ALERT: Watched process '$process_name' started or detected (PID: $pid) at $timestamp"
        printf '%s\n' "$message"
        printf '%s\n' "$message" >> "$LOG_FILE"
        alerts=$((alerts + 1))
    fi
done < "$CURRENT_FILE"

# Save current processes so the next check can compare them.
cp "$CURRENT_FILE" "$STATE_FILE"

if (( alerts == 0 )); then
    message="[$timestamp] Check complete: no new watched process instances detected."
    printf '%s\n' "$message"
    printf '%s\n' "$message" >> "$LOG_FILE"
fi
