#!/bin/bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Stephen Clarke <stephenlclarke@mac.com> - https://github.com/stephenlclarke/mac-spinner

set -euo pipefail

if [[ $# -ne 1 || ! -x "$1" ]]; then
  printf 'Usage: %s <mac-spinner-binary>\n' "$0" >&2
  exit 2
fi

binary="$1"
"$binary" --message "Leak check" --spin-only >/dev/null 2>&1 &
spinner_pid=$!
cleanup() {
  kill -TERM "$spinner_pid" 2>/dev/null || true
  wait "$spinner_pid" 2>/dev/null || true
}
trap cleanup EXIT
sleep 1
leaks --quiet "$spinner_pid"
