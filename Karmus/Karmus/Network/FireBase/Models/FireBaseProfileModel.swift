//
//  FireBaseProfileModel.swift
//  Karmus
//
//  Created by User on 8/26/22.
//

import Foundation

final class ProfileVerificationModel {
    
    var firstName: String
    var login: String
    var password: Int64
    var phoneNumber: String
    var secondName: String
    
    
    init(firstName: String, login: String,
         password: Int64, phoneNumber: String, secondName: String){
        self.firstName = firstName
        self.login = login
        self.password = password
        self.phoneNumber = phoneNumber
        self.secondName = secondName
    }
    
    var about: String { """

ProfileVerificationModel:

    "firstName" = \(firstName)
    "login" = \(login)
    "password" = \(password)
    "phoneNumber" = \(phoneNumber)
    "secondName" = \(secondName)

""" }
}
