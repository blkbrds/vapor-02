//
//  NotificationViewController.swift
//  VaporApiPackageDescription
//
//  Created by Quang Dang N.K on 12/17/17.
//

import HTTP
import Vapor
import Fluent
import VaporAPNS

final class NotificationController: ResourceRepresentable {

    var drop: Droplet?
    
    convenience init(drop: Droplet) {
        self.init()
        self.drop = drop
    }
    
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try ResImage.all().makeJSON()
    }

    func makeResource() -> Resource<ResImage> {
        return Resource(index: index
        )
    }
}

extension NotificationController {

    func push(req: Request) throws {
        let payload = try req.payload()
        let message = ApplePushMessage(priority: .immediately, payload: payload)
        let deviceToken = try req.deviceToken().flatMap { (json) -> String? in
            return json.string
        }
        do {
            try saveNotification(payload: payload, deviceTokens: deviceToken)
        } catch {
            drop?.log.error(error.localizedDescription)
        }
        for token in deviceToken {
            var options = try Options(topic: VaporAPNS.topic, teamId: VaporAPNS.teamId, keyId: VaporAPNS.keyId, keyPath: VaporAPNS.keyPath)
            options.disableCurlCheck = true
            let apns = try VaporAPNS(options: options)
            apns.send(message, to: [token], perDeviceResultHandler: { (result) in
                // TODO
            })
        }
    }
}

extension NotificationController {
    func saveNotification(payload: Payload, deviceTokens: [String]) throws {
        for token in deviceTokens {
            guard let des = payload.body,
            let title = payload.title else { return }
            let type = payload.extra[Payload.Keys.type] as? Int
            let notif = Notification(description: des, title: title, type: type)
            try notif.save()
        }
    }
}

extension Request {
    fileprivate func payload() throws -> Payload {
        guard let json = json, let payloadJson = json["payload"] else { throw Abort.badRequest }
        let payload = try Payload(json: payloadJson)
        return payload
    }
    
    fileprivate func deviceToken() throws -> [JSON] {
        guard let json = json, let deviceTokenJson = json["devicetoken"]?.array else { throw Abort.badRequest }
        return deviceTokenJson
    }
}

extension NotificationController: EmptyInitializable {}
