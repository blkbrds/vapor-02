//
//  DeviceToken.swift
//  VaporApiPackageDescription
//
//  Created by Quang Dang N.K on 1/8/18.
//

import Vapor
import FluentProvider
import HTTP

final class DeviceToken: Model {

    let storage = Storage()

    var deviceToken: String
    var userId: Identifier
    struct Keys {
        static let deviceToken = "device_token"
        static let userId = "userId"
    }

    init(token: String, user: User) throws {
        self.deviceToken = token
        self.userId = try user.assertExists()
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.deviceToken, deviceToken)
        return row
    }
    
    init(row: Row) throws {
        try deviceToken = row.get(Keys.deviceToken)
        try userId = row.get(Keys.userId)
    }
}

extension DeviceToken: Preparation {
    static func prepare(_ database: Database) throws {
       try database.create(self) { (builder) in
            builder.id()
            builder.string(Keys.deviceToken)
            builder.parent(User.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
