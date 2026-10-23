// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2026 Stephen Clarke <stephenlclarke@mac.com> - https://github.com/stephenlclarke/mac-spinner

import XCTest
@testable import MacSpinnerCore

/// Verifies frame wrapping and the exact text and colour emitted by the renderer.
final class SpinnerRendererTests: XCTestCase {
    /// Checks that frame indices wrap for positive and negative positions.
    func testFramesWrapForPositiveAndNegativeIndices() {
        XCTAssertEqual(SpinnerRenderer.frame(at: SpinnerRenderer.frames.count), SpinnerRenderer.frames[0])
        XCTAssertEqual(SpinnerRenderer.frame(at: -1), SpinnerRenderer.frames.last)
        XCTAssertEqual(SpinnerRenderer.frame(at: 1), SpinnerRenderer.frames[1])
    }

    /// Checks that colour escape sequences appear only when requested.
    func testStyledFrameAddsColourOnlyWhenRequested() {
        XCTAssertEqual(SpinnerRenderer.styledFrame(at: 0), SpinnerRenderer.frames[0])
        XCTAssertEqual(SpinnerRenderer.styledFrame(at: 0, colour: true), "\u{001B}[38;5;63m\(SpinnerRenderer.frames[0])\u{001B}[0m")
    }

    /// Checks the plain pending and done row formats.
    func testPendingAndDoneRows() {
        XCTAssertEqual(SpinnerRenderer.pending(message: "Waiting"), "\(SpinnerRenderer.pendingMark) Waiting")
        XCTAssertEqual(SpinnerRenderer.done(message: "Ready"), "\(SpinnerRenderer.doneMark) Ready")
    }

    /// Checks that pending and done rows use their expected ANSI colours.
    func testRowsApplyExpectedColour() {
        XCTAssertTrue(SpinnerRenderer.pending(message: "Waiting", colour: true).hasPrefix("\u{001B}[38;5;63m"))
        XCTAssertTrue(SpinnerRenderer.done(message: "Ready", colour: true).hasPrefix("\u{001B}[32m"))
    }

    /// Checks that a spinner line contains its frame followed by the message.
    func testSpinnerLineContainsMessage() {
        XCTAssertEqual(SpinnerRenderer.spinnerLine(frame: "*", message: "Doing work"), "* Doing work")
    }
}
