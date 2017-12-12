//
//  Meta.swift
//  App
//
//  Created by Quang Dang N.K on 12/2/17.
//

import Vapor
import FluentProvider
import HTTP

final class Meta {
    
    static let maxItems = 20
    let storage = Storage()
    
    var currentPage = 0
    var totalCount = 0
    var nextPage: Int? {
        if currentPage > 0 && currentPage < totalPage {
            return currentPage + 1
        }
        return nil
    }
    var previousPage: Int? {
        return currentPage > 1 ? currentPage - 1 : nil
    }
    var totalPage: Int {
        let pages = totalCount / Meta.maxItems
        let balance = totalCount % Meta.maxItems
        return balance > 0 ? pages + 1 : pages
    }
    
    struct Keys {
        static let currentPage = "current_page"
        static let totalPage = "total_page"
        static let nextPage = "next_page"
        static let previousPage = "previous_page"
        static let totalCount = "total_count"
    }
    
    init(currentPage: Int, totalCount: Int) {
        self.currentPage = currentPage
        self.totalCount = totalCount
    }
}

extension Meta: JSONConvertible {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.currentPage, currentPage)
        try json.set(Keys.totalPage, totalPage)
        try json.set(Keys.nextPage, nextPage)
        try json.set(Keys.previousPage, previousPage)
        try json.set(Keys.totalCount, totalCount)
        return json
    }
    
    convenience init(json: JSON) throws {
        self.init(
            currentPage: try json.get(Keys.currentPage),
            totalCount: try json.get(Keys.totalCount)
        )
    }
}
