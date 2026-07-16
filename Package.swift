// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ClipBar",
    platforms: [.macOS(.v13)],
    targets: [
        .target(name: "ClipHistoryCore"),
        .executableTarget(name: "ClipBar", dependencies: ["ClipHistoryCore"]),
        .testTarget(name: "ClipHistoryCoreTests", dependencies: ["ClipHistoryCore"]),
    ]
)
