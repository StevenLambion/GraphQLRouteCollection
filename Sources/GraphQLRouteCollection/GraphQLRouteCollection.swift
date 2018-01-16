import Vapor
import Routing
import GraphQL

public typealias SchemaContext = (
    schema: GraphQLSchema,
    rootValue: Any,
    context: Any
)

public typealias SchemaProvider = (Request) -> SchemaContext

public final class GraphQLRouteCollection: RouteCollection {
    /// Path to the graphql route
    public let path: String

    /// Enables the GraphiQL webpage
    public let enableGraphiQL: Bool

    /// Enables the GraphiQL webpage
    public let enableIntrospectionQuery: Bool

    /// Provides the schema based off the given request.
    public let schemaProvider: SchemaProvider

    public init(_ path: String = "graphql", enableGraphiQL: Bool = false, enableIntrospectionQuery: Bool = true, schemaProvider: @escaping SchemaProvider) {
        self.path = path
        self.enableGraphiQL = enableGraphiQL
        self.enableIntrospectionQuery = enableIntrospectionQuery
        self.schemaProvider = schemaProvider
    }

    public func build(_ builder: RouteBuilder) {
        let graphql = builder.grouped(path)
        graphql.get(handler: self.executeGet)
        graphql.post(handler: self.executePost)
    }

    func executeGet(_ req: Request) throws -> ResponseRepresentable {
        let accepts = Set(req.accept.map { $0.mediaType })
        if accepts.contains("text/html") {
            if enableGraphiQL {
                return try self.renderGraphiQL(for: req)
            }
            return Response(status: .unsupportedMediaType)
        }
        return try self.executeGetQuery(req)
    }

    func executeGetQuery(_ req: Request) throws -> ResponseRepresentable {
        guard let searchQuery = req.query else {
            return try enableIntrospectionQuery ? self.executeIntrospectionQuery(withRequest: req) : Response(status: .methodNotAllowed)
        }
        guard let query = searchQuery["query"]?.string else {
            return Response(status: .badRequest, body: "Missing valid query parameter")
        }
        var variables: JSON = [:]
        if let rawVariables = searchQuery["variables"]?.string {
            variables = JSON(rawVariables)
        }
        let operationName = searchQuery["operationName"]?.string
        return try self.execute(for: req, query: query, variables: variables, operationName: operationName)
    }

    func executePost(_ req: Request) throws -> ResponseRepresentable {
        guard let payload = req.json else {
            return Response(status: .badRequest, body: "Invalid JSON")
        }
        let query: String = try payload.get("query")
        let variables: JSON = try payload.get("variables")
        var operationName: String? = nil;
        do {
            operationName = try payload.get("operationName")
        }
        return try self.execute(for: req, query: query, variables: variables, operationName: operationName)
    }

    func execute(for req: Request, query: String, variables: JSON, operationName: String? = nil) throws -> ResponseRepresentable {
        let (schema, rootValue, context) = self.schemaProvider(req)
        do {
            return try graphql(
                schema: schema,
                request: query,
                rootValue: rootValue,
                contextValue: context,
                variableValues: try Map(json: variables).dictionary ?? [:],
                operationName: operationName)
        } catch let e as GraphQLError {
            return try [
                "data": [
                    "errors": [e.map]
                ]
            ].asMap()
        }
    }

}
