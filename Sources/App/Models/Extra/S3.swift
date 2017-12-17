import Foundation
import AWS
import S3

extension S3 {
    static var shared: S3!
    
    static func upload(folderName: String, fileName: String, bytes: [Byte]) throws -> String {
        let butketName = "/vapordemo"
        let timeInterval = "\(Date().timeIntervalSince1970)"
        let path = butketName / fileName + timeInterval + ".png"
        let host = S3.shared.host
        try S3.shared.upload(
            bytes: bytes,
            path: path,
            access: .bucketOwnerFullControl
        )
        return "https://" + host + path
    }
}

// MARK: - Custom slash appends operator
precedencegroup MultiplicationPrecedence {
    associativity: left
    higherThan: AdditionPrecedence
}

infix operator / : MultiplicationPrecedence

func / (left: String, right: String) -> String {
    return left + "/" + right
}

