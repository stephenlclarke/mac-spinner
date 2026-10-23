#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

TEST_BUNDLE="$(find .build -type d -name '*.xctest' -print -quit)"
TEST_BINARY="$(find "$TEST_BUNDLE/Contents/MacOS" -type f ! -path '*.dSYM/*' -print -quit)"
PROFILE="$(find .build -name default.profdata -type f -print -quit)"
if [[ -z "$TEST_BUNDLE" || -z "$TEST_BINARY" || -z "$PROFILE" ]]; then
  printf 'Coverage data not found. Run swift test --enable-code-coverage first.\n' >&2
  exit 1
fi

xcrun llvm-cov export -format=lcov -instr-profile "$PROFILE" "$TEST_BINARY" > coverage.lcov
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
