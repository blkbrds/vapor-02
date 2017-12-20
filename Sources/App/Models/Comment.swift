
//
//  File.swift
//  VaporApiPackageDescription
//
//  Created by Quang Dang N.K on 12/12/17.
//

import Vapor
import FluentProvider
import HTTP

final class Comment: Model {
    
    let storage = Storage()
    var userId: Identifier?
    
    struct Keys {
        static let id = "id"
        static let comment = "comment"
        static let userId = "user_id"
    }
    
    var comment = ""
    
    init(comment: String, user: User) {
        self.comment = comment
        self.userId = user.id
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.comment, comment)
        try row.set(User.foreignIdKey, userId)
        return row
    }
    
    init(row: Row) throws {
        comment = try row.get(Keys.comment)
        userId = try row.get(User.foreignIdKey)
    }
}

extension Comment: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { builder in
            builder.id()
            builder.string(Keys.comment)
            builder.parent(User.self)
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Comment: JSONConvertible {
    convenience init(json: JSON) throws {
        let userId: Identifier = try json.get(Keys.userId)
        guard let user = try User.find(userId) else {
            throw Abort.notFound
        }
        try self.init(comment: json.get(Keys.comment), user: user)
    }
    
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.id, id)
        try json.set(Keys.comment, comment)
        return json
    }
    
    func makeFullJSON() throws -> JSON {
        var json = try makeJSON()
        // Make More
        return json
    }
}

extension Comment {
    var user: Parent<Comment, User> {
        return parent(id: userId)
    }
}

extension Comment: Updateable {
    static var updateableKeys: [UpdateableKey<Comment>] {
        return [
            UpdateableKey(Keys.comment, String.self) { comment, commentString in
                comment.comment = commentString
            }
        ]
    }
}

extension Comment: ResponseRepresentable {}
