//
//  UserController.swift
//  App
//
//  Created by Lam Le V. on 12/12/17.
//

import Vapor
import FluentProvider
import HTTP

final class User: Model {

    let storage = Storage()

    struct Keys {
        static let id = "id"
        static let name = "name"
        static let description = "description"
        static let website = "website"
    }

    var name: String
    var description: String
    var website: String

    init(name: String, description: String, website: String) {
        self.name = name
        self.description = description
        self.website = website
    }

    init(row: Row) throws {
        name = try row.get(Keys.name)
        description = try row.get(Keys.description)
        website = try row.get(Keys.website)
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.name, name)
        try row.set(Keys.description, description)
        try row.set(Keys.website, website)
        return row
    }
}

extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { builder in
            builder.id()
            builder.string(Keys.name)
            builder.string(Keys.description)
            builder.string(Keys.website)
        })
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension User: JSONConvertible {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.name, name)
        try json.set(Keys.description, description)
        try json.set(Keys.website, website)
        return json
    }

    convenience init(json: JSON) throws {
        self.init(
            name: try json.get(Keys.name),
            description: try json.get(Keys.description),
            website: try json.get(Keys.website)
        )
    }
}

extension User {
    var comments: Children<User, Comment> {
        return children()
    }
}

extension User: ResponseRepresentable {}
