//
//  UserController.swift
//  App
//
//  Created by Lam Le V. on 12/12/17.
//

import Vapor
import FluentProvider
import HTTP
import AuthProvider

final class User: Model {

    let storage = Storage()

    struct Keys {
        static let id = "id"
        static let name = "name"
        static let email = "email"
        static let avatar = "image"
    }

    var name: String
    var email: String
    var avatar: String?

    init(name: String, email: String, avatar: String?) {
        self.name = name
        self.email = email
        self.avatar = avatar
    }

    init(row: Row) throws {
        name = try row.get(Keys.name)
        email = try row.get(Keys.email)
        avatar = try row.get(Keys.avatar)
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.name, name)
        try row.set(Keys.email, email)
        try row.set(Keys.avatar, avatar)
        return row
    }
}

extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { builder in
            builder.id()
            builder.string(Keys.name)
            builder.string(Keys.email)
            builder.string(Keys.avatar, optional: true)
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
        try json.set(Keys.email, email)
        try json.set(Keys.avatar, avatar)
        return json
    }

    convenience init(json: JSON) throws {
        self.init(
            name: try json.get(Keys.name),
            email: try json.get(Keys.email),
            avatar: try json.get(Keys.avatar)
        )
    }
}

extension User {
    var comments: Children<User, Comment> {
        return children()
    }

    var auths: Children<User, Auth> {
        return children(foreignIdKey: Auth.Keys.userId)
    }
}

extension User: ResponseRepresentable {}

extension User: TokenAuthenticatable {
    typealias TokenType = Session
    static let tokenKey = Session.Keys.accessToken
}
