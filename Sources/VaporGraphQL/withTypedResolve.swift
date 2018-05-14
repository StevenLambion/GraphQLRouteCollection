/// Wraps resolvers to provide better type support when working with GraphQL.

import GraphQL

enum TypedFieldResolveError: Error {
  case InvalidType
}

public typealias TypedTypeResolver1<Value, Result: TypeResolveResultRepresentable> = (
  _ value: Value
  ) throws -> Result

public typealias TypedTypeResolver2<Value, Context, Result: TypeResolveResultRepresentable> = (
  _ value: Value,
  _ context: Context
  ) throws -> Result

public typealias TypedTypeResolver3<Value, Context, Result: TypeResolveResultRepresentable> = (
  _ value: Value,
  _ context: Context,
  _ info: GraphQLResolveInfo
  ) throws -> Result

public typealias TypedFieldResolver1<Source, Result> = (
  _ source: Source,
  _ args: Map
  ) throws -> Result?

public typealias TypedFieldResolver2<Source, Context, Result> = (
  _ source: Source,
  _ args: Map,
  _ context: Context
  ) throws -> Result?

public typealias TypedFieldResolver3<Source, Context, Result> = (
  _ source: Source,
  _ args: Map,
  _ context: Context,
  _ info: GraphQLResolveInfo
  ) throws -> Result?

public func withTypedResolve<Source, Result>(resolver: @escaping TypedFieldResolver1<Source, Result>) -> GraphQLFieldResolve {
  return { (source: Any, args: Map, context: Any, info: GraphQLResolveInfo) throws in
    guard let typedSource = source as? Source else {
      throw TypedFieldResolveError.InvalidType
    }
    return try resolver(typedSource, args)
  }
}

public func withTypedResolve<Source, Context, Result>(resolver: @escaping TypedFieldResolver2<Source, Context, Result>) -> GraphQLFieldResolve {
  return { (source: Any, args: Map, context: Any, info: GraphQLResolveInfo) throws in
    guard
      let typedSource = source as? Source,
      let typedContext = context as? Context else {
        throw TypedFieldResolveError.InvalidType
    }
    return try resolver(typedSource, args, typedContext)
  }
}

public func withTypedResolve<Source, Context, Result>(resolver: @escaping TypedFieldResolver3<Source, Context, Result>) -> GraphQLFieldResolve {
  return { (source: Any, args: Map, context: Any, info: GraphQLResolveInfo) throws in
    guard
      let typedSource = source as? Source,
      let typedContext = context as? Context else {
        throw TypedFieldResolveError.InvalidType
    }
    return try resolver(typedSource, args, typedContext, info)
  }
}

public func withTypedResolve<Value, Result: TypeResolveResultRepresentable>(
  resolver: @escaping TypedTypeResolver1<Value, Result>
) throws -> GraphQLTypeResolve {
  return { (value: Any, context: Any, info: GraphQLResolveInfo) throws in
    guard let typedValue = value as? Value else {
      throw TypedFieldResolveError.InvalidType
    }
    return try resolver(typedValue)
  }
}

public func withTypedResolve<Value, Context, Result: TypeResolveResultRepresentable>(
  resolver: @escaping TypedTypeResolver2<Value, Context, Result>
) throws -> GraphQLTypeResolve {
  return { (value: Any, context: Any, info: GraphQLResolveInfo) throws in
    guard
      let typedValue = value as? Value,
      let typedContext = context as? Context else {
        throw TypedFieldResolveError.InvalidType
    }
    return try resolver(typedValue, typedContext)
  }
}

public func withTypedResolve<Value, Context, Result: TypeResolveResultRepresentable>(
  resolver: @escaping TypedTypeResolver3<Value, Context, Result>
  ) throws -> GraphQLTypeResolve {
  return { (value: Any, context: Any, info: GraphQLResolveInfo) throws in
    guard
      let typedValue = value as? Value,
      let typedContext = context as? Context else {
        throw TypedFieldResolveError.InvalidType
    }
    return try resolver(typedValue, typedContext, info)
  }
}
