// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2026 Stephen Clarke <stephenlclarke@mac.com> - https://github.com/stephenlclarke/mac-spinner

import Foundation
import XCTest
@testable import MacSpinnerCore

/// Verifies command launch, combined output capture, and invalid setup handling.
final class CommandRunnerTests: XCTestCase {
    /// Checks that stdout and stderr share one output file and preserve exit status.
    func testCapturesCombinedOutputAndExitStatus() throws {
        // Use a temporary destination so the child process cannot change repository files.
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: outputURL) }

        // Emit to both streams and exit non-zero to exercise capture and status handling.
        let status = try CommandRunner.run(command: ["/bin/sh", "-c", "printf out; printf err >&2; exit 7"], outputPath: outputURL.path)

        // Confirm both streams were captured in order and the child's status was returned.
        XCTAssertEqual(status, 7)
        XCTAssertEqual(try String(contentsOf: outputURL, encoding: .utf8), "outerr")
    }

    /// Checks that a bare executable name resolves from the current PATH.
    func testFindsExecutableOnPATH() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: outputURL) }

        // Run a standard no-op command by name to cover PATH lookup.
        XCTAssertEqual(try CommandRunner.run(command: ["true"], outputPath: outputURL.path), 0)
    }

    /// Checks that a missing bare executable produces a typed lookup error.
    func testRejectsExecutableMissingFromPATH() {
        let command = "missing-\(UUID().uuidString)"
        XCTAssertThrowsError(try CommandRunner.run(command: [command], outputPath: "/tmp/mac-spinner-test")) {
            XCTAssertEqual($0 as? CommandRunnerError, .executableNotFound(command))
        }
    }

    /// Checks that an empty command is rejected before process setup.
    func testRejectsEmptyCommand() {
        XCTAssertThrowsError(try CommandRunner.run(command: [], outputPath: "/tmp/mac-spinner-test")) { XCTAssertEqual($0 as? CommandRunnerError, .emptyCommand) }
    }

    /// Checks that a directory cannot be used as the output file destination.
    func testRejectsDirectoryAsOutputFile() {
        XCTAssertThrowsError(try CommandRunner.run(command: ["/usr/bin/true"], outputPath: FileManager.default.temporaryDirectory.path)) { XCTAssertEqual($0 as? CommandRunnerError, .cannotCreateOutput(FileManager.default.temporaryDirectory.path)) }
    }
}
