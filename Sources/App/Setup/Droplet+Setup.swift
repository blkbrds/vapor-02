@_exported import Vapor
import S3
extension Droplet {
    public func setup() throws {
        try setupRoutes()
        // Do any additional droplet setup
        configS3()
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
}
