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

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = command
        process.standardOutput = output
        process.standardError = output
        try process.run()
        process.waitUntilExit()
        return process.terminationStatus
    }
}

public enum CommandRunnerError: Error, Equatable, CustomStringConvertible {
    case emptyCommand
    case cannotCreateOutput(String)

    public var description: String {
        switch self {
        case .emptyCommand:
            "command is empty"
        case let .cannotCreateOutput(path):
            "cannot create output file: \(path)"
        }
    }
}
