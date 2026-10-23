// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2026 Stephen Clarke <stephenlclarke@mac.com> - https://github.com/stephenlclarke/mac-spinner

import XCTest
@testable import MacSpinnerCore

/// Verifies valid CLI modes and the parser's rejection of invalid argument sets.
final class CLIConfigurationTests: XCTestCase {
    /// Checks that command tokens after `--` remain intact in run mode.
    func testParsesRunCommandAndArguments() throws {
        // Parse a command with separate executable, output path, and child arguments.
        let parsed = try CLIConfiguration.parse(["--message", "Working", "--output", "/tmp/out", "--", "git", "status"])
        // Compare the complete parsed configuration, including child argument order.
        XCTAssertEqual(parsed, CLIConfiguration(message: "Working", mode: .run(outputPath: "/tmp/out", command: ["git", "status"])))
    }

    /// Checks that all three display-only modes parse without command arguments.
    func testParsesDisplayModes() throws {
        XCTAssertEqual(try CLIConfiguration.parse(["--message", "Wait", "--spin-only"]).mode, .spinOnly)
        XCTAssertEqual(try CLIConfiguration.parse(["--message", "Wait", "--pending"]).mode, .pending)
        XCTAssertEqual(try CLIConfiguration.parse(["--message", "Wait", "--done"]).mode, .done)
    }

    /// Checks that help takes precedence even when another mode appears first.
    func testHelpWinsRegardlessOfPosition() throws {
        XCTAssertEqual(try CLIConfiguration.parse(["--pending", "--help"]).mode, .help)
    }

    /// Checks that parsing fails when no message option is supplied.
    func testRejectsMissingMessage() {
        XCTAssertThrowsError(try CLIConfiguration.parse(["--pending"])) { XCTAssertEqual($0 as? CLIParseError, .missingMessage) }
    }

    /// Checks that an empty message is rejected like a missing message.
    func testRejectsEmptyMessage() {
        XCTAssertThrowsError(try CLIConfiguration.parse(["--message", "", "--pending"])) { XCTAssertEqual($0 as? CLIParseError, .missingMessage) }
    }

    /// Checks that an option requiring a value fails when the value is absent.
    func testRejectsMissingOptionValue() {
        XCTAssertThrowsError(try CLIConfiguration.parse(["--message", "Wait", "--output"])) { XCTAssertEqual($0 as? CLIParseError, .missingValue("--output")) }
    }

    /// Checks that the command separator cannot be consumed as an option value.
    func testRejectsSeparatorAsOptionValue() {
        XCTAssertThrowsError(try CLIConfiguration.parse(["--message", "--", "echo"])) { XCTAssertEqual($0 as? CLIParseError, .missingValue("--message")) }
    }

    /// Checks that run mode requires an output file path.
    func testRejectsMissingOutput() {
        XCTAssertThrowsError(try CLIConfiguration.parse(["--message", "Wait", "--", "echo"])) { XCTAssertEqual($0 as? CLIParseError, .missingOutput) }
    }

    /// Checks that run mode requires a command after all options.
    func testRejectsMissingCommand() {
        XCTAssertThrowsError(try CLIConfiguration.parse(["--message", "Wait", "--output", "/tmp/out"])) { XCTAssertEqual($0 as? CLIParseError, .missingCommand) }
    }

    /// Checks that two display modes cannot be selected in one invocation.
    func testRejectsConflictingModes() {
        XCTAssertThrowsError(try CLIConfiguration.parse(["--message", "Wait", "--pending", "--done"])) { XCTAssertEqual($0 as? CLIParseError, .multipleModes) }
    }

    /// Checks that display-only modes reject command arguments.
    func testRejectsCommandForDisplayMode() {
        XCTAssertThrowsError(try CLIConfiguration.parse(["--message", "Wait", "--pending", "--", "echo"])) { XCTAssertEqual($0 as? CLIParseError, .unexpectedCommandArguments) }
    }

    /// Checks that unrecognised options return the matching parse error.
    func testRejectsUnknownArgument() {
        XCTAssertThrowsError(try CLIConfiguration.parse(["--message", "Wait", "--unknown"])) { XCTAssertEqual($0 as? CLIParseError, .unknownOption("--unknown")) }
    }
}
