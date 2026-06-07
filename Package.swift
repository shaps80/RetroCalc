// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "RetroCalc",
    platforms: [
        .macOS(.v13),
        .iOS("26.0")
    ],
    products: [
        .library(
            name: "CalculatorCore",
            targets: ["CalculatorCore"]
        )
    ],
    targets: [
        .target(
            name: "CalculatorCore",
            path: "RetroCalcApp/Calculator",
            exclude: [
                "CalculatorView.swift",
                "Key.swift",
                "KeyPad.swift"
            ],
            sources: ["CalculatorModel.swift"]
        ),
        .testTarget(
            name: "CalculatorCoreTests",
            dependencies: ["CalculatorCore"]
        )
    ]
)
