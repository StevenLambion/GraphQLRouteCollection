import Vapor
import VaporGraphQL
import GraphQL

public let application = try app(.detect())
try application.run()
