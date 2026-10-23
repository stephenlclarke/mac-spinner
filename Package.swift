// swift-tools-version: 6.2

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
