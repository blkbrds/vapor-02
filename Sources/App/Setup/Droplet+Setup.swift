@_exported import Vapor
import S3
import VaporAPNS
extension Droplet {
    public func setup() throws {
        try setupRoutes()
        // Do any additional droplet setup
        configS3()
        configAPNS()
    }
    private func configS3() {
        guard let accessKey = self.config["s3", "accessKey"]?.string,
            let secretKey = self.config["s3", "secretKey"]?.string,
            let host = self.config["s3", "host"]?.string else { return }
        S3.shared = S3(
            host: host,
            accessKey: accessKey,
            secretKey: secretKey,
            region: .apSoutheast1
        )
    }
    
    private func configAPNS() {
        guard let topic = self.config["apns", "topic"]?.string,
            let teamId = self.config["apns", "teamId"]?.string,
            let keyId = self.config["apns", "keyId"]?.string,
            let keyPath = self.config["apns", "keyPath"]?.string else { return }
        VaporAPNS.topic = topic
        VaporAPNS.keyId = keyId
        VaporAPNS.keyPath = keyPath
        VaporAPNS.teamId = teamId
    }
}
