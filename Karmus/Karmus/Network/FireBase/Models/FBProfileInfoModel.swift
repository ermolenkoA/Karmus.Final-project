//
//  FBProfileInfoModel.swift
//  Karmus
//
//  Created by VironIT on 9/1/22.
//

import Foundation

final class ProfileInfoModel {
    
    let firstName: String?
    let secondName: String?
    let photo: String?
    let dateOfBirth: String?
    let email: String?
    let phone: String?
    let city: String?
    let preferences: [String]?
    let education: String?
    let work: String?
    let skills: String?
    
    
    init( firstName: String?, secondName: String?, photo: String?,
          dateOfBirth: String?, email: String?, phone: String?,
          city: String?, preferences: [String]?, education: String?,
          work: String?, skills: String?) {
        
        self.firstName = firstName
        self.secondName = secondName
        self.photo = photo
        self.dateOfBirth = dateOfBirth
        self.email = email
        self.phone = phone
        self.city = city
        self.preferences = preferences
        self.education = education
        self.work = work
        self.skills = skills
        
    }
    
    var about: String { """

ProfileInfoModel:

    "firstName" = \(firstName ?? "")
    "secondName" = \(secondName ?? "")
    "photo" = \(photo ?? "")
    "dateOfBirth" = \(dateOfBirth ?? "")
    "email" = \(email ?? "")
    "phone" = \(phone ?? "")
    "city" = \(city ?? "")
    "preferences" = \(preferences ?? [""])
    "education" = \(education ?? "")
    "work" = \(work ?? "")
    "skills" = \(skills ?? "")

""" }
    
}
