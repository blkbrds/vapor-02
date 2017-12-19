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
    
    func store(_ req: Request) throws -> ResponseRepresentable {
        let image = try req.imageUpload()
        try image.save()
        return try Response(status: .ok, json: ["message": "Successful"])
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
                        store: store,
                        show: show,
                        destroy: delete
        )
    }
}

extension Request {
    func imageUpload() throws -> Image {
        guard let bytes = json?["image"]?.bytes,
            let fileName = json?["named"]?.string else { throw Abort.notFound }
        let url = try S3.upload(folderName: "media", fileName: fileName, bytes: bytes)
        return Image(url: url)
    }
}

extension ImageController: EmptyInitializable {}
