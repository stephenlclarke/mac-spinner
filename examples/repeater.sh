#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Stephen Clarke <stephenlclarke@mac.com> - https://github.com/stephenlclarke/mac-spinner
# USAGE: repeater.sh [-p|--pause INTERVAL] [--] COMMAND [ARG...]
# Run a command immediately, then repeat it until interrupted with Ctrl+C.

set -uo pipefail

readonly SELF_PATH="${BASH_SOURCE[0]:-$0}"
SCRIPT_NAME="$(basename "$SELF_PATH")"
readonly SCRIPT_NAME
SPINNER_PID=""
USE_TERMINAL=false
CURSOR_HIDDEN=false
FIRST_WAIT=true

# Print command usage.
usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [-p|--pause INTERVAL] [--] COMMAND [ARG...]

Run COMMAND immediately, wait, then repeat until Ctrl+C.
The default pause is 5 seconds. On a terminal, each repeat clears the
display below the command's original cursor position before running it.

INTERVAL is a positive whole number followed by s, sec, m, min, h, or hour.
A number without a suffix is in seconds.

Options:
  -p, --pause INTERVAL  Set the pause between runs (default: 5 seconds)
  --                    End option parsing
  -h, --help            Show this help

Example:
  $SCRIPT_NAME --pause 10min docker ps
EOF
}

# Print an error message to stderr.
error() {
  printf '%s: %s\n' "$SCRIPT_NAME" "$1" >&2
}

# Stop the optional countdown spinner if it is running.
stop_spinner() {
  if [[ -n "$SPINNER_PID" ]]; then
    kill -TERM "$SPINNER_PID" 2>/dev/null || true
    wait "$SPINNER_PID" 2>/dev/null || true
    SPINNER_PID=""
  fi
}

# Restore the terminal cursor if this script hid it for the spinner.
show_terminal_cursor() {
  if [[ "$CURSOR_HIDDEN" == true ]]; then
    printf '\033[?25h'
    CURSOR_HIDDEN=false
  fi
}

# Stop the spinner and exit when the user interrupts the loop.
handle_interrupt() {
  stop_spinner
  show_terminal_cursor
  if [[ "$USE_TERMINAL" == true ]]; then
    printf '\n'
  fi
  exit 130
}

# Locate mac-spinner beside this script first, then through PATH.
find_spinner() {
  local script_dir
  script_dir="$(cd -- "$(dirname -- "$SELF_PATH")" && pwd)"

  if [[ -x "${script_dir}/mac-spinner" ]]; then
    printf '%s\n' "${script_dir}/mac-spinner"
  elif command -v mac-spinner >/dev/null 2>&1; then
    command -v mac-spinner
  fi
}

# Wait for the next run and show a spinner on an interactive terminal when available.
wait_for_next_run() {
  local seconds="$1"
  local spinner_path="$2"
  local spinner_message="Waiting to rerun command - press any key to quit"
  local key_pressed=false

  if [[ "$USE_TERMINAL" == true && -n "$spinner_path" ]]; then
    if [[ "$FIRST_WAIT" == true ]]; then
      printf '\n%s\033[J\r' "$spinner_message"
      FIRST_WAIT=false
    else
      printf '\n%s\r' "$spinner_message"
    fi

    printf '\033[?25l'
    CURSOR_HIDDEN=true
    "$spinner_path" --message "$spinner_message" --spin-only &
    SPINNER_PID=$!

    if [[ -t 0 ]]; then
      if IFS= read -r -n 1 -t "$seconds"; then
        key_pressed=true
      fi
    else
      sleep "$seconds"
    fi

    stop_spinner
    show_terminal_cursor

    if [[ "$key_pressed" == true ]]; then
      printf '\r\033[K'
      printf '\n'
      return 1
    fi
  else
    sleep "$seconds"
  fi

  return 0
}

# Convert a whole-number interval to seconds.
interval_to_seconds() {
  local interval="$1"
  local value unit

  if [[ ! "$interval" =~ ^([1-9][0-9]*)(s|sec|m|min|h|hour)?$ ]]; then
    return 1
  fi

  value="${BASH_REMATCH[1]}"
  unit="${BASH_REMATCH[2]:-s}"

  case "$unit" in
    s|sec) printf '%s\n' "$value" ;;
    m|min) printf '%s\n' "$((value * 60))" ;;
    h|hour) printf '%s\n' "$((value * 3600))" ;;
  esac
}

# Run the command repeatedly, refreshing the terminal area below its start.
main() {
  local pause=5 pause_seconds command_status spinner_path

  while (( $# > 0 )); do
    case "$1" in
      -p|--pause)
        if (( $# < 2 )); then
          error "-p/--pause requires an interval"
          usage >&2
          return 2
        fi
        pause=$2
        shift 2
        ;;
      --)
        shift
        break
        ;;
      -h|--help)
        usage
        return 0
        ;;
      -*)
        error "unknown option: $1"
        usage >&2
        return 2
        ;;
      *)
        break
        ;;
    esac
  done

  if ! pause_seconds=$(interval_to_seconds "$pause"); then
    error "invalid interval '$pause'"
    usage >&2
    return 2
  fi

  if (( $# == 0 )); then
    error "a command is required"
    usage >&2
    return 2
  fi

  if [[ -t 1 ]]; then
    USE_TERMINAL=true
    printf '\033[s'
  fi

  spinner_path="$(find_spinner || true)"
  trap handle_interrupt INT

  while :; do
    if "$@"; then
      :
    else
      command_status=$?
      error "command exited with status $command_status; continuing"
    fi

    if ! wait_for_next_run "$pause_seconds" "$spinner_path"; then
      return 0
    fi

    if [[ "$USE_TERMINAL" == true ]]; then
      printf '\033[u\033[J\033[u'
    fi
  done
}

main "$@"
