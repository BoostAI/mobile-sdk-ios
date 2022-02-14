// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "BoostAI",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "BoostAI",
            targets: ["BoostAI"]),
    ],
    targets: [
        .target(
            name: "BoostAI",
            dependencies: [],
            path: "BoostAI",
            exclude: [
                "Info.plist"
            ])
    ]
)
