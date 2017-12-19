//
//  Image.swift
//  VaporApiPackageDescription
//
//  Created by Quang Dang N.K on 12/13/17.
//

import Vapor
import FluentProvider
import HTTP

final class Image: Model {
    let storage = Storage()
    
    struct Keys {
        static let url = "url"
    }
    
    var url = ""
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.url, url)
        return row
    }
    
    init(row: Row) throws {
        try url = row.get(Keys.url)
    }
    
    init(url: String) {
        self.url = url
    }
}

extension Image: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { (builder) in
            builder.id()
            builder.string(Keys.url)
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Image: JSONConvertible {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.url, url)
        return json
    }
    
    convenience init(json: JSON) throws {
        self.init(
            url: try json.get(Keys.url)
        )
    }
}

extension Image: ResponseRepresentable {}
