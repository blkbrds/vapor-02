//
//  Favorite.swift
//  App
//
//  Created by Quang Dang N.K on 12/12/17.
//

import Vapor
import FluentProvider
import HTTP

final class Favorite: Model {
    let storage = Storage()
    
    struct Keys {
        static let name = "name"
    }
    
    var name = ""
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.name, name)
        return row
    }
    
    init(row: Row) throws {
        try name = row.get(Keys.name)
    }
    
    init() {}
}

extension Favorite: Preparation {
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

extension Favorite: JSONConvertible {

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.name, name)
        return json
    }
    
    convenience init(json: JSON) throws {
        self.init()
    }
}

extension Favorite: ResponseRepresentable {}
