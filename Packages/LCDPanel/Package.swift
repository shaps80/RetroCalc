// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LCDPanel",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "LCDPanel",
            targets: ["LCDPanel"]
        )
    ],
    targets: [
        .target(name: "LCDPanel")
    ]
)
