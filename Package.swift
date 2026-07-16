// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Clippy",
    platforms: [.macOS(.v13)],
    targets: [
        .target(name: "ClipHistoryCore"),
        .executableTarget(name: "Clippy", dependencies: ["ClipHistoryCore"]),
        .testTarget(name: "ClipHistoryCoreTests", dependencies: ["ClipHistoryCore"]),
    ]
)
