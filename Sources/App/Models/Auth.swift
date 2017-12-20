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
    var authId: String
    var authToken: String

    var userId: Identifier
    var authMethodId: Identifier

    struct Keys {
        static let authId = "authId"
        static let authToken = "authToken"
        static let userId = "userId"
        static let authMethodId = "authMethodId"
        static let user = "user"
        static let authMethod = "authMethod"
    }

    init(authId: String, authToken: String, user: User, authMethod: AuthMethod) throws {
        authMethodId = try authMethod.assertExists()
        self.userId = try user.assertExists()
        self.authId = authId
        self.authToken = authToken
    }

    init(row: Row) throws {
        authId = try row.get(Keys.authId)
        authToken = try row.get(Keys.authToken)
        userId = try row.get(Keys.userId)
        authMethodId = try row.get(Keys.authMethodId)
    }

    // Serializes
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.authId, authId)
        try row.set(Keys.authToken, authToken)
        try row.set(Keys.authMethodId, authMethodId)
        try row.set(Keys.userId, userId)
        return row
    }
}

extension Auth: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Keys.authId, length: 255)
            builder.string(Keys.authToken, length: 255)
            builder.parent(AuthMethod.self, optional: false, foreignIdKey: Keys.authMethodId)
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
        try json.set(Keys.authId, authId)
        try json.set(Keys.user, user.get())
        try json.set(Keys.authMethod, authMethod.get())
        return json
    }
}

extension Auth: ResponseRepresentable { }

// MARK: Parent
extension Auth {
    var user: Parent<Auth, User> {
        return parent(id: userId)
    }

    var authMethod: Parent<Auth, AuthMethod> {
        return parent(id: authMethodId)
    }
}

extension Auth: TokenAuthenticatable {
    typealias TokenType = Session

    static let tokenKey = Session.Keys.accessToken
}

