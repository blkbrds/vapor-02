//
//  ImageRouters.swift
//  VaporApiPackageDescription
//
//  Created by Quang Dang N.K on 12/19/17.
//

import Vapor
import HTTP
import Routing
import S3

class ImageRouteCollection: RouteCollection {
    struct Keys {
        static let main = "image"
        static let upload = "upload"
    }

    func build(_ builder: RouteBuilder) throws {
        let image = builder.grouped(Keys.main)
        image.post(Keys.upload, handler: upload)
    }
    
    private func upload(_ req: Request) throws -> ResponseRepresentable {
        let image = try req.imageUpload()
        try image.save()
        return try image.makeJSON()
    }
}

extension Request {
    func imageUpload() throws -> Image {
        guard let form = formData, let bytes = form["image"]?.part.body,
            let fileName = form["named"]?.string else { throw Abort.notFound }
        let url = try S3.upload(folderName: "media", fileName: fileName, bytes: bytes)
        return Image(url: url)
    }
}
