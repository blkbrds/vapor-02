//
//  AuthController.swift
//  App
//
//  Created by hai phung on 12/6/17.
//

import Foundation

final class AuthController {
    let drop: Droplet

    init(drop: Droplet) {
        self.drop = drop
    }
}

extension AuthController {

    struct Params: Equatable {
        var authId: String
        var authToken: String
        var authMethod: AuthMethod

        static func == (lhs: Params, rhs: Params) -> Bool {
            return lhs.authId == rhs.authId
                && lhs.authToken == rhs.authToken
                && lhs.authMethod.id == rhs.authMethod.id
        }
    }

    enum Validation {
        case success(Params)
        case failure([ResponseError])
    }

    func validate(json: JSON?) throws -> Validation {
        guard let authId = json?[Auth.Keys.authId]?.string,
            let authToken = json?[Auth.Keys.authToken]?.string,
            let authMethod = json?[Auth.Keys.authMethod]?.string else {
                let error = ResponseError(
                    key: App.Keys.parameters,
                    value: App.Strings.Error.invalidParameters
                )
                return .failure([error])
        }
        // Check authMethod param is available
        guard let fetchedAuthMethod = try AuthMethod.makeQuery().filter(AuthMethod.Keys.name, authMethod).first() else {
            let error = ResponseError(
                key: App.Keys.parameters,
                value: App.Strings.Error.authMethodNotSupported
            )
            return .failure([error])
        }
        // Check validation
        var errors: [ResponseError] = []
        if authId.isEmpty {
            let error = ResponseError(
                key: Auth.Keys.authId,
                value: App.Strings.Error.emptyEmail
            )
            errors.append(error)
        } else if !authId.validate(String.Regex.email) {
            let error = ResponseError(key: Auth.Keys.authId, value: App.Strings.Error.invalidEmail)
            errors.append(error)
        }
        if authToken.isEmpty {
            let error = ResponseError(
                key: Auth.Keys.authToken,
                value: App.Strings.Error.emptyPassword
            )
            errors.append(error)
        } else if !authToken.isValidPassword() {
            let error = ResponseError(
                key: Auth.Keys.authToken,
                value: App.Strings.Error.invalidPassword
            )
            errors.append(error)
        }

        if errors.isEmpty {
            let params = Params(
                authId: authId,
                authToken: authToken,
                authMethod: fetchedAuthMethod
            )
            return .success(params)
        }
        return .failure(errors)
    }
}

extension AuthController {

    // web
    func login(req: Request) throws -> ResponseRepresentable {
        var registerParams: Params
        switch try validate(json: req.json) {
        case .success(let params):
            registerParams = params
        case .failure(let errors):
            throw Abort(status: .badRequest, errors: errors)
        }
        guard let auth = try Auth.makeQuery().filter(Auth.Keys.authId, registerParams.authId).first() else {
            throw Abort.badRequest
        }

        let authTokenBytes = registerParams.authToken.makeBytes()
        let hashPassword = try drop.hash.make(authTokenBytes).makeString()

        guard hashPassword == auth.authToken else {
            let error = ResponseError(
                key: Auth.Keys.authToken,
                value: App.Strings.Error.incorrectPassword
            )
            throw Abort(status: .badRequest, errors: [error])
        }
        guard let user = try auth.user.first() else {
            throw Abort(.internalServerError)
        }
        // Make a session form a supplied auth
        let session = try Session.generate(for: user)
        try session.save()
        let resJSON = try session.makeResponseJSON()
        return try JSON(data: resJSON)
    }

    // app
    func register(req: Request) throws -> ResponseRepresentable {
        // Check request data validation
        var params: Params
        switch try validate(json: req.json) {
        case .success(let registerParams):
            params = registerParams
        case .failure(let errors):
            throw Abort(status: .badRequest, errors: errors)
        }
        // Check `authId` is exist
        let auth = try Auth.makeQuery().filter(Auth.Keys.authId, params.authId).first()
        if auth != nil {
            let error = ResponseError(
                key: App.Keys.loginFailed,
                value: App.Strings.Error.emailAlreadyExists
            )
            throw Abort(status: .badRequest, errors: [error])
        }

        let database = try drop.assertDatabase()
        return try database.transaction { _ -> ResponseRepresentable in

            // Create User from a given account
            guard let name = req.json?[User.Keys.name]?.string else {
                let error = ResponseError(
                    key: App.Keys.loginFailed,
                    value: App.Strings.Error.invalidParameters
                )
                throw Abort(status: .badRequest, errors: [error])
            }

            let user = User(name: name, email: params.authId)
            try user.save()

            // hash the password and set it on the user
            let authTokenBytes = params.authToken.makeBytes()
            params.authToken = try drop.hash.make(authTokenBytes).makeString()

            let auth = try Auth(
                authId: params.authId,
                authToken: params.authToken,
                user: user,
                authMethod: params.authMethod
            )
            try auth.save()

            let resJSON = try auth.makeJSON()
            return try JSON(data: resJSON)
        }
    }
}
