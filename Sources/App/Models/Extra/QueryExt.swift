//
//  QueryExt.swift
//  VaporReferenceDemoPackageDescription
//
//  Created by Quang Dang N.K on 12/6/17.
//

import Fluent

extension QueryRepresentable where Self: ExecutorRepresentable {
    @discardableResult
    public func page(limit: Int = 20, _ page: Int) throws -> Query<E> {
        let query = try makeQuery()
        if page < 1 {
            return query
        }
        let limit = Limit(count: limit, offset: (page - 1) * Meta.maxItems)
        try query.limit(limit)
        return query
    }
}
