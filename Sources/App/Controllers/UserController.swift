//
//  UserController.swift
//  App
//
//  Created by Lam Le V. on 12/12/17.
//

import Vapor
import HTTP
import Fluent

final class UserController: ResourceRepresentable {

    func index(_ req: Request) throws -> ResponseRepresentable {
        return try User.all().makeJSON()
    }

    func makeResource() -> Resource<User> {
        return Resource(index: index)
    }
}

extension Request {

    func postUser() throws -> User {
        guard let json = json else {
            throw Abort.badRequest
        }
        return try User(json: json)
    }
}

extension UserController: EmptyInitializable {}
