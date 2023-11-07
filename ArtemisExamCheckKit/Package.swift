// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ArtemisExamCheckKit",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ArtemisExamCheckKit",
            targets: ["ArtemisExamCheckKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/daltoniam/Starscream", exact: "4.0.4"),
        .package(url: "https://github.com/ls1intum/artemis-ios-core-modules", from: "7.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ArtemisExamCheckKit",
            dependencies: [
                .product(name: "Starscream", package: "Starscream"),
                .product(name: "Account", package: "artemis-ios-core-modules"),
                .product(name: "APIClient", package: "artemis-ios-core-modules"),
                .product(name: "Common", package: "artemis-ios-core-modules"),
                .product(name: "DesignLibrary", package: "artemis-ios-core-modules"),
                .product(name: "Login", package: "artemis-ios-core-modules"),
                .product(name: "UserStore", package: "artemis-ios-core-modules"),
            ]),
        .testTarget(
            name: "ArtemisExamCheckKitTests",
            dependencies: ["ArtemisExamCheckKit"]),
    ]
)
