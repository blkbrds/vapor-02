//
//  RestaurantController.swift
//  App
//
//  Created by hai phung on 11/27/17.
//

import Vapor
import HTTP

final class RestaurantController: ResourceRepresentable {

    func makeResource() -> Resource<Restaurant> {
        return Resource(
            index: index,
            store: store
        )
    }

    func create(req: Request) throws -> ResponseRepresentable {
        let user = try req.user()
        try req.json?.set(Restaurant.Keys.userId, user.id)
        let res = try req.res()
        try res.save()
        return try res.makeJSON()
    }

    func index(_ req: Request) throws -> ResponseRepresentable {
        return try Restaurant.all().makeJSON()
    }

    func store(_ req: Request) throws -> ResponseRepresentable {
        let res = try req.res()
        try res.save()
        return try res.makeJSON()
    }

    func show(_ req: Request, Restaurant: Restaurant) throws -> ResponseRepresentable {
        return try Restaurant.makeRow() as! ResponseRepresentable
    }
}

extension RestaurantController: EmptyInitializable {}

fileprivate extension Request {

    func res() throws -> Restaurant {
        guard let json = json else { throw Abort.badRequest }
        return try Restaurant(json: json)
    }

    func userId() throws -> Identifier {
        guard let userId = data[Restaurant.Keys.userId]?.int else {
            throw Abort.badRequest
        }
        return Identifier(userId)
    }
}
