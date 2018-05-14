// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VaporGraphQL",
    products: [
        .library(
            name: "VaporGraphQL",
            targets: ["VaporGraphQL"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/GraphQLSwift/GraphQL.git", .upToNextMajor(from: "0.5.0"))
    ],
    targets: [
        .target(
            name: "VaporGraphQL",
            dependencies: ["Vapor", "GraphQL"]),
        .testTarget(
            name: "VaporGraphQLTests",
            dependencies: ["VaporGraphQL"]),
    ]
)
