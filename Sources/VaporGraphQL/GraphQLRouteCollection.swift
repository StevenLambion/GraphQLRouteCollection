import Vapor
import Routing
import GraphQL

/// Simple collection of graphql endpoints designed for the most common use case.
public struct GraphQLRouteCollection: RouteCollection {
  /// Path to the graphql route
  public let path: String

  /// Enables the GraphiQL webpage
  public let enableGraphiQL: Bool

  /// Path to GraphiQL. Defaults to "/graphiql"
  public let graphiQLPath: String

  public init(_ path: String = "graphql", enableGraphiQL: Bool = false, graphiQLPath: String = "graphiql") {
    self.path = path
    self.enableGraphiQL = enableGraphiQL
    self.graphiQLPath = graphiQLPath
  }

  public func boot(router: Router) throws {
    let graphql = router.grouped(path)
    graphql.get("", use: self.execute)
    graphql.post("", use: self.execute)
    if enableGraphiQL {
      router.get(graphiQLPath, use: self.renderGraphiQL)
    }
  }

  private func execute(_ req: Request) throws -> Future<Map> {
    let graphql = try req.make(GraphQLService.self)
    return try graphql.execute(req)
  }

  private func renderGraphiQL(_ req: Request) throws -> View {
    let graphql = try req.make(GraphQLService.self)
    return try graphql.renderGraphiQL(pathToGraphQL: path, for: req)
  }
}
