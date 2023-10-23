// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FoldUI",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FoldUI",
            targets: ["FoldUI"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "FoldUI",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
            ]
        ),
        .testTarget(
            name: "FoldUITests",
            dependencies: ["FoldUI"]),
    ]
)
