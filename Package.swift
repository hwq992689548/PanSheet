// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "PanSheet",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(name: "PanSheet", targets: ["PanSheet"]),
    ],
    targets: [
        .target(
            name: "PanSheet",
            path: "Sources/PanSheet"
        ),
    ]
)
