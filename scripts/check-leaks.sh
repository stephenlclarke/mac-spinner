#!/bin/bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Stephen Clarke <stephenlclarke@mac.com> - https://github.com/stephenlclarke/mac-spinner

set -euo pipefail

# Require one executable so the leak check targets the requested build artifact.
if [[ $# -ne 1 || ! -x "$1" ]]; then
  printf 'Usage: %s <mac-spinner-binary>\n' "$0" >&2
  exit 2
fi

binary="$1"
# Keep the spinner alive while leaks inspects the process's allocations.
"$binary" --message "Leak check" --spin-only >/dev/null 2>&1 &
spinner_pid=$!
# Stop and reap the background spinner when the check exits; this function takes no arguments.
cleanup() {
  # Stop and reap the background process even when the check exits early.
  kill -TERM "$spinner_pid" 2>/dev/null || true
  wait "$spinner_pid" 2>/dev/null || true
}
trap cleanup EXIT
# Allow startup allocations to settle before taking the leak snapshot.
sleep 1
leaks --quiet "$spinner_pid"
