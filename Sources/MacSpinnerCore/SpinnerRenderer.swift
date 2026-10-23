// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2026 Stephen Clarke <stephenlclarke@mac.com> - https://github.com/stephenlclarke/mac-spinner

/// Builds the Unicode marks and terminal rows used by spinner modes.
public enum SpinnerRenderer {
    /// Ordered braille frames for the animated spinner.
    public static let frames = [
        "\u{2813}", "\u{280B}", "\u{2819}", "\u{281A}", "\u{2816}",
        "\u{2846}", "\u{28C4}", "\u{28E0}", "\u{28B0}", "\u{2832}",
    ]
    /// Braille mark used for a pending status row.
    public static let pendingMark = "\u{2813}"
    /// Text-presentation check mark used for a completed status row.
    public static let doneMark = "\u{2714}\u{FE0E}"

    /// Selects a spinner frame and wraps indices in either direction.
    /// - Parameter index: Frame position, including negative or out-of-range values.
    /// - Returns: The frame at the wrapped position.
    public static func frame(at index: Int) -> String {
        let frameIndex = ((index % frames.count) + frames.count) % frames.count
        return frames[frameIndex]
    }

    /// Adds optional ANSI colour sequences around one animation frame.
    /// - Parameters:
    ///   - index: Frame position passed to `frame(at:)`.
    ///   - colour: Whether to add the spinner colour escape sequences.
    /// - Returns: A plain or colour-styled frame.
    public static func styledFrame(at index: Int, colour: Bool = false) -> String {
        let frame = frame(at: index)
        return colour ? "\u{001B}[38;5;63m\(frame)\u{001B}[0m" : frame
    }

    /// Formats a pending status row with optional colour on its mark.
    /// - Parameters:
    ///   - message: Status text shown after the mark.
    ///   - colour: Whether to add terminal colour escape sequences.
    /// - Returns: The formatted row without a trailing newline.
    public static func pending(message: String, colour: Bool = false) -> String {
        row(mark: pendingMark, message: message, colour: colour, colourCode: "38;5;63")
    }

    /// Formats a completed status row with optional colour on its mark.
    /// - Parameters:
    ///   - message: Completion text shown after the mark.
    ///   - colour: Whether to add terminal colour escape sequences.
    /// - Returns: The formatted row without a trailing newline.
    public static func done(message: String, colour: Bool = false) -> String {
        row(mark: doneMark, message: message, colour: colour, colourCode: "32")
    }

    /// Formats one spinner frame and its message for an animated terminal line.
    /// - Parameters:
    ///   - frame: Unicode frame or other mark to display.
    ///   - message: Text shown after the mark.
    ///   - colour: Whether to add terminal colour escape sequences around the mark.
    /// - Returns: The formatted line without a trailing newline.
    public static func spinnerLine(frame: String, message: String, colour: Bool = false) -> String {
        let mark = colour ? "\u{001B}[38;5;63m\(frame)\u{001B}[0m" : frame
        return "\(mark) \(message)"
    }

    /// Applies the requested colour to a mark and joins it with the status message.
    /// - Parameters:
    ///   - mark: Symbol shown at the start of the row.
    ///   - message: Text shown after the mark.
    ///   - colour: Whether to wrap the mark in ANSI colour sequences.
    ///   - colourCode: ANSI colour code used when styling is enabled.
    /// - Returns: The formatted row without a trailing newline.
    private static func row(mark: String, message: String, colour: Bool, colourCode: String) -> String {
        let styledMark = colour ? "\u{001B}[\(colourCode)m\(mark)\u{001B}[0m" : mark
        return "\(styledMark) \(message)"
    }
}
