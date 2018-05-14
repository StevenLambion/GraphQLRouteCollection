/// Wrap resolver functions that return a promise, so they work correctly with
/// the GraphQL executor.  They assume the initial execution happens within a future
/// using the concurrent strategy.

import GraphQL
import Vapor

public func resolveWithFuture<Source, Result>(resolver: @escaping TypedFieldResolver1<Source, Future<Result?>>) throws -> GraphQLFieldResolve {
  return withTypedResolve { (source: Source, args: Map) -> Result? in
    try resolver(source, args)?.wait()
  }
}

public func resolveWithFuture<Source, Context, Result>(
  resolver: @escaping TypedFieldResolver2<Source, Context, Future<Result?>>
) throws -> GraphQLFieldResolve {
  return withTypedResolve { (source: Source, args: Map, context: Context) -> Result? in
    try resolver(source, args, context)?.wait()
  }
}

public func resolveWithFuture<Source, Context, Result>(
  resolver: @escaping TypedFieldResolver3<Source, Context, Future<Result?>>
) throws -> GraphQLFieldResolve {
  return withTypedResolve { (source: Source, args: Map, context: Context, info: GraphQLResolveInfo) -> Result? in
    try resolver(source, args, context, info)?.wait()
  }
}
