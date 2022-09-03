//
//  FireBaseManager.swift
//  Karmus
//
//  Created by User on 8/25/22.
//

import Foundation
import FirebaseDatabase

final class FireBaseDataBaseManager {
    
    private static let profiles =  Database.database().reference().child(FBDefaultKeys.profiles)
    private static let profliesInfo =  Database.database().reference().child(FBDefaultKeys.profilesInfo)
    private static let topics =  Database.database().reference().child(FBDefaultKeys.topics)
    
    static let description = "<FireBaseDataBaseManager>"
    
    static func findLoginOrPhone(_ loginOrPhone: String, _ result: @escaping (FireBaseRequestResult) -> ()) {
        
            guard loginOrPhone ~= "^([A-Za-z]+([-_\\.]?[A-Za-z0-9]+){0,2}){3,}$" ||
                    loginOrPhone ~= "^(\\+375)(29|25|33|44)([\\d]{7})$" else{
                
                print("\n \(self.description) ERROR: login is incorrect\n)")
                result(.error)
                return
            }
        
        profiles.observeSingleEvent(of: .value) { snapshot in
            
            guard snapshot.exists() else{
                print("\n\(self.description) Failure: snapshot isn't exist\n")
                result(.notFound)
                return
            }
            
            guard let profiles = snapshot.children.allObjects as? [DataSnapshot] else {
                print("\n\(self.description) ERROR: profiles isn't exist\n")
                result(.error)
                return
            }
        
            for profile in profiles {
                
                guard let profileElements = profile.value as? [String : AnyObject] else {
                    print("\n\(self.description) ERROR: profiles contains unvalid profile\n")
                    result(.error)
                    return
                }
                
                if profileElements[FBProfileKeys.login] as? String == loginOrPhone ||
                    profileElements[FBProfileKeys.phoneNumber] as? String == loginOrPhone{
                    result(.found)
                    return
                }
                
            }
            
            result(.notFound)
        }
        
    }
    
    static func getProfileUpdateDate(_ profileID: String, _ result: @escaping (String?) -> ()){
        
        profiles.child(profileID).child(FBProfileKeys.profileUpdateDate).observeSingleEvent(of: .value){ snapshot in
            guard snapshot.exists() else {
                result(nil)
                return
            }
            result(snapshot.value as? String)
        }
        
    }
    
    static func getProfileInfo(_ login: String, _ result: @escaping (ProfileInfoModel?) -> ()){
        
        profliesInfo.child(login).observeSingleEvent(of: .value){ snapshot in
            guard snapshot.exists() else {
                result(nil)
                return
            }
            result(parseDataToProfileInfo(snapshot))
        }
        
    }
    
    static func getProfileLogin(_ profileID: String, _ result: @escaping (String?) -> ()){
        
        profiles.child(profileID).child(FBProfileKeys.login).observeSingleEvent(of: .value){ snapshot in
            guard snapshot.exists() else {
                result(nil)
                return
            }
            result(snapshot.value as? String)
        }
        
    }
    
    static func getTopics(_ result: @escaping ([String]?) -> ()){
        
        topics.observeSingleEvent(of: .value){ snapshot in
            guard snapshot.exists() else {
                result(nil)
                return
            }
            result(snapshot.value as? [String])
        }
        
    }
    
    static func openProfile(login: String, password: Int64, newPassword: Int64? = nil, _ result: @escaping (FireBaseOpenProfileResult, String?) -> ()) {

        if !(login ~= "^([A-Za-z]+([-_\\.]?[A-Za-z0-9]+){0,2}){3,}$"){
            if !(login ~= "^(\\+375)(29|25|33|44)([\\d]{7})$") {
                result(.failure, nil)
                return
            }
        }
        
        profiles.observeSingleEvent(of: .value) { snapshot in

            guard snapshot.exists() else{
                print("\n\(self.description) Failure: snapshot isn't exist\n")
                result(.failure, nil)
                return
                
            }
            
            guard let profiles = snapshot.children.allObjects as? [DataSnapshot] else {
                print("\n\(self.description) ERROR: profiles isn't exist\n")
                result(.error, nil)
                return
            }
            
            for profile in profiles {
                
                guard let profileElements = profile.value as? [String : AnyObject] else {
                    print("\n\(self.description) ERROR: profiles contains unvalid profile\n")
                    result(.error, nil)
                    return
                }
                
                guard let loginFromData = profileElements[FBProfileKeys.login] as? String,
                      let passwordFromData = profileElements[FBProfileKeys.password] as? Int64,
                      let phoneNumber = profileElements[FBProfileKeys.phoneNumber] as? String else {
                    
                    print("\n\(self.description) ERROR: profiles contains unvalid profile\\login\n")
                    result(.error, nil)
                    return
                }
                
                guard ( loginFromData == login || phoneNumber == login ) && (password == passwordFromData) else {
                    continue
                }
                
                if let newPassword = newPassword {
                    self.profiles.child(profile.key).child(FBProfileKeys.password).setValue(newPassword)
                }

                result(.success, profile.key)
                return
            }
            
            result(.failure, nil)
        }
        
    }
    
    static func parseDataForVerification(_ data: DataSnapshot) -> ProfileVerificationModel? {
        
        guard let profileElements = data.value as? [String : AnyObject],
              let firstName = profileElements[FBProfileKeys.firstName] as? String,
              let login = profileElements[FBProfileKeys.login] as? String,
              let password = profileElements[FBProfileKeys.password] as? Int64,
              let phoneNumber = profileElements[FBProfileKeys.phoneNumber] as? String else {
            print("\n\(self.description) ERROR: profiles contains unvalid profile\n")
            return nil
        }
        
        return ProfileVerificationModel.init(firstName: firstName,
                                 login: login, password: password,
                                 phoneNumber: phoneNumber,
                                 secondName: "")
    }
    
    static func parseDataToProfileInfo(_ data: DataSnapshot) -> ProfileInfoModel? {
        
        guard let profileElements = data.value as? [String : AnyObject] else { return nil }
        
        let firstName = profileElements[FBProfileInfoKeys.firstName] as? String
        let secondName = profileElements[FBProfileInfoKeys.secondName] as? String
        let photo = profileElements[FBProfileInfoKeys.photo] as? String
        let dateOfBirth = profileElements[FBProfileInfoKeys.dateOfBirth] as? String
        let email = profileElements[FBProfileInfoKeys.email] as? String
        let phone = profileElements[FBProfileInfoKeys.phone] as? String
        let city = profileElements[FBProfileInfoKeys.city] as? String
        let preferences = profileElements[FBProfileInfoKeys.preferences]?.allObjects as? [String]
        let education = profileElements[FBProfileInfoKeys.education] as? String
        let work = profileElements[FBProfileInfoKeys.work] as? String
        let skills = profileElements[FBProfileInfoKeys.skills] as? String
    
        
        return ProfileInfoModel.init(
            firstName: firstName, secondName: secondName, photo: photo,
            dateOfBirth: dateOfBirth, email: email, phone: phone,
            city: city, preferences: preferences, education: education,
            work: work, skills: skills)
    }
    
}
