#!/bin/bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Stephen Clarke <stephenlclarke@mac.com> - https://github.com/stephenlclarke/mac-spinner

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

PROFILE_DIR="$ROOT_DIR/.build/coverage"
# Keep transient profiles and command output under SwiftPM's ignored build directory.
mkdir -p "$PROFILE_DIR"
rm -f "$PROFILE_DIR"/*.profraw

# Build the executable with instrumentation so its CLI paths join unit-test coverage.
swift build --enable-code-coverage --product mac-spinner

CLI_BINARY="$ROOT_DIR/.build/debug/mac-spinner"
OUTPUT_FILE="$PROFILE_DIR/command-output.log"
# Exercise help, each short status mode, and a successful command invocation.
LLVM_PROFILE_FILE="$PROFILE_DIR/cli-%p.profraw" "$CLI_BINARY" --help >/dev/null
LLVM_PROFILE_FILE="$PROFILE_DIR/cli-%p.profraw" "$CLI_BINARY" --message coverage --pending >/dev/null
LLVM_PROFILE_FILE="$PROFILE_DIR/cli-%p.profraw" "$CLI_BINARY" --message coverage --done >/dev/null
LLVM_PROFILE_FILE="$PROFILE_DIR/cli-%p.profraw" "$CLI_BINARY" --message coverage --output "$OUTPUT_FILE" -- /usr/bin/true

# A malformed invocation must reach the CLI error handler and return status 2.
set +e
LLVM_PROFILE_FILE="$PROFILE_DIR/cli-%p.profraw" "$CLI_BINARY" --message "" --pending >/dev/null 2>&1
CLI_ERROR_STATUS=$?
set -e
if [[ "$CLI_ERROR_STATUS" -ne 2 ]]; then
  printf 'Expected invalid CLI invocation to exit with status 2; got %s.\n' "$CLI_ERROR_STATUS" >&2
  exit 1
fi

# Exercise the redirected-output wait loop and its signal-based shutdown path.
LLVM_PROFILE_FILE="$PROFILE_DIR/spin-%p.profraw" "$CLI_BINARY" --message coverage --spin-only >/dev/null &
SPIN_PID=$!
sleep 0.2
kill -TERM "$SPIN_PID"
wait "$SPIN_PID"

# Use a pseudo-terminal to cover cursor control and interactive frame redraws.
LLVM_PROFILE_FILE="$PROFILE_DIR/tty-%p.profraw" python3 - "$CLI_BINARY" <<'PY'
import os
import pty
import signal
import subprocess
import sys
import time

master, slave = pty.openpty()
# Attach all three child streams to the pseudo-terminal to exercise TTY rendering.
process = subprocess.Popen(
    [sys.argv[1], "--message", "coverage", "--spin-only"],
    stdin=slave,
    stdout=slave,
    stderr=slave,
    env=os.environ.copy(),
)
# Close the parent's slave descriptor so child shutdown releases the terminal cleanly.
os.close(slave)
# Let the child render frames before sending its supported termination signal.
time.sleep(0.2)
process.send_signal(signal.SIGTERM)
status = process.wait(timeout=5)
# Close the remaining terminal descriptor after confirming the child has exited.
os.close(master)
if status != 0:
    raise SystemExit(f"Interactive spinner exited with status {status}.")
PY

# Locate SwiftPM's unit-test bundle and its merged profile before combining coverage.
TEST_BUNDLE="$(find "$ROOT_DIR/.build" -type d -name '*.xctest' -print -quit)"
TEST_PROFILE="$(find "$ROOT_DIR/.build" -type f -name default.profdata -print -quit)"
if [[ -z "$TEST_BUNDLE" || -z "$TEST_PROFILE" || ! -x "$CLI_BINARY" ]]; then
  printf 'Coverage binaries or test profile not found. Run swift test --enable-code-coverage first.\n' >&2
  exit 1
fi

# Find the XCTest executable only after confirming that SwiftPM produced a test bundle.
TEST_BINARY="$(find "$TEST_BUNDLE/Contents/MacOS" -type f ! -path '*.dSYM/*' -print -quit)"
if [[ -z "$TEST_BINARY" ]]; then
  printf 'Coverage binaries or test profile not found. Run swift test --enable-code-coverage first.\n' >&2
  exit 1
fi

# Merge XCTest data with CLI smoke-run profiles, then export one Sonar-compatible report.
xcrun llvm-profdata merge -sparse "$TEST_PROFILE" "$PROFILE_DIR"/*.profraw -o "$PROFILE_DIR/merged.profdata"
xcrun llvm-cov export -format=lcov -instr-profile "$PROFILE_DIR/merged.profdata" "$TEST_BINARY" -object "$CLI_BINARY" > coverage.lcov
python3 - <<'PY'
import pathlib
import sys
import xml.etree.ElementTree as ET

# Convert LCOV line records into SonarQube's generic coverage XML format.
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
# Enforce the repository's minimum line-coverage target on maintained source files.
percentage = covered * 100 / total
print(f"Source line coverage: {covered}/{total} ({percentage:.2f}%)")
if percentage < 80:
    print("Coverage is below the required 80%.", file=sys.stderr)
    sys.exit(1)
PY
