// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2026 Stephen Clarke <stephenlclarke@mac.com> - https://github.com/stephenlclarke/mac-spinner

import Foundation
import XCTest
@testable import MacSpinnerCore

final class CommandRunnerTests: XCTestCase {
    func testCapturesCombinedOutputAndExitStatus() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: outputURL) }

        let status = try CommandRunner.run(command: ["/bin/sh", "-c", "printf out; printf err >&2; exit 7"], outputPath: outputURL.path)

        XCTAssertEqual(status, 7)
        XCTAssertEqual(try String(contentsOf: outputURL, encoding: .utf8), "outerr")
    }

    func testFindsExecutableOnPATH() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: outputURL) }

        XCTAssertEqual(try CommandRunner.run(command: ["true"], outputPath: outputURL.path), 0)
    }

    func testRejectsExecutableMissingFromPATH() {
        let command = "missing-\(UUID().uuidString)"
        XCTAssertThrowsError(try CommandRunner.run(command: [command], outputPath: "/tmp/mac-spinner-test")) {
            XCTAssertEqual($0 as? CommandRunnerError, .executableNotFound(command))
        }
    }

    func testRejectsEmptyCommand() {
        XCTAssertThrowsError(try CommandRunner.run(command: [], outputPath: "/tmp/mac-spinner-test")) { XCTAssertEqual($0 as? CommandRunnerError, .emptyCommand) }
    }

    func testRejectsDirectoryAsOutputFile() {
        XCTAssertThrowsError(try CommandRunner.run(command: ["/usr/bin/true"], outputPath: FileManager.default.temporaryDirectory.path)) { XCTAssertEqual($0 as? CommandRunnerError, .cannotCreateOutput(FileManager.default.temporaryDirectory.path)) }
    }
}
