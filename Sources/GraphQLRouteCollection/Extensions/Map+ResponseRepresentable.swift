import GraphQL
import Vapor
import HTTP

extension Map: BodyRepresentable {

    public func makeBody() -> Body {
        return Body(String(describing:self))
    }

}

extension Map: ResponseRepresentable {

    public func makeResponse() throws -> Response {
        return Response(status: .ok, body: self)
    }

}
