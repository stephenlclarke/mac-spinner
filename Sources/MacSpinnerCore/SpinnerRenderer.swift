public enum SpinnerRenderer {
    public static let frames = [
        "\u{2813}", "\u{280B}", "\u{2819}", "\u{281A}", "\u{2816}",
        "\u{2846}", "\u{28C4}", "\u{28E0}", "\u{28B0}", "\u{2832}",
    ]
    public static let pendingMark = "\u{2813}"
    public static let doneMark = "\u{2714}\u{FE0E}"

    public static func frame(at index: Int) -> String {
        let frameIndex = ((index % frames.count) + frames.count) % frames.count
        return frames[frameIndex]
    }

    public static func styledFrame(at index: Int, colour: Bool = false) -> String {
        let frame = frame(at: index)
        return colour ? "\u{001B}[38;5;63m\(frame)\u{001B}[0m" : frame
    }

    public static func pending(message: String, colour: Bool = false) -> String {
        row(mark: pendingMark, message: message, colour: colour, colourCode: "38;5;63")
    }

    public static func done(message: String, colour: Bool = false) -> String {
        row(mark: doneMark, message: message, colour: colour, colourCode: "32")
    }

    public static func spinnerLine(frame: String, message: String, colour: Bool = false) -> String {
        let mark = colour ? "\u{001B}[38;5;63m\(frame)\u{001B}[0m" : frame
        return "\(mark) \(message)"
    }

    private static func row(mark: String, message: String, colour: Bool, colourCode: String) -> String {
        let styledMark = colour ? "\u{001B}[\(colourCode)m\(mark)\u{001B}[0m" : mark
        return "\(styledMark) \(message)"
    }
}
