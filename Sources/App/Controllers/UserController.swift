//
//  UserController.swift
//  App
//
//  Created by Lam Le V. on 12/12/17.
//

import Vapor
import HTTP
import Fluent

final class UserController {

    struct Keys {
        static let create = "create"
        static let comments = "comments"
    }

    // Make json
    func addRoutes(to drop: Droplet) {
        let userGroup = drop.grouped("users")
        userGroup.get(handler: allUsers)
        userGroup.post(Keys.create, handler: createUser) //http://localhost:8080/users/create
        userGroup.get(User.parameter, handler: getUser)
        userGroup.get(User.parameter, Keys.comments, handler: getUserComments)
    }

    func allUsers(_ req: Request) throws -> ResponseRepresentable {
        return try User.all().makeJSON()
    }

    func createUser(_ req: Request) throws -> ResponseRepresentable {
        guard let json = req.json else {
            throw Abort.badRequest
        }
        let user = try User(json: json)
        try user.save()
        return user
    }

    func getUserComments(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.parameters.next(User.self)
        return try user.comments.all().makeJSON()
    }

    func store(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.postUser()
        try user.save()
        return user
    }

    func getUser(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.parameters.next(User.self)
        return user
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
