# GraphQLRouteCollection

Provides a simple route collection to integrate [GraphQLSwift](https://github.com/GraphQLSwift/GraphQL) into a Vapor application.

[![Travis][travis-badge]][travis-url]
[![Swift][swift-badge]][swift-url]
[![License][mit-badge]][mit-url]

## Installation

Add VaporGraphQL to your `Package.swift`

```swift
import PackageDescription

let package = Package(
    dependencies: [
        ...
        .package(url: "https://github.com/stevenlambion/vapor-graphql.git", .upToNextMajor(from: "0.1.0")),
    ],
    .target(
        name: "App",
        dependencies: [..., "VaporGraphQL"],
    ),
)
```

## Usage

### Basic

Create a new HTTPGraphQL service with your schema, then register it:

```swift
services.register(HTTPGraphQL() { req in (
  schema: schema,
  rootValue: [:],
  context: req
)});
```

Then use it in your app's routing:

```swift
let router = app.make(Router.self)
let graphql = app.make(GraphQLService.self)

router.get("/graphql") { req in
  return graphql.execute(req)
}
router.post("/graphql") { req in
  return graphql.execute(req)
}
```

### Introspection

HTTPGraphQL provides a way to introspect the entire graphql schema. This is useful in development when you need to auto-generate a schema for graphql clients.

```swift
let graphql = HTTPGraphQL(enableIntrospectionQuery: true) { req in (
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

HTTPGraphQL will use the request's method to determine how to retrieve the graphql query. For GET requests, it uses the query items in the URL. For POSTs, it uses the payload.

### GraphQLRouteCollection

Provides a simple means to setup typical GraphQL endpoints for both GET and POST requests.

```swift
let graphql = app.make(GraphQLService.self)
let graphQLRoutes = GraphQLRouteCollection()
```

### GraphiQL

HTTPGraphQL provides a method to return a [GraphiQL](https://github.com/graphql/graphiql) HTML view.

```swift
router.get("/graphiql") { req in
  return graphql.renderGraphiQL(pathToGraphQL: "/graphql")
}
```

You can also enable it for the route collection:

```swift
GraphQLRouteCollection(enableGraphiQL: true)
```

### Type Safety

The Swift GraphQL library does not provide a fully type safe environment currently. To mitigate this, there's a `withTypedResolve()` decorator function to wrap resolvers that provide typed sources and context objects. This function has multiple overloads for both field and type resolvers. The function helps to provide better type support in development and runtime checking of the GraphQL API.

```swift
let UserType = try! GraphQLObjectType(
  name: "User",
  fields: [
    "id": GraphQLField(type: GraphQLNonNull(GraphQLID)),
    "email": GraphQLField(type: GraphQLNonNull(GraphQLString)),
    "role": GraphQLField(
      type: UserRoleType,
      resolve: withTypedResolve { (user: User, _,) -> Role in
        try user.role.get().wait()
      })
  ]
)
```

### Async Support

Vapor 3 has a strong focus on async, however, the Swift GraphQL library hasn't implemented this functionality yet. To mitigate this problem the HTTPGraphQL service runs executions using GCD so as not to block the NIO event loop. It also uses the concurrency strategy for queries and subscriptions for parallel field resolving.

For async resolvers, a `resolveWithFuture()` decorator is provided. This allows resolvers to work with async code based on Swift NIO as they typically would in Vapor. `resolveWithFuture()` works by waiting for the results under an async queue separate from the NIO event loop. `resolveWithFuture()` is composed using the `withTypedResolve()` decorator, so it also includes type handling.

```swift
let UserType = try! GraphQLObjectType(
  name: "User",
  fields: [
    "id": GraphQLField(type: GraphQLNonNull(GraphQLID)),
    "email": GraphQLField(type: GraphQLNonNull(GraphQLString)),
    "role": GraphQLField(
      type: UserRoleType,
      resolve: resolveWithFuture { (user: User, _,) -> Future<Role> in
        try user.role.get()
      })
  ]
)
```

## License

This project is released under the MIT license. See [LICENSE](LICENSE) for details.

[swift-badge]: https://img.shields.io/badge/Swift-4.1-orange.svg?style=flat
[swift-url]: https://swift.org
[mit-badge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat
[mit-url]: https://tldrlegal.com/license/mit-license
[travis-badge]: https://travis-ci.org/StevenLambion/GraphQLRouteCollection.svg?branch=master
[travis-url]: https://travis-ci.org/StevenLambion/GraphQLRouteCollection
