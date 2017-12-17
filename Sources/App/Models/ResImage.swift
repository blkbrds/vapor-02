//
//  ResImage.swift
//  VaporApiPackageDescription
//
//  Created by Quang Dang N.K on 12/13/17.
//

import Vapor
import FluentProvider
import HTTP

final class ResImage: Model {
    let storage = Storage()
    
    struct Keys {
        static let name = "name"
        static let imageId = "image_id"
    }
    
    var name = ""
    var imageId: Identifier
    
    init(name: String, imageId: Identifier) {
        self.name = name
        self.imageId = imageId
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.name, name)
        try row.set(Keys.imageId, imageId)
        return row
    }
    
    init(row: Row) throws {
        try name = row.get(Keys.name)
        try imageId = row.get(Keys.imageId)
    }
}

extension ResImage: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { (builder) in
            builder.id()
            builder.string(Keys.name)
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension ResImage: JSONConvertible {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.name, name)
        try json.set(Keys.imageId, imageId)
        return json
    }
    
    convenience init(json: JSON) throws {
        self.init(
            name: try json.get(Keys.name),
            imageId: try json.get(Keys.imageId)
        )
    }
}
