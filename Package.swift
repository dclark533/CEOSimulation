// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CEOSimulationCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "CEOSimulationCore",
            targets: ["CEOSimulationCore"]),
    ],
    targets: [
        .target(
            name: "CEOSimulationCore",
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),
        .testTarget(
            name: "CEOSimulationCoreTests",
            dependencies: ["CEOSimulationCore"]
        ),
    ]
)