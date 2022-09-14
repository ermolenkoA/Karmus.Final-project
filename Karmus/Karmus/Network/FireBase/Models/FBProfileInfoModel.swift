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
    let numberOfRespects: Int?
    let numberOfFriends: Int?
    let profileType: String?
    let sponsorName: String?
    let onlineStatus: String?
    let numberOfSessions: Int?

    init(firstName: String?, secondName: String?, photo: String?,
          dateOfBirth: String?, email: String?, phone: String?,
          city: String?, preferences: [String]?, education: String?,
          work: String?, skills: String?, numberOfRespects: Int?,
          numberOfFriends: Int?, profileType: String?, sponsorName: String?,
          onlineStatus: String?, numberOfSessions: Int?) {
        
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
        self.numberOfRespects = numberOfRespects
        self.numberOfFriends = numberOfFriends
        self.profileType = profileType
        self.sponsorName = sponsorName
        self.onlineStatus = onlineStatus
        self.numberOfSessions = numberOfSessions
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
    "numberOfRespects" = \(numberOfRespects ?? 0)
    "numberOfFriends" = \(numberOfFriends ?? 0)
    "profileType" = \(profileType ?? "")
    "sponsorName" = \(sponsorName ?? "")
    "onlineStatus" = \(onlineStatus ?? "")

""" }
    
}

struct ProfileForTask {
    let login: String
    let name: String
    let photo: String
    let profileType: String
}
