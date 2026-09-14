// swift-tools-version:5.3
import PackageDescription
let package = Package(
    name: "BoostAI",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "BoostAI",
            targets: ["BoostAI"]
        )
    ],
    targets: [
        .target(
            name: "BoostAI",
            path: "BoostAI",
            exclude: [
                "BoostAI.h",
                "Info.plist"
            ],
            resources: [
                .process("UI/Assets.xcassets")
            ]
        ),
        .testTarget(
            name: "BoostAITests",
            dependencies: ["BoostAI"],
            path: "BoostAITests",
            exclude: [
                "Info.plist"
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
