// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2026 Stephen Clarke <stephenlclarke@mac.com> - https://github.com/stephenlclarke/mac-spinner

import Foundation

/// Describes the action requested from the command-line application.
public enum SpinnerMode: Equatable {
    /// Runs the command and writes its combined output to the supplied file path.
    case run(outputPath: String, command: [String])
    /// Displays an animated spinner until the process receives a stop signal.
    case spinOnly
    /// Prints a pending status row and exits.
    case pending
    /// Prints a completed status row and exits.
    case done
    /// Prints command usage and exits.
    case help
}

/// Holds the validated message and execution mode parsed from CLI arguments.
public struct CLIConfiguration: Equatable {
    /// Text displayed beside the spinner or status mark.
    public let message: String
    /// Action to perform after argument parsing succeeds.
    public let mode: SpinnerMode

    /// Creates a configuration from an already validated message and mode.
    /// - Parameters:
    ///   - message: Text displayed beside the spinner or status mark.
    ///   - mode: Action selected by the caller.
    public init(message: String, mode: SpinnerMode) {
        self.message = message
        self.mode = mode
    }

    /// Parses CLI tokens and validates the selected mode's required arguments.
    /// - Parameter arguments: Arguments following the executable name.
    /// - Returns: A complete configuration for the requested action.
    /// - Throws: `CLIParseError` when an option, value, or mode is invalid.
    public static func parse(_ arguments: [String]) throws -> CLIConfiguration {
        // Help is accepted in any position and takes precedence over other options.
        if arguments.contains("-h") || arguments.contains("--help") {
            return CLIConfiguration(message: "", mode: .help)
        }

        var message: String?
        var outputPath: String?
        var selectedMode: SpinnerMode?
        var command: [String] = []
        var index = 0

        // Collect options until the command separator; tokens after it belong to the child process.
        while index < arguments.count {
            let argument = arguments[index]
            index += 1

            switch argument {
            case "--message":
                message = try value(for: argument, in: arguments, at: &index)
            case "--output":
                outputPath = try value(for: argument, in: arguments, at: &index)
            case "--spin-only":
                try select(.spinOnly, into: &selectedMode)
            case "--pending":
                try select(.pending, into: &selectedMode)
            case "--done":
                try select(.done, into: &selectedMode)
            case "--":
                command = Array(arguments[index...])
                index = arguments.count
            default:
                throw CLIParseError.unknownOption(argument)
            }
        }

        // A non-empty message is required for every display mode.
        guard let message, !message.isEmpty else {
            throw CLIParseError.missingMessage
        }

        // Display-only modes cannot also receive command or output-file arguments.
        if let selectedMode {
            guard outputPath == nil, command.isEmpty else {
                throw CLIParseError.unexpectedCommandArguments
            }
            return CLIConfiguration(message: message, mode: selectedMode)
        }

        // The default run mode requires both an output destination and a command.
        guard let outputPath, !outputPath.isEmpty else {
            throw CLIParseError.missingOutput
        }
        guard !command.isEmpty else {
            throw CLIParseError.missingCommand
        }

        return CLIConfiguration(message: message, mode: .run(outputPath: outputPath, command: command))
    }

    /// Reads the next token as an option value and advances the parser index.
    /// - Parameters:
    ///   - option: Option name used in a missing-value error.
    ///   - arguments: Full argument list being parsed.
    ///   - index: Index of the next candidate value; updated after success.
    /// - Returns: The value token following `option`.
    /// - Throws: `CLIParseError.missingValue` if no value is available.
    private static func value(for option: String, in arguments: [String], at index: inout Int) throws -> String {
        guard index < arguments.count, arguments[index] != "--" else {
            throw CLIParseError.missingValue(option)
        }

        defer { index += 1 }
        return arguments[index]
    }

    /// Records a display mode and rejects a second mode selection.
    /// - Parameters:
    ///   - mode: Mode to select.
    ///   - selectedMode: Current selection, updated when no mode is selected yet.
    /// - Throws: `CLIParseError.multipleModes` if another mode was already selected.
    private static func select(_ mode: SpinnerMode, into selectedMode: inout SpinnerMode?) throws {
        guard selectedMode == nil else {
            throw CLIParseError.multipleModes
        }
        selectedMode = mode
    }
}

/// Describes invalid or incomplete command-line input in user-readable form.
public enum CLIParseError: Error, Equatable, CustomStringConvertible {
    case missingMessage
    case missingValue(String)
    case missingOutput
    case missingCommand
    case multipleModes
    case unexpectedCommandArguments
    case unknownOption(String)

    /// Returns the concise message shown before the usage text.
    public var description: String {
        switch self {
        case .missingMessage:
            "missing --message"
        case let .missingValue(option):
            "missing value for \(option)"
        case .missingOutput:
            "missing --output"
        case .missingCommand:
            "missing command after --"
        case .multipleModes:
            "choose one mode"
        case .unexpectedCommandArguments:
            "this mode does not accept --output or a command"
        case let .unknownOption(option):
            "unknown argument: \(option)"
        }
    }
}
