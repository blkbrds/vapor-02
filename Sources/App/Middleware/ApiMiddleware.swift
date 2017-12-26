//
//  ApiMiddleware.swift
//  VaporApiPackageDescription
//
//  Created by Quang Dang N.K on 12/26/17.
//
import Vapor

final class  ApiMiddleware: Middleware {
    enum APIError: Error {
        case unable
    }
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            let response = try next.respond(to: request)
            if try !request.isPassWithoutAuthorizationHeader() { throw Abort(.unauthorized, reason: "Unauthorized") }
            return response
        } catch APIError.unable {
            throw Abort(.badRequest,reason: "Sorry, we were unable to query service.")
        }
    }
}

extension Request {
    func isPassWithoutAuthorizationHeader() throws -> Bool {
        let path = uri.path
        if !path.contains("register") && !path.contains("login") {
            guard let accessToken = headers[.authorization]?.string, !accessToken.isEmpty else { return false }
            let auths = try Auth.all().map({ $0.authToken })
            return auths.filter({ $0 == accessToken }).count > 0
        }
        return true
    }
}
