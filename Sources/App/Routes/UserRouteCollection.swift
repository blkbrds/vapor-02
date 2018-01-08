//
//  UserRouteCollection.swift
//  VaporApiPackageDescription
//
//  Created by Quang Dang N.K on 1/8/18.
//

import Vapor
import HTTP
import Routing
import S3

class UserRouteCollection: RouteCollection {
    func build(_ builder: RouteBuilder) throws {
        let user = builder.grouped("user")
        user.put("update", handler: update)
    }
    
    private func update(req: Request) throws -> ResponseRepresentable {
        let userUpdate = try req.user()
        switch try validation(json: req.json) {
        case .success(let param):
            userUpdate.name = param.name
            userUpdate.avatar = param.avatar
            try userUpdate.save()
            return JSON(["message": "Successful"])
        case .failure: throw Abort.badRequest
        }
    }
}

extension UserRouteCollection {
    struct UpdateParams {
        var name: String
        var avatar: String?
        init(name: String, avatar: String?) {
            self.name = name
            self.avatar = avatar
        }
    }
    
    enum Validation {
        case success(UpdateParams)
        case failure
    }
    
    func validation(json: JSON?) throws -> Validation {
        let avatar = json?["image"]?.string
        guard let name = json?["name"]?.string else { throw Abort.badRequest }
        if name.isEmpty {
            return .failure
        }
        return .success(UpdateParams(name: name, avatar: avatar))
    }
}
