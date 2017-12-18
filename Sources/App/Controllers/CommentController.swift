//
//  CommentController.swift
//  App
//
//  Created by Quang Dang N.K on 12/2/17.
//

import Vapor
import HTTP
import Fluent
import VaporAPNS

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
        try NotificationController.pushNotification()
        return try Comment(json: json)
    }
}

// Test Push Notification
extension NotificationController {
    static func pushNotification() throws {
        func payloadTest() -> Payload {
            let payload = Payload()
            payload.body = "Have new comment"
            payload.title = "New Comment"
            payload.sound = "default"
            payload.badge = 2
            payload.extra = [Payload.Keys.type: 2]
            return payload
        }
        let message = ApplePushMessage(priority: .immediately, payload: payloadTest())
        var options = try Options(topic: VaporAPNS.topic, teamId: VaporAPNS.teamId, keyId: VaporAPNS.keyId, keyPath: VaporAPNS.keyPath)
        options.disableCurlCheck = false
        let apns = try VaporAPNS(options: options)
        let token = "1f7c256bf7dc68c69073d12eaef2d0283ee087f51391ec13188a409c2ab52015"
        apns.send(message, to: [token], perDeviceResultHandler: { (result) in
        })
        try saveNotification(payload: payloadTest(), deviceTokens: [])
    }
    
    static func saveNotification(payload: Payload, deviceTokens: [String]) throws {
//        for token in deviceTokens {
            guard let des = payload.body,
                let title = payload.title else { return }
            let type = payload.extra[Payload.Keys.type] as? Int
            let notif = Notification(description: des, title: title, type: type)
            try notif.save()
//        }
    }
}

extension CommentController: EmptyInitializable {}
