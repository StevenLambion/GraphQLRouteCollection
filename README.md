# GraphQLRouteCollection

Provides a simple route collection to integrate [GraphQLSwift](https://github.com/GraphQLSwift/GraphQL) into a Vapor application.

[![Swift][swift-badge]][swift-url]
[![License][mit-badge]][mit-url]

## Installation

Add GraphQLRouteCollection to your `Package.swift`

```swift
import PackageDescription

let package = Package(
    dependencies: [
        ...
        .package(url: "https://github.com/stevenlambion/GraphQLRouteCollection.git", .upToNextMajor(from: "0.0.1")),
    ],
    .target(
        name: "App",
        dependencies: [..., "GraphQLRouteCollection"],
    ),
)
```

## Usage

Add the GraphQLRouteCollection to your droplet. Your schema, rootValue, and context are provided through a closure to allow per request dynamic execution. A common use case is setting up [dataloaders](https://github.com/facebook/dataloader) for each request.

### Basic

```swift
import Vapor
import GraphQLRouteCollection

extension Droplet {
    func setupRoutes() throws {

        // By default, the collection uses "graphql" as its path.
        // Pass a custom path as the first argument to change it.

        try collection(
            GraphQLRouteCollection() { req in (
                schema: schema,
                rootValue: [:],
                context: [:]
            )}
        )

    }
}
```

### GraphiQL

Enables the [GraphiQL](https://github.com/graphql/graphiql) IDE when a user accesses the graphql path in a web browser.

```swift
GraphQLRouteCollection(enableGraphiQL: true) { req in (
    schema: schema,
    rootValue: [:],
    context: [:]
)}
```

### Introspection Query

The route collection enables a quick way to introspect your entire graphql schema. This is useful in development when you need to auto-generate a schema for graphql clients such as Apollo. Here's an example of how to enable for development use.

```swift
GraphQLRouteCollection(enableIntrospectionQuery: true) { req in (
    schema: schema,
    rootValue: [:],
    context: [:]
)}
```

To retrieve the introspected schema simply hit the graphql endpoint without a provided query. It will instead use an internal introspection query.

```swift
  fetch("localhost:8080/graphql") { resp in
    let schema = parseSchema(resp.json)
  }
```

### The Kitchen Sink

```swift
GraphQLRouteCollection("graphql", enableGraphiQL: true, enableIntrospectionQuery: true) { req in (
    schema: schema,
    rootValue: [:],
    context: ["dataLoaders": createDataLoaders(req)]
)}
```

## License

This project is released under the MIT license. See [LICENSE](LICENSE) for details.

[swift-badge]: https://img.shields.io/badge/Swift-4-orange.svg?style=flat
[swift-url]: https://swift.org
[mit-badge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat
[mit-url]: https://tldrlegal.com/license/mit-license
[slack-image]: http://s13.postimg.org/ybwy92ktf/Slack.png
[slack-badge]: https://zewo-slackin.herokuapp.com/badge.svg
[slack-url]: http://slack.zewo.io
[travis-badge]: https://travis-ci.org/GraphQLSwift/GraphQL.svg?branch=master
[travis-url]: https://travis-ci.org/GraphQLSwift/GraphQL
[codecov-badge]: https://codecov.io/gh/GraphQLSwift/GraphQL/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/GraphQLSwift/GraphQL
[codebeat-badge]: https://codebeat.co/badges/13293962-d1d8-4906-8e62-30a2cbb66b38
[codebeat-url]: https://codebeat.co/projects/github-com-graphqlswift-graphql
