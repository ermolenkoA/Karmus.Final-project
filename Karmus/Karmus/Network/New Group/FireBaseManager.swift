//
//  FireBaseManager.swift
//  Karmus
//
//  Created by User on 8/25/22.
//

import Foundation
import FirebaseDatabase

final class FireBaseDataBaseManager {
    
    private static let profiles =  Database.database().reference().child(FireBaseDefaultKeys.profiles)
    
    static let description = "<FireBaseDataBaseManager>"
    
    static func findLoginOrPhone(_ loginOrPhone: String, mode: FireBaseRequestMode, _ result: @escaping (FireBaseRequestResult) -> ()) {
        
        switch mode {
        case .findLogin:
            guard loginOrPhone ~= "^[A-Za-z]+([-_\\.]?[A-Za-z0-9]+){0,2}$" && loginOrPhone.count >= 3 else{
                print("\n \(self.description) ERROR: login is incorrect\n)")
                result(.error)
                return
            }
        case .findPhone:
            guard loginOrPhone ~= "^(\\+375)(29|25|33|44)([\\d]{7})$"  else{
                print("\n \(self.description) ERROR: login is incorrect\n)")
                result(.error)
                return
            }
        }
        
        profiles.observe(.value) { snapshot in
            
            guard snapshot.exists() else{
                print("\n\(self.description) ERROR: snapshot isn't exist\n")
                result(.error)
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
                
                switch mode {
                case .findLogin:
                    if profileElements[FireBaseProfileKeys.login] as? String == loginOrPhone {
                        result(.found)
                        return
                    }
                case .findPhone:
                    if profileElements[FireBaseProfileKeys.phoneNumber] as? String == loginOrPhone {
                        result(.found)
                        return
                    }
                }
    
            }
            result(.notFound)
            return
        
        }
        
    }
    
    
    static func openProfile(login: String, password: Int64, newPassword: Int64? = nil, _ result: @escaping (FireBaseOpenProfileResult) -> ()) {

        if !(login ~= "^([A-Za-z]+([-_\\.]?[A-Za-z0-9]+){0,2}){3,}$"){
            if !(login ~= "^(\\+375)(29|25|33|44)([\\d]{7})$") {
                result(.failure)
                return
            }
        }
        
        profiles.observe(.value) { snapshot in

            guard snapshot.exists() else{
                print("\n\(self.description) ERROR: snapshot isn't exist\n")
                result(.error)
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
                
                guard let loginFromData = profileElements[FireBaseProfileKeys.login] as? String else {
                    print("\n\(self.description) ERROR: profiles contains unvalid profile\\login\n")
                    result(.error)
                    return
                }
                
                guard let passwordFromData = profileElements[FireBaseProfileKeys.password] as? Int64 else {
                    print("\n\(self.description) ERROR: profiles contains unvalid profile\n")
                    result(.error)
                    return
                }
                
                if loginFromData != login {
                    guard let phoneNumber = profileElements[FireBaseProfileKeys.phoneNumber] as? String else {
                        print("\n\(self.description) ERROR: profiles contains unvalid profile\n")
                        continue
                    }
                    if phoneNumber != login {
                        continue
                    }
                }
                
                if password != passwordFromData {
                    continue
                }
                
                if let newPassword = newPassword {
                    self.profiles.child(profile.key).child(FireBaseProfileKeys.password).setValue(newPassword)
                }
                
                result(.success)
                return
            }
            result(.failure)
            return
        }
    }
    
    static func parseDataToProfileModel(_ data: DataSnapshot) -> ProfileModel? {
        
        guard let profileElements = data.value as? [String : AnyObject] else {
            print("\n\(self.description) ERROR: profiles contains unvalid profile\n")
            return nil
        }
        
        guard let firstName = profileElements[FireBaseProfileKeys.firstName] as? String else {
            print("\n\(self.description) ERROR: profiles contains unvalid profile\n")
            return nil
        }
        
        guard let secondName = profileElements[FireBaseProfileKeys.secondName] as? String else {
            print("\n\(self.description) ERROR: profiles contains unvalid profile\n")
            return nil
        }

        guard let dateOfBirth = profileElements[FireBaseProfileKeys.dateOfBirth] as? String else {
            print("\n\(self.description) ERROR: profiles contains unvalid profile\n")
            return nil
        }

        guard let login = profileElements[FireBaseProfileKeys.login] as? String else {
            print("\n\(self.description) ERROR: profiles contains unvalid profile\n")
            return nil
        }

        guard let password = profileElements[FireBaseProfileKeys.password] as? Int64 else {
            print("\n\(self.description) ERROR: profiles contains unvalid profile\n")
            return nil
        }

        guard let phoneNumber = profileElements[FireBaseProfileKeys.phoneNumber] as? String else {
            print("\n\(self.description) ERROR: profiles contains unvalid profile\n")
            return nil
        }
        
        guard let photo = profileElements[FireBaseProfileKeys.photo] as? String else {
            print("\n\(self.description) ERROR: profiles contains unvalid profile\n")
            return nil
        }
        return ProfileModel.init(dateOfBirth: dateOfBirth, firstName: firstName,
                                 login: login, password: password,
                                 phoneNumber: phoneNumber, photo: photo,
                                 secondName: secondName)
    }
}


