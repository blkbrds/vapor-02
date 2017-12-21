//
//  RestaurantRouteCollection.swift
//  App
//
//  Created by hai phung on 12/20/17.
//

import Routing
import HTTP
import AuthProvider

class RestaurantRouteCollection: RouteCollection {

    func build(_ builder: RouteBuilder) throws {
        let res = builder.grouped("restaurant")
        let token = res.grouped([
            TokenAuthenticationMiddleware(User.self)
            ])

        token.post("create") { req in
            let response = try RestaurantController().create(req: req)
            return response
        }
    }
}
