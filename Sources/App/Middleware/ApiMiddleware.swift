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
            return response
        } catch APIError.unable {
            throw Abort(.badRequest,reason: "Sorry, we were unable to query service.")
        }
    }
}
