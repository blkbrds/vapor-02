//
//  Restaurant.swift
//  App
//
//  Created by hai phung on 12/1/17.
//

import Vapor
import FluentProvider

final class Restaurant: Model {

    let storage = Storage()

    var name: String
    var address: String
    var lat: Float
    var lng: Float
    var userId: Identifier

    init(name: String, address: String, lat: Float, lng: Float, userId: Identifier) throws {
        self.name = name
        self.address = address
        self.lat = lat
        self.lng = lng
        self.userId = userId
    }

    struct Keys {
        static let name = "name"
        static let address = "address"
        static let lat = "lat"
        static let lng = "lng"
        static let userId = "userId"
    }

    init(row: Row) throws {
        name = try row.get(Keys.name)
        address = try row.get(Keys.address)
        lat = try row.get(Keys.lat)
        lng = try row.get(Keys.lng)
        userId = try row.get(Keys.userId)
    }
}

extension Restaurant: RowRepresentable {

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.name, name)
        try row.set(Keys.address, address)
        try row.set(Keys.lat, lat)
        try row.set(Keys.lng, lng)
        try row.set(Keys.userId, userId)
        return row
    }
}

extension Restaurant: JSONConvertible {

    convenience init(json: JSON) throws {
        try self.init(
            name: try json.get(Keys.name),
            address: try json.get(Keys.address),
            lat: try json.get(Keys.lat),
            lng: try json.get(Keys.lng),
            userId: try json.get(Keys.userId)
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.name, name)
        try json.set(Keys.address, address)
        try json.set(Keys.lng, lng)
        try json.set(Keys.lat, lat)
        try json.set(Keys.userId, userId)
        try json.set("user", user.all().makeJSON())
        return try json.dataJSON()
    }
}

extension Restaurant: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Keys.name)
            builder.string(Keys.address)
            builder.string(Keys.lat)
            builder.string(Keys.lng)
            builder.foreignId(for: User.self)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Restaurant {

    var user: Parent<Restaurant, User> {
        return parent(id: userId)
    }
}

extension User {
    var restaurants: Children<User, Restaurant> {
        return children()
    }
}
