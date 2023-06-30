// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "FileCachePackage",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "FileCachePackage",
            targets: ["FileCachePackage"])
    ],
    dependencies: [
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.8.0")
    ],
    targets: [
        .target(
            name: "FileCachePackage",
            dependencies: [
                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack")
            ]),
        .testTarget(
            name: "FileCachePackageTests",
            dependencies: ["FileCachePackage"])
    ]
)
