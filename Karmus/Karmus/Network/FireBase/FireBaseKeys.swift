//
//  FireBaseDataBaseKeys.swift
//  Karmus
//
//  Created by User on 8/26/22.
//

import Foundation

struct FBDefaultKeys {
    static let profiles = "Profiles"
    static let profilesInfo = "ProfilesInfo"
    static let tasks = "Tasks"
    static let topics = "Topics"
    static let chats = "Chats"
    static let coupons = "Coupons"
}

struct FBProfileKeys {
    static let firstName = "firstName"
    static let login = "login"
    static let password = "password"
    static let phoneNumber = "phoneNumber"
    static let secondName = "secondName"
    static let userTasks = "userTasks"
    static let profileUpdateDate = "profileUpdateDate"
    static let friends = "friends"
    static let requests = "requests"
    static let followers = "followers"
    static let balance = "balance"
    static let coupons = "coupons"
}

struct FBProfileInfoKeys {
    static let firstName = "firstName"
    static let secondName = "secondName"
    static let photo = "photo"
    static let dateOfBirth = "dateOfBirth"
    static let email = "email"
    static let phone = "phone"
    static let city = "city"
    static let preferences = "preferences"
    static let education = "education"
    static let work = "work"
    static let skills = "skills"
    static let numberOfRespects = "numberOfRespects"
    static let numberOfFriends = "numberOfFriends"
    
    static let profileType = "profileType"
    static let sponsorName = "sponsorName"
    
    static let onlineStatus = "onlineStatus"
    static let numberOfSessions = "numberOfSessions"
}

struct FBChatKeys {
    static let members = "members"
    static let messages = "messages"
}

struct FBChatMessageKeys {
    static let sender = "sender"
    static let sentDate = "sentDate"
    static let messageText = "messageText"
    static let isRead = "isRead"
}


struct FBOnlineStatuses {
    static let online = "online"
    static let offline = "offline"
    static let blocked = "blocked"
}

struct FBProfileTypes {
    static let user = "user"
    static let admin = "admin"
    static let sponsor = "sponsor"

}

struct FBCoupons {
    static let name = "name"
    static let description = "description"
    static let codes = "codes"
    static let sponsorLogin = "sponsorLogin"
    static let price = "price"
}


