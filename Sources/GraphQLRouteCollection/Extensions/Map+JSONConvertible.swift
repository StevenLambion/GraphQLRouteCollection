// Adds compatibilty of vapor's JSON object to GraphQL's map to handle request data.

import GraphQL
import Vapor

extension Map: JSONConvertible {

    public init(json: JSON) throws {
        try self.init(json.wrapped)
    }

    public init(_ structuredData: StructuredData) throws {
        switch structuredData {
        case .null:
            self = Map.null
        case .bool(let bool):
            self = Map.bool(bool)
        case .number(let number):
            switch number {
            case .double(let double):
                self = Map.double(double)
            case .int(let int):
                self = Map.int(int)
            case .uint(let uint):
                self = Map.int(Int(uint))
            }
        case .string(let string):
            self = Map.string(string)
        case .bytes(let bytes):
            self = try bytes.asMap()
        case .date(let date):
            self = Map.string(String(describing: date))
        case .array(let array):
            self = Map.array(try array.map { try Map($0) })
        case .object(let ob):
            self = Map.dictionary(try ob.reduce(into: [:]) { (result, info) in result[info.key] = try Map(info.value) })
        }
    }

    public func makeJSON() throws -> JSON {
        return JSON(try self.asStructuredData())
    }

    public func asStructuredData() throws -> StructuredData {
        switch self {
        case .null:
            return StructuredData.null
        case .bool(let bool):
            return StructuredData.bool(bool)
        case .double(let double):
            return StructuredData.number(.double(double))
        case .int(let int):
            return StructuredData.number(.int(int))
        case .string(let string):
            return StructuredData.string(string)
        case .array(let array):
            return StructuredData.array(try array.map { try $0.asStructuredData() })
        case .dictionary(let ob):
            return StructuredData.object(try ob.reduce(into: [:]) { (result, info) in result[info.key] = try info.value.asStructuredData() })
        }
    }

}
