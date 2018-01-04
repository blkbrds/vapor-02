//
//  AuthRouteCollection.swift
//  VaporApiPackageDescription
//
//  Created by Quang Dang N.K on 1/3/18.
//

import Vapor
import HTTP
import Routing
import S3

class AuthRouteCollection: RouteCollection {
    
    func build(_ builder: RouteBuilder) throws {
        builder.post("register", handler: register)
        builder.post("login", handler: login)
    }
    
    private func register(req: Request) throws -> ResponseRepresentable {
        switch try registerValidation(json: req.json) {
        case .success(let param):
            guard try User.makeQuery().filter(User.Keys.email, param.email).count() == 0 else {
                let error = ResponseError(key: "Register Invalid", value: "Email is Exist")
                throw Abort(status: .badRequest, errors: [error])
            }
            guard try Auth.makeQuery().filter(Auth.Keys.authUsername, param.username).count() == 0 else {
                let error = ResponseError(key: "Register Invalid", value: "Username is Exist")
                throw Abort(status: .badRequest, errors: [error])
            }
            let user = User(name: param.name, email: param.email)
            try user.save()
            let auth = try Auth(username: param.username, password: param.password, user: user)
            try auth.save()
            return JSON(["message": "Successful"])
        case .failure(let errors): throw Abort(status: .badRequest, errors: errors)
        }
    }
    
    private func login(req: Request) throws -> ResponseRepresentable {
        switch try loginValidation(json: req.json) {
        case .success(let param):
            guard let auth = try Auth.makeQuery().filter(Auth.Keys.authUsername, param.username).filter(Auth.Keys.authPassword, param.password).first() else {
                throw Abort(status: .badRequest, errors: [ResponseError(key: "Login Invalid", value: "Login failure")])
            }
            guard let user = try User.makeQuery().filter(User.Keys.id, auth.userId).first() else { throw Abort.badRequest }
            let session = try Session.generate(for: user)
            try session.save()
            return try JSON(json: session.makeJSON())
        case .failure(let errors): throw Abort(status: .badRequest, errors: errors)
        }
    }
}

extension AuthRouteCollection {
    private enum RegisterValidation {
        case success(RegisterParam)
        case failure([ResponseError])
    }
    
    private struct RegisterParam {
        var username: String
        var password: String
        var name: String
        var email: String
        init(username: String, password: String, name: String, email: String) {
            self.username = username
            self.password = password
            self.name = name
            self.email = email
        }
    }
    
    private func registerValidation(json: JSON?) throws -> RegisterValidation {
        guard let username = json?["username"]?.string,
            let password = json?["password"]?.string,
            let name = json?["name"]?.string,
            let email = json?["email"]?.string else {
                let error = ResponseError(key: "Register Validation", value: "Parameter Invalid")
                return .failure([error])
        }
        var errors: [ResponseError] = []
        if username.isEmpty {
            let error = ResponseError(key: "Register Validation", value: "Username Must not Empty")
            errors.append(error)
        }
        
        if !password.isValidPassword() {
            let error = ResponseError(key: "Register Validation", value: "Password Invalid")
            errors.append(error)
        }
        
        if name.isEmpty {
            let error = ResponseError(key: "Register Validation", value: "Name Must not Empty")
            errors.append(error)
        }
        
        if !email.validate(String.Regex.email){
            let error = ResponseError(key: "Register Validation", value: "Email Invalid")
            errors.append(error)
        }
        if errors.isEmpty {
            return .success(RegisterParam(username: username, password: password, name: name, email: email))
        }
        return .failure(errors)
    }
    
    private struct LoginParam {
        var username: String
        var password: String
        init(username: String, password: String) {
            self.username = username
            self.password = password
        }
    }
    
    private enum LoginValidation {
        case success(LoginParam)
        case failure([ResponseError])
    }
    
    private func loginValidation(json: JSON?) throws -> LoginValidation {
        guard let username = json?["username"]?.string, let password = json?["password"]?.string else { throw Abort.badRequest }
        var errors: [ResponseError] = []
        if username.isEmpty {
            let error = ResponseError(key: "Login Validation", value: "UserName Must not Empty")
            errors.append(error)
        }
        if !password.isValidPassword() {
            let error = ResponseError(key: "Login Validation", value: "Password Invalid")
            errors.append(error)
        }
        if errors.isEmpty {
            return .success(LoginParam(username: username, password: password))
        }
        return .failure(errors)
    }
}
