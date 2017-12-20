//
//  JSONExt.swift
//  VaporApiPackageDescription
//
//  Created by Quang Dang N.K on 12/12/17.
//

extension JSON {
    init(data: JSON) throws {
        try self.init(node: ["data": data])
    }

    func dataJSON() throws -> JSON {
        return try JSON(data: self)
    }
    
    init(meta: Meta, data: JSON) throws {
        try self.init(node: ["meta": meta.makeJSON(), "data": data])
    }
}
