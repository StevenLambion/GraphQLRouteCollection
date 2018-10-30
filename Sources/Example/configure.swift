import Vapor
import VaporGraphQL
import StarWars

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Vapor.Environment, _ services: inout Services) throws {
    let httpGraphQL = HTTPGraphQL() { req in
        return ExecutionContext(
            schema: starWarsSchema,
            eventLoopGroup: req
        )
    }
    services.register(httpGraphQL, as: GraphQLService.self)
    
    /// Register routes to the router
    let router = EngineRouter.default()
    let graphQLRouteCollection = GraphQLRouteCollection(enableGraphiQL: true)
    try graphQLRouteCollection.boot(router: router)
    try routes(router)
    services.register(router, as: Router.self)
    
    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
}
