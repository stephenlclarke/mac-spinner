# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Stephen Clarke <stephenlclarke@mac.com> - https://github.com/stephenlclarke/mac-spinner

# Build an optimised executable for local use and release validation.
.PHONY: build test coverage leak-check demo icon

# Compile the release configuration.
build:
	swift build -c release

# Run the Swift unit-test suite.
test:
	swift test

# Enforce coverage using unit tests plus instrumented CLI smoke runs.
coverage:
	swift test --enable-code-coverage
	./scripts/coverage-report.sh

# Build the release binary and check its live spinner process for leaks.
leak-check: build
	./scripts/check-leaks.sh .build/release/mac-spinner

# Regenerate the app icon from its maintained SVG source.
icon:
	./scripts/build-icon.sh

# Build the binary and record the terminal demonstration.
demo: build
	vhs demo/spinner.tape
