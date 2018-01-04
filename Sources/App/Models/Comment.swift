
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
    var comment = ""
    var userId: Identifier
    var restaurantId: Identifier
    
    struct Keys {
        static let id = "id"
        static let comment = "comment"
        static let userId = "user_id"
        static let restaurantId = "restaurant_id"
    }

    init(comment: String, user: User, restaurant: Restaurant) throws {
        self.comment = comment
        userId = try user.assertExists()
        restaurantId = try restaurant.assertExists()
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.comment, comment)
        try row.set(Keys.userId, userId)
        try row.set(Keys.restaurantId, restaurantId)
        return row
    }
    
    init(row: Row) throws {
        comment = try row.get(Keys.comment)
        userId = try row.get(Keys.userId)
        restaurantId = try row.get(Keys.restaurantId)
    }
}

extension Comment: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { builder in
            builder.id()
            builder.string(Keys.comment)
            builder.parent(User.self, optional: false)
            builder.parent(Restaurant.self, optional: false)
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Comment: JSONRepresentable {
    convenience init(json: JSON) throws {
        let userId: Identifier = try json.get(Keys.userId)
        let restaurantId: Identifier = try json.get(Keys.restaurantId)
        guard let user = try User.find(userId),
            let restaurant = try Restaurant.find(restaurantId) else {
            throw Abort.notFound
        }
        try self.init(comment: json.get(Keys.comment), user: user, restaurant: restaurant)
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

    var restaurant: Parent<Comment, Restaurant> {
        return parent(id: restaurantId)
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
