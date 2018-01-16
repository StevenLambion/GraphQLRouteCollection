// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GraphQLRouteCollection",
    products: [
        .library(
            name: "GraphQLRouteCollection",
            targets: ["GraphQLRouteCollection"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.1.0")),
        .package(url: "https://github.com/GraphQLSwift/GraphQL.git", .upToNextMajor(from: "0.3.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "GraphQLRouteCollection",
            dependencies: ["Vapor", "GraphQL"]),
        .testTarget(
            name: "GraphQLRouteCollectionTests",
            dependencies: ["GraphQLRouteCollection"]),
    ]
)
