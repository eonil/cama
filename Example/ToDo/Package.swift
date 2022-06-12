// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ToDo",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(name: "ToDo", targets: ["ToDo"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "ToDo", dependencies: []),
    ]
)
