import Vapor
import FluentProvider
import HTTP
import AuthProvider
import Crypto

final class Session: Model {

    let storage = Storage()

    var accessToken: String
    var expiredAt: Date

    var userId: Identifier

    struct Keys {
        static let id = "id"
        static let accessToken = "accessToken"
        static let expiredAt = "expiredAt"
        static let userId = "userId"
    }

    init(accessToken: String, expiredAt: Date, user: User) throws {
        self.accessToken = accessToken
        self.expiredAt = expiredAt
        userId = try user.assertExists()
    }

    init(row: Row) throws {
        accessToken = try row.get(Keys.accessToken)
        expiredAt = try row.get(Keys.expiredAt)
        userId = try row.get(Keys.userId)
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.accessToken, accessToken)
        try row.set(Keys.expiredAt, expiredAt)
        try row.set(Keys.userId, userId)
        return row
    }
}

// MARK: Fluent Preparation

extension Session: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Keys.accessToken, length: 255)
            builder.string(Keys.expiredAt)
            builder.parent(User.self, optional: false, foreignIdKey: Keys.userId)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Session: JSONRepresentable {

    func makeResponseJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.id, id)
        try json.set(Keys.accessToken, accessToken)
        try json.set(App.Keys.tokenType, "Bearer")
        try json.set(Keys.expiredAt, expiredAt)
        try json.set(Keys.userId, userId)
        return json
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.accessToken, accessToken)
        try json.set(Keys.expiredAt, expiredAt)
        try json.set(Keys.id, id)
        try json.set(Keys.userId, userId)
        return try json.dataJSON()
    }
}

extension Session: ResponseRepresentable { }

extension Session {

    var user: Parent<Session, User> {
        return parent(id: userId)
    }
}

extension Session {
    /// Generates a new token for the supplied User.
    static func generate(for user: User) throws -> Session {
        // generate 128 random bits using OpenSSL
        let random = try Crypto.Random.bytes(count: 32)

        // create and return the new token
        let accessToken = random.base64Encoded.makeString()
        // TODO: Hanlde expiredAt later.
        return try Session(accessToken: accessToken, expiredAt: Date(), user: user)
    }
}
