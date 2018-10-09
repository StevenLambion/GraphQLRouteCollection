import Vapor
import GraphQL
import Graphiti

public struct ExecutionContext {
    public let schema: GraphQLSchema
    public let rootValue: Any
    public let context: Any
    public let eventLoopGroup: EventLoopGroup
    
    public init(schema: GraphQLSchema, rootValue: Any = (), context: Any = (), eventLoopGroup: EventLoopGroup) {
        self.schema = schema
        self.rootValue = rootValue
        self.context = context
        self.eventLoopGroup = eventLoopGroup
    }
}

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
        let executionContext = try self.executionContextProvider(req)
        let result = try graphql(
            schema: executionContext.schema, 
            request: executionRequest.query, 
            rootValue: executionContext.rootValue, 
            context: executionContext.context, 
            eventLoopGroup: executionContext.eventLoopGroup, 
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
