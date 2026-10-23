// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Stephen Clarke

import Darwin
import Foundation
import MacSpinnerCore

private let usage = """
USAGE:
  mac-spinner --message <text> --output <file> -- <command> [args...]
  mac-spinner --message <text> --spin-only
  mac-spinner --message <text> --pending
  mac-spinner --message <text> --done
  mac-spinner -h|--help

OPTIONS:
  --message <text>  Text to show next to the spinner.
  --output <file>   File that receives combined stdout and stderr.
  --spin-only       Show the spinner until this process is stopped.
  --pending         Print a pending progress row and exit.
  --done            Print a completed progress row.
  -h, --help        Show this help text.

ENVIRONMENT:
  SCRIPT_COLOUR     Set to off, false, or 0 to disable colour.
"""

private func colourEnabled() -> Bool {
    guard isatty(STDOUT_FILENO) == 1 else { return false }
    let disabledValues = ["off", "OFF", "false", "FALSE", "0"]
    return !disabledValues.contains(ProcessInfo.processInfo.environment["SCRIPT_COLOUR"] ?? "")
}

private func restoreCursor() {
    guard isatty(STDOUT_FILENO) == 1 else { return }
    let sequence = Array("\u{001B}[?25h".utf8)
    sequence.withUnsafeBytes { bytes in
        _ = Darwin.write(STDOUT_FILENO, bytes.baseAddress!, bytes.count)
    }
}

private func spin(message: String) -> Never {
    signal(SIGTERM) { _ in
        restoreCursor()
        Darwin.exit(0)
    }
    signal(SIGINT) { _ in
        restoreCursor()
        Darwin.exit(0)
    }

    guard isatty(STDOUT_FILENO) == 1 else {
        print(SpinnerRenderer.pending(message: message))
        while true { usleep(100_000) }
    }

    let hideCursor = "\u{001B}[?25l"
    hideCursor.withCString { _ = fputs($0, stdout) }
    let firstFrame = SpinnerRenderer.frame(at: 0)
    print(SpinnerRenderer.spinnerLine(frame: firstFrame, message: message, colour: colourEnabled()), terminator: "")
    fflush(stdout)

    var index = 1
    while true {
        let frame = SpinnerRenderer.styledFrame(at: index, colour: colourEnabled())
        print("\r\(frame)", terminator: "")
        fflush(stdout)
        index += 1
        usleep(100_000)
    }
}

private func main() -> Int32 {
    do {
        let configuration = try CLIConfiguration.parse(Array(CommandLine.arguments.dropFirst()))
        switch configuration.mode {
        case .help:
            print(usage)
            return 0
        case .pending:
            print(SpinnerRenderer.pending(message: configuration.message, colour: colourEnabled()))
            return 0
        case .done:
            print(SpinnerRenderer.done(message: configuration.message, colour: colourEnabled()))
            return 0
        case .spinOnly:
            spin(message: configuration.message)
        case let .run(outputPath, command):
            print(SpinnerRenderer.pending(message: configuration.message, colour: colourEnabled()))
            return try CommandRunner.run(command: command, outputPath: outputPath)
        }
    } catch {
        fputs("ERROR: \(error)\n\(usage)\n", stderr)
        return 2
    }
}

Darwin.exit(main())
