# mac-spinner

<!-- markdownlint-disable MD033 -->
<p>
  <img align="left" hspace="20" src="assets/mac-spinner-icon.png" width="147" alt="mac-spinner application icon" />
  <a href="https://github.com/stephenlclarke/mac-spinner/actions/workflows/ci.yml"><img alt="CI" src="https://github.com/stephenlclarke/mac-spinner/actions/workflows/ci.yml/badge.svg?branch=main" /></a>
  <a href="https://github.com/stephenlclarke/mac-spinner/actions/workflows/codeql.yml"><img alt="CodeQL" src="https://github.com/stephenlclarke/mac-spinner/actions/workflows/codeql.yml/badge.svg?branch=main" /></a>
  <a href="https://github.com/stephenlclarke/mac-spinner/releases"><img alt="Release" src="https://img.shields.io/github/v/release/stephenlclarke/mac-spinner" /></a>
  <a href="https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner"><img alt="Quality Gate Status" src="https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&amp;metric=alert_status" /></a>
  <a href="https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner"><img alt="Bugs" src="https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&amp;metric=bugs" /></a>
  <a href="https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner"><img alt="Maintainability Issues" src="https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&amp;metric=software_quality_maintainability_issues" /></a>
  <a href="https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner"><img alt="Reliability Issues" src="https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&amp;metric=software_quality_reliability_issues" /></a>
  <a href="https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner"><img alt="Security Issues" src="https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&amp;metric=software_quality_security_issues" /></a>
  <a href="https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner"><img alt="Code Smells" src="https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&amp;metric=code_smells" /></a>
  <a href="https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner"><img alt="Coverage" src="https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&amp;metric=coverage" /></a>
  <a href="https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner"><img alt="Duplicated Lines (%)" src="https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&amp;metric=duplicated_lines_density" /></a>
  <a href="https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner"><img alt="Lines of Code" src="https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&amp;metric=ncloc" /></a>
  <a href="https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner"><img alt="Reliability Rating" src="https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&amp;metric=reliability_rating" /></a>
  <a href="https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner"><img alt="Security Rating" src="https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&amp;metric=security_rating" /></a>
  <a href="https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner"><img alt="Technical Debt" src="https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&amp;metric=sqale_index" /></a>
  <a href="https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner"><img alt="Maintainability Rating" src="https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&amp;metric=sqale_rating" /></a>
  <a href="https://sonarcloud.io/summary/new_code?id=stephenlclarke_mac-spinner"><img alt="Vulnerabilities" src="https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_mac-spinner&amp;metric=vulnerabilities" /></a>
  <a href="LICENSE"><img alt="License: MIT" src="assets/license-badge.svg" /></a>
</p>
<br clear="left" />
<!-- markdownlint-enable MD033 -->

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
