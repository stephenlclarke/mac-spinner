# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Stephen Clarke

.PHONY: build test coverage leak-check demo icon

build:
	swift build -c release

test:
	swift test

coverage:
	swift test --enable-code-coverage
	./scripts/coverage-report.sh

leak-check: build
	./scripts/check-leaks.sh .build/release/mac-spinner

icon:
	./scripts/build-icon.sh

demo: build
	vhs demo/spinner.tape
