// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LEDDisplay",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "LEDDisplay",
            targets: ["LEDDisplay"]
        )
    ],
    targets: [
        .target(name: "LEDDisplay")
    ]
)
