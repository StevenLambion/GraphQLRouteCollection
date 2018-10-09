import Vapor
import GraphQL

/// Request object to submit a graphql query to be executed. This is generated
/// by vapor from an http request's payload.
public struct GraphQLExecutionRequest: Content {
  let query: String
  let variables: [String:Map]
  let operationName: String?
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    query = try container.decode(String.self, forKey: .query)
    // the decoder has trouble decoding a nil `[String: Map]`, so we'll use an optional throw.
    variables = (try? container.decode([String: Map].self, forKey: .variables)) ?? [:]
    operationName = try? container.decode(String.self, forKey: .operationName)
  }
    
  init(query: String, variables: [String:Map]?, operationName: String?) {
    self.query = query
    self.variables = variables ?? [:]
    self.operationName = operationName
  }
  
  /// Initiates a new request from a URL. It decodes the URL's query items. This
  /// is required as req.query.decode isn't yet able to decode json values in query items.
  init (url: URL) throws {
    let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    var query = "";
    var variables = [String:Map]();
    var operationName: String?;
    try components?.queryItems?.forEach { item throws in
      if let value = item.value {
        switch (item.name) {
        case "query":
          query = value
        case "variables":
          let decoder = JSONDecoder()
          if let jsonData = value.data(using: .utf16, allowLossyConversion: false) {
            variables = try decoder.decode([String:Map].self, from: jsonData)
          }
        case "operationName":
          operationName = value
        default:
          break
        }
      }
    }
    self.init(query: query, variables: variables, operationName: operationName)
  }
}
