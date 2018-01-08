//
//  DeviceTokenRouteCollection.swift
//  VaporApiPackageDescription
//
//  Created by Quang Dang N.K on 1/8/18.
//

import Routing
import HTTP
import AuthProvider

class DeviceTokenRouteCollection: RouteCollection {
    func build(_ builder: RouteBuilder) throws {
        builder.post("device_token", handler: save)
    }
    
    private func save(req: Request) throws -> ResponseRepresentable {
        guard let json = req.json, let token = json["device_token"]?.string, !token.isEmpty else { throw Abort.badRequest }
        let user = try req.user()
        let devicetoken = try DeviceToken(token: token, user: user)
        try devicetoken.save()
        return JSON(["message": "Successful"])
    }
}
