#!/bin/bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Stephen Clarke <stephenlclarke@mac.com> - https://github.com/stephenlclarke/mac-spinner

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

PROFILE_DIR="$ROOT_DIR/.build/coverage"
mkdir -p "$PROFILE_DIR"
rm -f "$PROFILE_DIR"/*.profraw

swift build --enable-code-coverage --product mac-spinner

CLI_BINARY="$ROOT_DIR/.build/debug/mac-spinner"
OUTPUT_FILE="$PROFILE_DIR/command-output.log"
LLVM_PROFILE_FILE="$PROFILE_DIR/cli-%p.profraw" "$CLI_BINARY" --help >/dev/null
LLVM_PROFILE_FILE="$PROFILE_DIR/cli-%p.profraw" "$CLI_BINARY" --message coverage --pending >/dev/null
LLVM_PROFILE_FILE="$PROFILE_DIR/cli-%p.profraw" "$CLI_BINARY" --message coverage --done >/dev/null
LLVM_PROFILE_FILE="$PROFILE_DIR/cli-%p.profraw" "$CLI_BINARY" --message coverage --output "$OUTPUT_FILE" -- /usr/bin/true

set +e
LLVM_PROFILE_FILE="$PROFILE_DIR/cli-%p.profraw" "$CLI_BINARY" --message "" --pending >/dev/null 2>&1
CLI_ERROR_STATUS=$?
set -e
if [[ "$CLI_ERROR_STATUS" -ne 2 ]]; then
  printf 'Expected invalid CLI invocation to exit with status 2; got %s.\n' "$CLI_ERROR_STATUS" >&2
  exit 1
fi

LLVM_PROFILE_FILE="$PROFILE_DIR/spin-%p.profraw" "$CLI_BINARY" --message coverage --spin-only >/dev/null &
SPIN_PID=$!
sleep 0.2
kill -TERM "$SPIN_PID"
wait "$SPIN_PID"

LLVM_PROFILE_FILE="$PROFILE_DIR/tty-%p.profraw" python3 - "$CLI_BINARY" <<'PY'
import os
import pty
import signal
import subprocess
import sys
import time

master, slave = pty.openpty()
process = subprocess.Popen(
    [sys.argv[1], "--message", "coverage", "--spin-only"],
    stdin=slave,
    stdout=slave,
    stderr=slave,
    env=os.environ.copy(),
)
os.close(slave)
time.sleep(0.2)
process.send_signal(signal.SIGTERM)
status = process.wait(timeout=5)
os.close(master)
if status != 0:
    raise SystemExit(f"Interactive spinner exited with status {status}.")
PY

TEST_BUNDLE="$(find "$ROOT_DIR/.build" -type d -name '*.xctest' -print -quit)"
TEST_BINARY="$(find "$TEST_BUNDLE/Contents/MacOS" -type f ! -path '*.dSYM/*' -print -quit)"
TEST_PROFILE="$(find "$ROOT_DIR/.build" -type f -name default.profdata -print -quit)"
if [[ -z "$TEST_BUNDLE" || -z "$TEST_BINARY" || -z "$TEST_PROFILE" || ! -x "$CLI_BINARY" ]]; then
  printf 'Coverage binaries or test profile not found. Run swift test --enable-code-coverage first.\n' >&2
  exit 1
fi

xcrun llvm-profdata merge -sparse "$TEST_PROFILE" "$PROFILE_DIR"/*.profraw -o "$PROFILE_DIR/merged.profdata"
xcrun llvm-cov export -format=lcov -instr-profile "$PROFILE_DIR/merged.profdata" "$TEST_BINARY" -object "$CLI_BINARY" > coverage.lcov
python3 - <<'PY'
import pathlib
import sys
import xml.etree.ElementTree as ET

root = pathlib.Path.cwd()
coverage = ET.Element("coverage", version="1")
source_file = None
covered = 0
total = 0
with (root / "coverage.lcov").open(encoding="utf-8") as report:
    for line in report:
        line = line.rstrip("\n")
        if line.startswith("SF:"):
            path = pathlib.Path(line[3:]).resolve()
            try:
                relative = path.relative_to(root)
            except ValueError:
                source_file = None
                continue
            if not str(relative).startswith("Sources/"):
                source_file = None
                continue
            source_file = ET.SubElement(coverage, "file", path=str(relative))
        elif line.startswith("DA:") and source_file is not None:
            line_number, hits = line[3:].split(",", 1)
            is_covered = int(hits) > 0
            ET.SubElement(source_file, "lineToCover", lineNumber=line_number, covered=str(is_covered).lower())
            total += 1
            covered += is_covered

if total == 0:
    print("No source lines found in coverage report.", file=sys.stderr)
    sys.exit(1)
ET.indent(coverage)
ET.ElementTree(coverage).write(root / "coverage.xml", encoding="utf-8", xml_declaration=True)
percentage = covered * 100 / total
print(f"Source line coverage: {covered}/{total} ({percentage:.2f}%)")
if percentage < 80:
    print("Coverage is below the required 80%.", file=sys.stderr)
    sys.exit(1)
PY
