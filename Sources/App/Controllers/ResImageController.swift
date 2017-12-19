//
//  ResImageController.swift
//  VaporApiPackageDescription
//
//  Created by Quang Dang N.K on 12/13/17.
//
import Vapor
import HTTP
import Fluent

final class ResImageController: ResourceRepresentable {
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try ResImage.all().makeJSON()
    }
    
    func store(_ req: Request) throws -> ResponseRepresentable {
        return try Response(status: .ok, json: ["message": "Successful"])
    }
    
    func show(_ req: Request, resImage: ResImage) throws -> ResponseRepresentable {
        return try resImage.makeJSON()
    }
    
    func makeResource() -> Resource<ResImage> {
        return Resource(index: index,
                        store: store,
                        show: show
        )
    }
}

extension Request {
    func postResImage() throws -> ResImage {
        guard let json = json else { throw Abort.badRequest }
        return try ResImage(json: json)
    }
}

extension ResImageController: EmptyInitializable {}
