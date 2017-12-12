
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
    
    struct Keys {
        static let comment = "comment"
    }
    
    var comment = ""
    
    init(comment: String) {
        self.comment = comment
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.comment, comment)
        return row
    }
    
    init(row: Row) throws {
        try comment = row.get(Keys.comment)
    }
}

extension Comment: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { (builder) in
            builder.id()
            builder.string(Keys.comment)
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Comment: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            comment: try json.get(Keys.comment)
        )
    }
    
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set(Keys.comment, comment)
        return json
    }
    
    func makeFullJSON() throws -> JSON {
        var json = try makeJSON()
        // Make More
        return json
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
