import Vapor
import GraphQL
import Graphiti

public typealias ExecutionContext = (
  schema: GraphQLSchema,
  rootValue: Any,
  context: Any
)

/// Provides HTTPGraphQL an execution context to perform per request.
public typealias ExecutionContextProvider = (Request) throws -> ExecutionContext

public struct HTTPGraphQL: GraphQLService {
  
  /// Provides the schema based off the given request.
  public let executionContextProvider: ExecutionContextProvider
  
  /// If enabled, HTTPGraphQL returns an introspection of the GraphQL Schema if
  /// given an empty query.
  public let enableIntrospection: Bool
  
  public init(
    enableIntrospection: Bool = true,
    executionContextProvider: @escaping ExecutionContextProvider)
  {
    self.executionContextProvider = executionContextProvider
    self.enableIntrospection = enableIntrospection
  }
  
  public func execute(_ executionRequest: GraphQLExecutionRequest, for req: Request) -> Future<Map> {
    if executionRequest.query == "" && executionRequest.variables.isEmpty && self.enableIntrospection {
      return self.executeIntrospectionQuery(for: req)
    }
      do {
        let (schema, rootValue, context) = try self.executionContextProvider(req)
        let result = try graphql(
                    schema: schema, 
                    request: executionRequest.query, 
                    rootValue: rootValue, 
                    context: context, 
                    eventLoopGroup: req, 
                    variableValues: executionRequest.variables, 
                    operationName: executionRequest.operationName)
        return result
      } catch let e as GraphQLError {
        let graphQLError: [String: Map] = [
                  "data": [
                    "errors": [e.map]
                  ]
                ]
        let map = Map.dictionary(graphQLError)
        return req.future(map)
      } catch let e {
        return req.future(error: e)
      }
  }
  
}
