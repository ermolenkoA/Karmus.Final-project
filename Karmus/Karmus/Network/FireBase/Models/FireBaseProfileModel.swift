//
//  FireBaseProfileModel.swift
//  Karmus
//
//  Created by User on 8/26/22.
//

import Foundation

final class ProfileModel {
    
    var dateOfBirth: String
    var firstName: String
    var login: String
    var password: Int64
    var phoneNumber: String
    var photo: String
    var secondName: String
    
    
    init(dateOfBirth: String, firstName: String, login: String,
         password: Int64, phoneNumber: String, photo: String, secondName: String){
        self.dateOfBirth = dateOfBirth
        self.firstName = firstName
        self.login = login
        self.password = password
        self.phoneNumber = phoneNumber
        self.photo = photo
        self.secondName = secondName
    }
    
    var about: String { """

Profile:
    "dateOfBirth" = \(dateOfBirth)
    "firstName" = \(firstName)
    "login" = \(login)
    "password" = \(password)
    "phoneNumber" = \(phoneNumber)
    "photo" = \(photo)
    "secondName" = \(secondName)

""" }
}
