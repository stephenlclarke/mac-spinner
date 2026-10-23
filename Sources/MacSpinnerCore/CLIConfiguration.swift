// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Stephen Clarke

import Foundation

public enum SpinnerMode: Equatable {
    case run(outputPath: String, command: [String])
    case spinOnly
    case pending
    case done
    case help
}

public struct CLIConfiguration: Equatable {
    public let message: String
    public let mode: SpinnerMode

    public init(message: String, mode: SpinnerMode) {
        self.message = message
        self.mode = mode
    }

    public static func parse(_ arguments: [String]) throws -> CLIConfiguration {
        if arguments.contains("-h") || arguments.contains("--help") {
            return CLIConfiguration(message: "", mode: .help)
        }

        var message: String?
        var outputPath: String?
        var selectedMode: SpinnerMode?
        var command: [String] = []
        var index = 0

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

        guard let message, !message.isEmpty else {
            throw CLIParseError.missingMessage
        }

        if let selectedMode {
            guard outputPath == nil, command.isEmpty else {
                throw CLIParseError.unexpectedCommandArguments
            }
            return CLIConfiguration(message: message, mode: selectedMode)
        }

        guard let outputPath, !outputPath.isEmpty else {
            throw CLIParseError.missingOutput
        }
        guard !command.isEmpty else {
            throw CLIParseError.missingCommand
        }

        return CLIConfiguration(message: message, mode: .run(outputPath: outputPath, command: command))
    }

    private static func value(for option: String, in arguments: [String], at index: inout Int) throws -> String {
        guard index < arguments.count, arguments[index] != "--" else {
            throw CLIParseError.missingValue(option)
        }

        defer { index += 1 }
        return arguments[index]
    }

    private static func select(_ mode: SpinnerMode, into selectedMode: inout SpinnerMode?) throws {
        guard selectedMode == nil else {
            throw CLIParseError.multipleModes
        }
        selectedMode = mode
    }
}

public enum CLIParseError: Error, Equatable, CustomStringConvertible {
    case missingMessage
    case missingValue(String)
    case missingOutput
    case missingCommand
    case multipleModes
    case unexpectedCommandArguments
    case unknownOption(String)

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
