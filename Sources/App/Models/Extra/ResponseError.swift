//
//  ResponseError.swift
//  App
//
//  Created by hai phung on 12/5/17.
//

import Vapor
import FluentProvider
import AuthProvider
import HTTP

final class ResponseError {

    var key = ""
    var value = ""

    static var key = "key"
    static var valueKey = "value"

    init(key: String, value: String) {
        self.key = key
        self.value = value
    }

    static let internalServerError = ResponseError(key: App.Keys.internalServerError,
                                                   value: App.Strings.Error.internalServerError)

    var metadata: Node {
        let keyData = StructuredData.string(key)
        let valueData = StructuredData.string(value)
        let obj = StructuredData.object([ResponseError.key: keyData,
                                         ResponseError.valueKey: valueData])
        return Node(StructuredData.array([obj]), in: nil)
    }
}

extension ResponseError: Equatable, JSONConvertible, ResponseRepresentable {
    static func == (lhs: ResponseError, rhs: ResponseError) -> Bool {
        return lhs.key == rhs.key && lhs.value == rhs.value
    }

    convenience init(json: JSON) throws {
        try self.init(key: json.get(ResponseError.key),
                      value: json.get(ResponseError.valueKey))
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(ResponseError.key, key)
        try json.set(ResponseError.valueKey, value)
        return json
    }


}
