/// Make Map a Content type, so it can be returned as a response.

import GraphQL
import Vapor

extension Map: Content {}
