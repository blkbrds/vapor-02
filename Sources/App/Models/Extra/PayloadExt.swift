//
//  APNSExt.swift
//  VaporApiPackageDescription
//
//  Created by Quang Dang N.K on 12/18/17.
//

import AWS
import VaporAPNS

extension Payload {
    struct Keys {
        static let aps = "aps"
        static let sound = "sound"
        static let badge = "badge"
        static let alert = "alert"
        static let body = "body"
        static let title = "title"
        static let id = "id"
        static let type = "type"
        static let payload = "payload"
    }
    
    convenience init(json: JSON) throws {
        self.init()
        guard let aps = json[Keys.aps],
            let sound = aps[Keys.sound]?.string,
            let badge = aps[Keys.badge]?.int,
            let alert = aps[Keys.alert],
            let title = alert[Keys.title]?.string,
            let body = alert[Keys.body]?.string else { throw Abort.badRequest }
        let id = json[Keys.id]?.int
        let type = json[Keys.type]?.string
        self.body = body
        self.title = title
        self.sound = sound
        self.badge = badge
        self.extra = [Keys.type: type, Keys.id: id]
    }
}
