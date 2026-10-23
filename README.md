# mac-spinner

<img src="assets/mac-spinner-icon.png" alt="mac-spinner icon" width="160">

[![CI](https://github.com/stephenlclarke/mac-spinner/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/stephenlclarke/mac-spinner/actions/workflows/ci.yml) [![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner) [![Coverage](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&metric=coverage)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner) [![Release](https://img.shields.io/github/v/release/stephenlclarke/mac-spinner)](https://github.com/stephenlclarke/mac-spinner/releases) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

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

`--spin-only` runs until interrupted. In a non-interactive output stream, the program prints one pending row and waits without emitting terminal control codes. Set `SCRIPT_COLOUR=off` to disable colour.

## Build and quality checks

Requires Swift 6.2 and macOS 13 or later.

```sh
make build
make test
make coverage
make leak-check
```

CI runs the tests with Swift coverage instrumentation and fails below 80% source line coverage. It also runs Apple's `leaks` tool against the live spinner process. SonarQube Cloud imports the same coverage report.

## License

MIT. See [LICENSE](LICENSE).
