// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LCDPanel",
    platforms: [
        .macOS(.v13),
        .iOS("26.0")
    ],
    products: [
        .library(
            name: "LCDPanel",
            targets: ["LCDPanel"]
        )
    ],
    targets: [
        .target(name: "LCDPanel"),
        .testTarget(
            name: "LCDPanelTests",
            dependencies: ["LCDPanel"]
        )
    ]
)
