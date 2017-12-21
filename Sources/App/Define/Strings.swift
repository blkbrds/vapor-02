//
//  Strings.swift
//  App
//
//  Created by hai phung on 12/5/17.
//

import Foundation

extension App {
    struct Strings { }
}

extension App.Strings {
    struct Error { }
}

extension App.Strings.Error {
    static let emptyEmail = "The emai field is required"
    static let emptyPassword = "The password field is required"
    static let invalidEmail = "The email format is incorrect"
    static let invalidPassword = "The password must contain 6 - 255 characters"
    static let emailAlreadyExists = "This email address already exists"
    static let emailNotExist = "The email hasn't been registered yet"
    static let incorrectPassword = "The password is incorrect"
    static let invalidParameters = "These parameters is incorrect"
    static let internalServerError = "Internal Server Error"
    static let badRequest = "badRequest"
    static let unauthorized = "unauthorized"
    static let notFound = "notFound"
    static let invalidPage = "The page is invalid"
    static let authMethodNotSupported = "`authMethod` param is not supported"
    static let invalidAccountState = "`AccountState` table isn't available"
    static let paymentExisted = "This `Order` has had payment"
    static let removeOrder = "Can't remove Order because state of order"
    static let balanceNotEnough = "Your balance can not less than total price"
    static let saveFailed = "Can't save the object"
    static let configAPNSFail = "Vapor APNS isn't available"
}
