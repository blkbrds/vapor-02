//
//  Auth.swift
//  App
//
//  Created by hai phung on 12/5/17.
//

import Vapor
import FluentProvider
import AuthProvider

final class Auth: Model {

    // MARK: - Properties
    let storage = Storage()

    // Email or username
    var username: String
    var password: String

    var userId: Identifier

    struct Keys {
        static let authUsername = "username"
        static let authPassword = "password"
        static let userId = "user_id"
    }

    init(username: String, password: String, user: User) throws {
        self.userId = try user.assertExists()
        self.username = username
        self.password = password
    }

    init(row: Row) throws {
        username = try row.get(Keys.authUsername)
        password = try row.get(Keys.authPassword)
        userId = try row.get(Keys.userId)
    }

    // Serializes
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.authUsername, username)
        try row.set(Keys.authPassword, password)
        try row.set(Keys.userId, userId)
        return row
    }
}

extension Auth: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Keys.authUsername, length: 255)
            builder.string(Keys.authPassword, length: 255)
            builder.parent(User.self, optional: false, foreignIdKey: Keys.userId)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Auth: JSONRepresentable {

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.authUsername, username)
        try json.set("user", user.get())
        return json
    }
}

extension Auth: ResponseRepresentable { }

// MARK: Parent
extension Auth {
    var user: Parent<Auth, User> {
        return parent(id: userId)
    }
}

extension Auth: TokenAuthenticatable {
    typealias TokenType = Session

    static let tokenKey = Session.Keys.accessToken
}

