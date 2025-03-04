// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Models",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(
            name: "Models",
            targets: ["Models"]),
    ],
    targets: [
        .target(
            name: "Models",
            path: "Sources/Models"),
        .testTarget(
            name: "ModelsTests",
            dependencies: ["Models"]),
    ]
)
