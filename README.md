# mac-spinner

<img src="assets/mac-spinner-icon.png" alt="mac-spinner icon" width="160">

[![CI](https://github.com/stephenlclarke/mac-spinner/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/stephenlclarke/mac-spinner/actions/workflows/ci.yml)
[![CodeQL](https://github.com/stephenlclarke/mac-spinner/actions/workflows/codeql.yml/badge.svg?branch=main)](https://github.com/stephenlclarke/mac-spinner/actions/workflows/codeql.yml)
[![Release](https://img.shields.io/github/v/release/stephenlclarke/mac-spinner)](https://github.com/stephenlclarke/mac-spinner/releases)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner)
[![Bugs](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&metric=bugs)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner)
[![Code Smells](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&metric=code_smells)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&metric=coverage)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner)
[![Duplicated Lines (%)](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&metric=duplicated_lines_density)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner)
[![Lines of Code](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&metric=ncloc)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner)
[![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&metric=reliability_rating)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&metric=security_rating)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner)
[![Technical Debt](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&metric=sqale_index)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&metric=sqale_rating)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner)
[![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&metric=vulnerabilities)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner)
[![Security Hotspots Reviewed](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&metric=security_hotspots_reviewed)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner)
[![License: MIT](https://img.shields.io/badge/MIT-License%20%E2%9A%96-blue.svg)](LICENSE)

A small native macOS spinner for shell scripts. It keeps the spinner in a separate process, so the command output can be captured without disturbing the animation.

![mac-spinner demo](demo/spinner.gif)

## Install

```sh
brew install stephenlclarke/tap/mac-spinner
```

Homebrew downloads the prebuilt release binary for Apple Silicon or Intel Macs.

## Use

```sh
mac-spinner --message "Waiting for jobs" --spin-only
```

Print a pending or completed status row:

```sh
mac-spinner --message "Building" --pending
mac-spinner --message "Build complete" --done
```

Run a command and direct its combined standard output and error to a file:

```sh
mac-spinner --message "Running checks" --output /tmp/checks.log -- make check
```

The [repeater.sh example](examples/repeater.sh) reruns a command on an interval and uses mac-spinner for its interactive countdown. It accepts a command and its arguments without requiring shell quoting:

```sh
./examples/repeater.sh -p 10 -- docker ps
```

`--spin-only` runs until interrupted. In a non-interactive output stream, the program prints one pending row and waits without emitting terminal control codes. Set `SCRIPT_COLOUR=off` to disable colour.

## Build and quality checks

Requires Swift 6.0 and macOS 13 or later.

```sh
make build
make test
make coverage
make leak-check
```

CI runs the tests with Swift coverage instrumentation and fails below 80% source line coverage. It also runs Apple's `leaks` tool against the live spinner process. SonarQube Cloud imports the same coverage report. Regenerate the app icon with `make icon` and the 80-column VHS demo with `make demo`.

## License

MIT. See [LICENSE](LICENSE).
