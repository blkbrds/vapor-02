//
//  CommentController.swift
//  App
//
//  Created by Quang Dang N.K on 12/2/17.
//

import Vapor
import HTTP
import Fluent

final class CommentController: ResourceRepresentable {
    
    func index(_ req: Request) throws -> ResponseRepresentable {
        var item: Query<Comment>
        let totalCount = try Comment.all().count
        item = try Comment.makeQuery()
        let page = req.page()
        let meta = Meta(currentPage: req.page(), totalCount: totalCount)
        let commentData = try item.page(page).all().makeJSON()
        return try JSON(meta: meta, data: commentData)
    }
    
    func store(_ req: Request) throws -> ResponseRepresentable {
        let comment = try req.comment()
        try comment.save()
        return try Response(status: .ok, json: ["message": "Successful"])
    }
    
    func show(_ req: Request, comment: Comment) throws -> ResponseRepresentable {
        return try comment.makeFullJSON()
    }
    
    func update(_ req: Request, comment: Comment) throws -> ResponseRepresentable {
        try comment.update(for: req)
        try comment.save()
        return comment
    }
    
    func delete(_ req: Request, comment: Comment) throws -> ResponseRepresentable {
        try comment.delete()
        return try Response(status: .ok, json: ["meesage": "Delete OK"])
    }
    
    func makeResource() -> Resource<Comment> {
        return Resource(index: index,
                        store: store,
                        show: show,
                        update: update,
                        destroy: delete
        )
    }
}

extension Request {
    func comment() throws -> Comment {
        guard let json = json else { throw Abort.badRequest }
        return try Comment(json: json)
    }
}

extension CommentController: EmptyInitializable {}
