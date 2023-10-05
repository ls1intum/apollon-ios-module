// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Apollon-iOS",
    defaultLocalization: "en",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ApollonModels",
            targets: ["ApollonModels"]
        ),
        .library(
            name: "ApollonView",
            targets: ["ApollonView"]
        ),
        .library(
            name: "ApollonEdit",
            targets: ["ApollonEdit"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "1.9.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ApollonModels"
        ),
        .target(
            name: "ApollonCommon",
            dependencies: ["SwiftyBeaver", "ApollonModels"]
        ),
        .target(
            name: "ApollonView",
            dependencies: ["ApollonCommon", "ApollonModels"]
        ),
        .target(
            name: "ApollonEdit",
            dependencies: ["ApollonCommon", "ApollonModels"]
        )
    ]
)
