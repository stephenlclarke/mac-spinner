// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2026 Stephen Clarke <stephenlclarke@mac.com> - https://github.com/stephenlclarke/mac-spinner

import Darwin
import Dispatch
import Foundation
import MacSpinnerCore

/// Command syntax and option descriptions printed for help and parse failures.
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

/// Enables colour only for terminal output unless the environment disables it.
/// - Returns: `true` when stdout is a terminal and `SCRIPT_COLOUR` is not disabled.
private func colourEnabled() -> Bool {
    guard isatty(STDOUT_FILENO) == 1 else { return false }
    let disabledValues = ["off", "OFF", "false", "FALSE", "0"]
    return !disabledValues.contains(ProcessInfo.processInfo.environment["SCRIPT_COLOUR"] ?? "")
}

/// Shows the terminal cursor again when stdout is an interactive terminal.
private func restoreCursor() {
    guard isatty(STDOUT_FILENO) == 1 else { return }
    let sequence = Array("\u{001B}[?25h".utf8)
    sequence.withUnsafeBytes { bytes in
        _ = Darwin.write(STDOUT_FILENO, bytes.baseAddress!, bytes.count)
    }
}

/// Registers dispatch handlers for stop signals and keeps them alive until shutdown.
/// - Returns: Active sources that deliver `SIGINT` and `SIGTERM` outside signal context.
private func installStopSignalHandlers() -> [DispatchSourceSignal] {
    // Ignore each signal at the process level so Dispatch can deliver it to a queue.
    [SIGTERM, SIGINT].map { signalNumber in
        signal(signalNumber, SIG_IGN)

        let source = DispatchSource.makeSignalSource(signal: signalNumber, queue: .global())
        source.setEventHandler {
            // Restore the terminal in normal queue context before exiting the process.
            restoreCursor()
            Darwin.exit(0)
        }
        source.resume()
        return source
    }
}

/// Runs the animated or non-terminal waiting loop until a stop signal arrives.
/// - Parameter message: Text shown beside the spinner or pending mark.
/// - Returns: Never; the process exits from a registered signal handler.
private func spin(message: String) -> Never {
    let stopSignalSources = installStopSignalHandlers()
    // Retain the sources until this non-returning animation or wait loop ends.
    defer { withExtendedLifetime(stopSignalSources) {} }

    // In redirected output, print one status row and wait without terminal controls.
    guard isatty(STDOUT_FILENO) == 1 else {
        print(SpinnerRenderer.pending(message: message))
        while true { usleep(100_000) }
    }

    // Hide the cursor once, draw the first complete line, then update only its frame.
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

/// Parses process arguments, dispatches the selected mode, and reports failures.
/// - Returns: The exit status passed to `Darwin.exit`.
private func main() -> Int32 {
    // Parse once, then route validated configurations to the corresponding action.
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
    // Convert parse, file, and process-launch errors into a diagnostic and usage text.
    } catch {
        fputs("ERROR: \(error)\n\(usage)\n", stderr)
        return 2
    }
}

Darwin.exit(main())
