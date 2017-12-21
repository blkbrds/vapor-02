//
//  AuthMethod.swift
//  MyApp
//
//  Created by Mylo Ho on 7/18/17.
//
//

import Vapor
import FluentProvider
import HTTP

final class AuthMethod: Model {

    // MARK: Properties
    let storage = Storage()
    var name: String
    var description: String

    // MARK: - Database keys
    struct Keys {
        static let name = "name"
        static let description = "description"
    }

    // MARK: - Init
    init(name: String, description: String) {
        self.name = name
        self.description = description
    }

    // MARK: Fluent Serialization
    init(row: Row) throws {
        name = try row.get(Keys.name)
        description = try row.get(Keys.description)
    }

    // Serializes
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.name, name)
        try row.set(Keys.description, description)
        return row
    }
}

// MARK: Fluent Preparation
extension AuthMethod: Preparation {
    /// Prepares a table/collection in the database
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Keys.name, length: 255)
            builder.string(Keys.description, length: 255)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON
extension AuthMethod: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(idKey, id)
        try json.set(Keys.name, name)
        try json.set(Keys.description, description)
        return json
    }
}

// MARK: HTTP
extension AuthMethod: ResponseRepresentable { }

// MARK: Children
extension AuthMethod {
    
    var auths: Children<AuthMethod, Auth> {
        return children(foreignIdKey: Auth.Keys.authMethodId)
    }
}

// MARK: Equatable
extension AuthMethod: Equatable {
    static func == (lhs: AuthMethod, rhs: AuthMethod) -> Bool {
        return lhs.name == rhs.name && lhs.description == rhs.description
    }
}
