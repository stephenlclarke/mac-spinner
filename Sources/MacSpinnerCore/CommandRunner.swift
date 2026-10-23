// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2026 Stephen Clarke <stephenlclarke@mac.com> - https://github.com/stephenlclarke/mac-spinner

import Foundation

public enum CommandRunner {
    @discardableResult
    public static func run(command: [String], outputPath: String) throws -> Int32 {
        guard !command.isEmpty else {
            throw CommandRunnerError.emptyCommand
        }

        guard FileManager.default.createFile(atPath: outputPath, contents: nil) else {
            throw CommandRunnerError.cannotCreateOutput(outputPath)
        }

        let output = try FileHandle(forWritingTo: URL(fileURLWithPath: outputPath))
        defer { try? output.close() }

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

    private static func resolveExecutable(_ command: String) throws -> String {
        if command.contains("/") {
            return command
        }

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

public enum CommandRunnerError: Error, Equatable, CustomStringConvertible {
    case emptyCommand
    case cannotCreateOutput(String)
    case executableNotFound(String)

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
