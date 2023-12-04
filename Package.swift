// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Apollon-iOS",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ApollonShared",
            targets: ["ApollonShared"]
        ),
        .library(
            name: "ApollonView",
            targets: ["ApollonView"]
        ),
        .library(
            name: "ApollonEdit",
            targets: ["ApollonEdit"]
        ),
        .library(
            name: "ApollonFeedback",
            targets: ["ApollonFeedback"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/ls1intum/artemis-ios-core-modules", .upToNextMajor(from: "7.0.1")),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "1.9.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ApollonShared"
        ),
        .target(
            name: "ApollonRenderer",
            dependencies: ["SwiftyBeaver", 
                           "ApollonShared"
                          ]
        ),
        .target(
            name: "ApollonView",
            dependencies: ["ApollonRenderer", 
                           "ApollonShared"
                          ]
        ),
        .target(
            name: "ApollonEdit",
            dependencies: ["ApollonRenderer", 
                           "ApollonShared"
                          ]
        ),
        .target(
            name: "ApollonFeedback",
            dependencies: ["ApollonRenderer",
                           "ApollonShared",
                           .product(name: "SharedModels", package: "artemis-ios-core-modules")
                          ]
        )
    ]
)
