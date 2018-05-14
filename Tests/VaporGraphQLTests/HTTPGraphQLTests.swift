import XCTest
@testable import VaporGraphQL
import Vapor
import HTTP
import GraphQL

func urlEncode(_ stringToEncode: String) -> String {
  return stringToEncode.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
}

func createHTTPGraphQL() -> HTTPGraphQL {
  return HTTPGraphQL() { req in
    (
      schema: StarWarsSchema,
      rootValue: [:],
      context: req
    )
  }
}

func performRequest(httpRequest: HTTPRequest) throws -> Map {
  let collection = createHTTPGraphQL()
  let request = Request(http: httpRequest, using: try Application())
  return try collection.execute(request).wait()
}

func performGETRequest(query: String, variables: [String:Any]? = nil, operationName: String? = nil) throws -> Map {
  var urlComponents = URLComponents(string: "http://localhost:8080/graphql")!
  var queryItems = [URLQueryItem]()
  queryItems.append(URLQueryItem(name: "query", value: query))
  if let variables = variables {
    let json = String(data: try JSONSerialization.data(withJSONObject: variables), encoding: String.Encoding.utf8)!
    queryItems.append(URLQueryItem(name: "variables", value: json))
  }
  if let operationName = operationName {
    queryItems.append(URLQueryItem(name: "operationName", value: operationName))
  }
  urlComponents.queryItems = queryItems
  var httpRequest = HTTPRequest(
    method: .GET,
    url: urlComponents.url!
  )
  httpRequest.contentType = .json
  return try performRequest(httpRequest: httpRequest)
}

func performPOSTRequest(query: String, variables: [String:Any] = [:], operationName: String? = nil) throws -> Map {
  var json: [String: Any] = [
    "query": query,
    "variables": variables
  ];
  if let operationName = operationName {
    json["operationName"] = operationName
  }
  let data = try JSONSerialization.data(withJSONObject: json)
  var httpRequest = HTTPRequest(
    method: .POST,
    body: data
  )
  httpRequest.contentType = .json
  return try performRequest(httpRequest: httpRequest)
}

class HTTPGraphQLTests: XCTestCase {

  func testQueryWithGET() throws {
    let query = """
      query HeroQuery {
        hero {
          id
          name
        }
      }
    """;
    let expected: Map = [
      "data": [
        "hero": [
          "id": "2001",
          "name": "R2-D2"
        ]
      ]
    ]
    let result = try performGETRequest(query: query)
    XCTAssertEqual(result, expected)
  }

  func testVariablesWithGET() throws {
    let query = """
      query HeroQuery($episode: Episode) {
        hero(episode: $episode) {
          id
          name
        }
      }
    """;
    let variables = ["episode": "EMPIRE"]
    let expected: Map = [
      "data": [
        "hero": [
          "id": "1000",
          "name": "Luke Skywalker"
        ]
      ]
    ]
    let result = try performGETRequest(query: query, variables: variables)
    XCTAssertEqual(result, expected)
  }

  func testQueryWithPOST() throws {
    let query = """
      query HeroQuery {
        hero {
          id
          name
        }
      }
    """;
    let expected: Map = [
      "data": [
        "hero": [
          "id": "2001",
          "name": "R2-D2"
        ]
      ]
    ]
    let result = try performPOSTRequest(query: query)
    XCTAssertEqual(result, expected)
  }

  func testVariablesWithPOST() throws {
    let query = """
      query HeroQuery($episode: Episode) {
        hero(episode: $episode) {
          id
          name
        }
      }
    """;
    let variables = ["episode": "EMPIRE"]
    let expected: Map = [
      "data": [
        "hero": [
          "id": "1000",
          "name": "Luke Skywalker"
        ]
      ]
    ]
    let result = try performPOSTRequest(query: query, variables: variables)
    XCTAssertEqual(result, expected)
  }

  static var allTests = [
    testQueryWithGET,
    testVariablesWithGET,
    testVariablesWithPOST]
}
