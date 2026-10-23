// swift-tools-version: 6.0
// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2026 Stephen Clarke <stephenlclarke@mac.com> - https://github.com/stephenlclarke/mac-spinner

import PackageDescription

// Define the macOS package, its reusable core library, CLI product, and tests.
let package = Package(
    name: "mac-spinner",
    platforms: [.macOS(.v13)],
    products: [
        // Publish both the command-line app and its reusable rendering/configuration core.
        .executable(name: "mac-spinner", targets: ["mac-spinner"]),
        .library(name: "MacSpinnerCore", targets: ["MacSpinnerCore"]),
    ],
    targets: [
        // Keep parsing, rendering, and process execution independently testable.
        .target(name: "MacSpinnerCore"),
        // Link the CLI entry point to the shared core implementation.
        .executableTarget(name: "mac-spinner", dependencies: ["MacSpinnerCore"]),
        // Verify the core library's public behavior and error handling.
        .testTarget(name: "MacSpinnerCoreTests", dependencies: ["MacSpinnerCore"]),
    ],
)
