// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NewsFeedClient",
    platforms: [
        .iOS(.v17),
        // macOS enables `swift test` on GitHub Actions without iOS Simulator flakes.
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "NewsFeedClient",
            targets: ["NewsFeedClient"]),
    ],
    targets: [
        .target(
            name: "NewsFeedClient"),
        .testTarget(
            name: "NewsFeedClientTests",
            dependencies: ["NewsFeedClient"]),
    ]
)
