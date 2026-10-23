// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2026 Stephen Clarke <stephenlclarke@mac.com> - https://github.com/stephenlclarke/mac-spinner

import Foundation

/// Launches a child command and captures its standard output and error together.
public enum CommandRunner {
    /// Runs a command, resolves bare executable names through `PATH`, and captures output.
    /// - Parameters:
    ///   - command: Executable name or path followed by its argument tokens.
    ///   - outputPath: Destination file for combined standard output and error.
    /// - Returns: The child process termination status.
    /// - Throws: `CommandRunnerError` for invalid commands or output paths, or a process launch error.
    @discardableResult
    public static func run(command: [String], outputPath: String) throws -> Int32 {
        // Reject an empty command before creating files or configuring a process.
        guard !command.isEmpty else {
            throw CommandRunnerError.emptyCommand
        }

        // Create the capture file before opening it for the child's two output streams.
        guard FileManager.default.createFile(atPath: outputPath, contents: nil) else {
            throw CommandRunnerError.cannotCreateOutput(outputPath)
        }

        let output = try FileHandle(forWritingTo: URL(fileURLWithPath: outputPath))
        defer { try? output.close() }

        // Resolve PATH names, then pass the remaining tokens directly without invoking a shell.
        let executable = try resolveExecutable(command[0])
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = Array(command.dropFirst())
        process.standardOutput = output
        process.standardError = output
        try process.run()
        process.waitUntilExit()
        return process.terminationStatus
    }

    /// Returns the executable path for an absolute, relative, or PATH-based command name.
    /// - Parameter command: First token supplied to `run`.
    /// - Returns: A path suitable for `Process.executableURL`.
    /// - Throws: `CommandRunnerError.executableNotFound` if a bare name is absent from `PATH`.
    private static func resolveExecutable(_ command: String) throws -> String {
        // A command containing a slash already specifies its own location.
        if command.contains("/") {
            return command
        }

        // Search each PATH entry in order and accept only executable files.
        let searchPath = ProcessInfo.processInfo.environment["PATH"] ?? ""
        for directory in searchPath.split(separator: ":", omittingEmptySubsequences: false) {
            let candidate = URL(fileURLWithPath: String(directory), isDirectory: true)
                .appendingPathComponent(command)
                .path
            if FileManager.default.isExecutableFile(atPath: candidate) {
                return candidate
            }
        }

        throw CommandRunnerError.executableNotFound(command)
    }
}

/// Describes failures detected before or during child-command setup.
public enum CommandRunnerError: Error, Equatable, CustomStringConvertible {
    case emptyCommand
    case cannotCreateOutput(String)
    case executableNotFound(String)

    /// Returns a concise explanation suitable for the CLI error output.
    public var description: String {
        switch self {
        case .emptyCommand:
            "command is empty"
        case let .cannotCreateOutput(path):
            "cannot create output file: \(path)"
        case let .executableNotFound(command):
            "executable not found in PATH: \(command)"
        }
    }
}
