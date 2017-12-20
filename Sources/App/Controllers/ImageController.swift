//
//  ImageController.swift
//  VaporApiPackageDescription
//
//  Created by Quang Dang N.K on 12/13/17.
//
import S3
import HTTP
import CoreData
import WebKit

final class ImageController: ResourceRepresentable {
    
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try Image.all().makeJSON()
    }
    
    func show(_ req: Request, image: Image) throws -> ResponseRepresentable {
        return try image.makeJSON()
    }
    
    func delete(_ req: Request, image: Image) throws -> ResponseRepresentable {
        try image.delete()
        return try Response(status: .ok, json: ["meesage": "Delete OK"])
    }
    
    func makeResource() -> Resource<Image> {
        return Resource(index: index,
                        show: show,
                        destroy: delete
        )
    }
}

extension ImageController: EmptyInitializable {}
