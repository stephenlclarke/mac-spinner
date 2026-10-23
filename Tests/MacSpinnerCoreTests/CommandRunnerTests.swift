// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Stephen Clarke

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

    func testRejectsEmptyCommand() {
        XCTAssertThrowsError(try CommandRunner.run(command: [], outputPath: "/tmp/mac-spinner-test")) { XCTAssertEqual($0 as? CommandRunnerError, .emptyCommand) }
    }

    func testRejectsDirectoryAsOutputFile() {
        XCTAssertThrowsError(try CommandRunner.run(command: ["/usr/bin/true"], outputPath: FileManager.default.temporaryDirectory.path)) { XCTAssertEqual($0 as? CommandRunnerError, .cannotCreateOutput(FileManager.default.temporaryDirectory.path)) }
    }
}
