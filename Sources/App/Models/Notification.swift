//
//  Notification.swift
//  VaporApiPackageDescription
//
//  Created by Quang Dang N.K on 12/17/17.
//

import Vapor
import FluentProvider
import HTTP

final class Notification: Model {
    let storage = Storage()
    
    struct Keys {
        static let description = "description"
        static let title = "title"
        static let type = "type"
    }
    
    var description = ""
    var title = ""
    var type: Int?
    
    init(description: String, title: String, type: Int?) {
       self.description = description
        self.title = title
        self.type = type
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.description, description)
        try row.set(Keys.title, title)
        try row.set(Keys.type, type)
        return row
    }
    
    init(row: Row) throws {
        description = try row.get(Keys.description)
        title = try row.get(Keys.title)
        type = try row.get(Keys.type)
    }
}

extension Notification: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { (builder) in
            builder.id()
            builder.string(Keys.description)
            builder.string(Keys.title)
            builder.int(Keys.type)
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Notification: JSONConvertible {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.description, description)
        try json.set(Keys.title, title)
        try json.set(Keys.type, type)
        return json
    }

    convenience init(json: JSON) throws {
        self.init(
            description: try json.get(Keys.description),
            title: try json.get(Keys.title),
            type: try json.get(Keys.type)
        )
    }
}
