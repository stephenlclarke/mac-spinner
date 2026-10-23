// swift-tools-version: 6.0
// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2026 Stephen Clarke <stephenlclarke@mac.com> - https://github.com/stephenlclarke/mac-spinner

import PackageDescription

let package = Package(
    name: "mac-spinner",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "mac-spinner", targets: ["mac-spinner"]),
        .library(name: "MacSpinnerCore", targets: ["MacSpinnerCore"]),
    ],
    targets: [
        .target(name: "MacSpinnerCore"),
        .executableTarget(name: "mac-spinner", dependencies: ["MacSpinnerCore"]),
        .testTarget(name: "MacSpinnerCoreTests", dependencies: ["MacSpinnerCore"]),
    ],
)
