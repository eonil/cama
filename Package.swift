// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CAMA",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "CAMA",
            targets: ["CAMA"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "CAMA",
            dependencies: []),
        .testTarget(
            name: "CAMATests",
            dependencies: ["CAMA"]),
    ]
)
