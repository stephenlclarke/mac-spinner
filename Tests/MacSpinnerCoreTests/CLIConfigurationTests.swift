// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Stephen Clarke

import XCTest
@testable import MacSpinnerCore

final class CLIConfigurationTests: XCTestCase {
    func testParsesRunCommandAndArguments() throws {
        let parsed = try CLIConfiguration.parse(["--message", "Working", "--output", "/tmp/out", "--", "git", "status"])
        XCTAssertEqual(parsed, CLIConfiguration(message: "Working", mode: .run(outputPath: "/tmp/out", command: ["git", "status"])))
    }

    func testParsesDisplayModes() throws {
        XCTAssertEqual(try CLIConfiguration.parse(["--message", "Wait", "--spin-only"]).mode, .spinOnly)
        XCTAssertEqual(try CLIConfiguration.parse(["--message", "Wait", "--pending"]).mode, .pending)
        XCTAssertEqual(try CLIConfiguration.parse(["--message", "Wait", "--done"]).mode, .done)
    }

    func testHelpWinsRegardlessOfPosition() throws {
        XCTAssertEqual(try CLIConfiguration.parse(["--pending", "--help"]).mode, .help)
    }

    func testRejectsMissingMessage() {
        XCTAssertThrowsError(try CLIConfiguration.parse(["--pending"])) { XCTAssertEqual($0 as? CLIParseError, .missingMessage) }
    }

    func testRejectsEmptyMessage() {
        XCTAssertThrowsError(try CLIConfiguration.parse(["--message", "", "--pending"])) { XCTAssertEqual($0 as? CLIParseError, .missingMessage) }
    }

    func testRejectsMissingOptionValue() {
        XCTAssertThrowsError(try CLIConfiguration.parse(["--message", "Wait", "--output"])) { XCTAssertEqual($0 as? CLIParseError, .missingValue("--output")) }
    }

    func testRejectsSeparatorAsOptionValue() {
        XCTAssertThrowsError(try CLIConfiguration.parse(["--message", "--", "echo"])) { XCTAssertEqual($0 as? CLIParseError, .missingValue("--message")) }
    }

    func testRejectsMissingOutput() {
        XCTAssertThrowsError(try CLIConfiguration.parse(["--message", "Wait", "--", "echo"])) { XCTAssertEqual($0 as? CLIParseError, .missingOutput) }
    }

    func testRejectsMissingCommand() {
        XCTAssertThrowsError(try CLIConfiguration.parse(["--message", "Wait", "--output", "/tmp/out"])) { XCTAssertEqual($0 as? CLIParseError, .missingCommand) }
    }

    func testRejectsConflictingModes() {
        XCTAssertThrowsError(try CLIConfiguration.parse(["--message", "Wait", "--pending", "--done"])) { XCTAssertEqual($0 as? CLIParseError, .multipleModes) }
    }

    func testRejectsCommandForDisplayMode() {
        XCTAssertThrowsError(try CLIConfiguration.parse(["--message", "Wait", "--pending", "--", "echo"])) { XCTAssertEqual($0 as? CLIParseError, .unexpectedCommandArguments) }
    }

    func testRejectsUnknownArgument() {
        XCTAssertThrowsError(try CLIConfiguration.parse(["--message", "Wait", "--unknown"])) { XCTAssertEqual($0 as? CLIParseError, .unknownOption("--unknown")) }
    }
}
