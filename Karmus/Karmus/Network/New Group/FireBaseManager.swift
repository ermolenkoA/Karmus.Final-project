//
//  FireBaseManager.swift
//  Karmus
//
//  Created by User on 8/25/22.
//

import Foundation
import FirebaseDatabase
import KeychainSwift

final class FireBaseDataBaseManager {
    
    private static let profiles =  Database.database().reference().child(FBDefaultKeys.profiles)
    private static let profilesInfo =  Database.database().reference().child(FBDefaultKeys.profilesInfo)
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
    
    static func openProfile(login: String, password: Int64, newPassword: Int64? = nil, _ result: @escaping (FireBaseOpenProfileResult, String?) -> ()) {

        if !(login ~= "^([A-Za-z]+([-_\\.]?[A-Za-z0-9]+){0,2}){3,}$"){
            if !(login ~= "^(\\+375)(29|25|33|44)([\\d]{7})$") {
                result(.failure, nil)
                return
            }
        }
        
        profiles.observeSingleEvent(of: .value) { snapshot in

            guard snapshot.exists() else{
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
    
    
    static func changeLoginInFriendAccounts(_ profileID: String, oldLogin: String, newLogin: String? = nil, _ conclusion: @escaping () -> ()) {
        profiles.child(profileID).observeSingleEvent(of: .value) { snapshot in
            
            guard snapshot.exists(), let myFriendsLists = parseDataToFriendsLists(snapshot) else {
                conclusion()
                return
            }
            
            let friends = myFriendsLists[FBProfileKeys.friends]!
            let followers = myFriendsLists[FBProfileKeys.followers]!
            let requests = myFriendsLists[FBProfileKeys.requests]!
            
            profiles.observeSingleEvent(of: .value) { snapshot in
                
                guard snapshot.exists() else{
                    conclusion()
                    return
                }
                
                guard let profiles = snapshot.children.allObjects as? [DataSnapshot] else {
                    conclusion()
                    return
                }
                
                for profile in profiles {
                    
                    guard let profileElements = profile.value as? [String : AnyObject],
                          let login = profileElements[FBProfileKeys.login] as? String else { continue }
                    
                    guard let key = friends.contains(login) ? FBProfileKeys.friends
                    : followers.contains(login) ? FBProfileKeys.requests
                            : requests.contains(login) ? FBProfileKeys.followers : nil else  {
                        print("\nMYLOG: 123123\n")
                        continue
                    }
                    
                    guard let friendFriendsList = parseDataToFriendsLists(snapshot) else {
                        continue
                    }
                    
                    var newFriendsList = friendFriendsList[key]!.filter{ $0 != oldLogin }
                    
                    if let newLogin = newLogin {
                        newFriendsList.append(newLogin)
                    }
                    
                    self.profiles.child(profile.key).child(key).setValue(newFriendsList)
                    
                }
                
                conclusion()
                
            }
        }
    }
    
    static func getFriends(_ profileID: String, where friendsType: FriendsTypes, _ result: @escaping ([Friend]?) -> ()) {
        
        let key = friendsType != .friends ? friendsType != .followers ? FBProfileKeys.requests : FBProfileKeys.followers : FBProfileKeys.friends
        
        profiles.child(profileID).child(key).observe(.value) { snapshot in
            
            print("\nMYLOG: Ну и шо\n")
            
            guard snapshot.exists() else {
                result(nil)
                return
            }
            
            guard var friendsLogins = snapshot.value as? [String] else {
                result(nil)
                return
            }
            
            profilesInfo.observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists() else{
                    result(nil)
                    return
                }
                
                guard let profiles = snapshot.children.allObjects as? [DataSnapshot] else {
                    result(nil)
                    return
                }
                
                var friends = [Friend]()
                
                for profile in profiles {
                    
                    guard let index = friendsLogins.firstIndex(of: profile.key) else {
                        continue
                    }
                    
                    guard let friend = parseDataToFriend(profile) else {
                        continue
                    }
                    
                    friends.append(friend)
                    friendsLogins.remove(at: index)
                }
                
                result(friends.isEmpty ? nil : friends)
                
            }
            
        }
        
    }
    
    static func getFriendStatus(_ profileID: String, friendLogin: String, conclusion: @escaping (FriendsTypes?) -> ()) {
        
        profiles.child(profileID).observeSingleEvent(of: .value) { snapshot in
            
            guard snapshot.exists() else {
                print("\n\(self.description)\\getFriendStatus ERROR: profiles isn't exist\n")
                return
            }
            
            guard let myFriendsLists = parseDataToFriendsLists(snapshot) else {
                print("\n\(self.description)\\getFriendStatus ERROR: profiles contains unvalid profile\n")
                return
            }
            
            if myFriendsLists[FBProfileKeys.friends]!.contains(friendLogin) {
                conclusion(.friends)
            } else if myFriendsLists[FBProfileKeys.followers]!.contains(friendLogin) {
                conclusion(.followers)
            } else if myFriendsLists[FBProfileKeys.requests]!.contains(friendLogin) {
                conclusion(.requests)
            } else {
                conclusion(nil)
            }
    
        }
        
    }
    
    static func searchProfiles(_ string: String = "", _ result: @escaping ([Friend]?) -> ()) {
        
        profilesInfo.observe(.value) { snapshot in
            
            
            guard snapshot.exists() else {
                result(nil)
                return
            }
           
            guard var profiles = snapshot.children.allObjects as? [DataSnapshot] else {
                result(nil)
                return
            }
            if let me = KeychainSwift.shared.get(ConstantKeys.currentProfileLogin) {
                profiles.removeAll(where: { $0.key == me })
            }
            
            if string != "" {
                profiles = profiles.filter {
                    $0.key.lowercased().contains(string.lowercased())
                }
            }
            
            var resultProfiles = [Friend]()
            
            for profile in profiles {
                
                guard let friend = parseDataToFriend(profile) else {
                    continue
                }

                resultProfiles.append(friend)
            }

            result(resultProfiles.isEmpty ? nil : resultProfiles)
        }
        
    }
    
    static func stopProfilesSearching() {
        profilesInfo.removeAllObservers()
    }
    
    static func removeObserverFromFriendsList(_ profileID: String, where friendsType: FriendsTypes) {
        
        let key = friendsType != .friends ? friendsType != .followers ? FBProfileKeys.requests : FBProfileKeys.followers : FBProfileKeys.friends
        
        profiles.child(profileID).child(key).removeAllObservers()
        
    }
    
    static func changeFriendsLists(profileID: String, myLogin: String,
                                   friendLogin: String, currentFriendType: FriendsTypes?,
                                   _ resultFriendType: @escaping (FriendsTypes?) -> ()) {
        
        profiles.child(profileID).observeSingleEvent(of: .value) { snapshot in
            
            guard snapshot.exists(), let myFriendsLists = parseDataToFriendsLists(snapshot) else { return }
            
            profiles.observeSingleEvent(of: .value) { snapshot in
                
                guard snapshot.exists(), let profiles = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                for profile in profiles {
                    
                    guard let profileElements = profile.value as? [String : AnyObject],
                          profileElements[FBProfileKeys.login] as? String == friendLogin,
                          let anotherFriendsList = parseDataToFriendsLists(profile) else { continue }
                    
                    switch currentFriendType {
                    
                    case .friends:
                        fallthrough
                        
                    case .requests:
                        removeFromFriends(profileID, myLogin, myFriendsLists,
                                     profile.key, friendLogin, anotherFriendsList,
                                     resultFriendType)
                        
                    case .followers:
                        fallthrough
                        
                    default:
                        acceptRequest(profileID, myLogin, myFriendsLists,
                                     profile.key, friendLogin, anotherFriendsList,
                                     resultFriendType)
                        
                    }
                    
                }
                
            }
            
        }
    }
    
    
    private static func removeFromFriends(_ myProfileID: String, _ myLogin: String,
                             _ myFriendsLists: [String : [String]], _ friendProfileID: String,
                             _ friendLogin: String, _ friendFriendsLists: [String : [String]],
                             _ resultFriendType: @escaping (FriendsTypes?) -> ()) {
        
        guard myFriendsLists[FBProfileKeys.friends]!.contains(friendLogin) else {
            
            profiles.child(myProfileID).child(FBProfileKeys.requests)
                .setValue(myFriendsLists[FBProfileKeys.requests]!.filter { $0 != friendLogin })
            profiles.child(friendProfileID).child(FBProfileKeys.followers)
                .setValue(friendFriendsLists[FBProfileKeys.followers]!.filter { $0 != myLogin })
            resultFriendType(nil)
            return
            
        }
        
        profiles.child(myProfileID).child(FBProfileKeys.friends)
            .setValue(myFriendsLists[FBProfileKeys.friends]!.filter { $0 != friendLogin })
        profiles.child(friendProfileID).child(FBProfileKeys.friends)
            .setValue(friendFriendsLists[FBProfileKeys.friends]!.filter { $0 != myLogin })
        
        var myFollowers = myFriendsLists[FBProfileKeys.followers]!
        myFollowers.append(friendLogin)
        var friendRequests = friendFriendsLists[FBProfileKeys.requests]!
        friendRequests.append(myLogin)
        
        profiles.child(myProfileID).child(FBProfileKeys.followers)
            .setValue(myFollowers)
        profiles.child(friendProfileID).child(FBProfileKeys.requests)
            .setValue(friendRequests)
        resultFriendType(.followers)
        
    }
    
    private static func acceptRequest(_ myProfileID: String, _ myLogin: String,
                             _ myFriendsLists: [String : [String]], _ friendProfileID: String,
                             _ friendLogin: String, _ friendFriendsLists: [String : [String]],
                             _ resultFriendType: @escaping (FriendsTypes?) -> ()) {
        
        guard myFriendsLists[FBProfileKeys.followers]!.contains(friendLogin) else {
            
            var myRequests = myFriendsLists[FBProfileKeys.requests]!
            myRequests.append(friendLogin)
            var friendFollowers = friendFriendsLists[FBProfileKeys.followers]!
            friendFollowers.append(myLogin)
            
            profiles.child(myProfileID).child(FBProfileKeys.requests)
                .setValue(myRequests)
            profiles.child(friendProfileID).child(FBProfileKeys.followers)
                .setValue(friendFollowers)
            resultFriendType(.requests)
            return
            
        }
        
        profiles.child(myProfileID).child(FBProfileKeys.followers)
            .setValue(myFriendsLists[FBProfileKeys.followers]!.filter { $0 != friendLogin })
        profiles.child(friendProfileID).child(FBProfileKeys.requests)
            .setValue(friendFriendsLists[FBProfileKeys.requests]!.filter { $0 != myLogin })
        
        var myFriends = myFriendsLists[FBProfileKeys.friends]!
        myFriends.append(friendLogin)
        var friendFriends = friendFriendsLists[FBProfileKeys.friends]!
        friendFriends.append(myLogin)
        
        profiles.child(myProfileID).child(FBProfileKeys.friends)
            .setValue(myFriends)
        profiles.child(friendProfileID).child(FBProfileKeys.friends)
            .setValue(friendFriends)
        resultFriendType(.friends)
        
    }
    
    
    static func createProfileObserver(_ profileID: String, _ login: String) {
        
        profiles.child(profileID).observe(.value) { snapshot in
            guard snapshot.exists() else {
                removeObserversFromProfile(profileID, login)
                removeAccountObservers(profileID, login)
                forceQuitFromProfile()
                return
            }
            
           
            profiles.child(profileID).child(FBProfileKeys.login).observe(.value) { snapshot in
                guard snapshot.exists() else {
                    removeObserversFromProfile(profileID, login)
                    removeAccountObservers(profileID, login)
                    forceQuitFromProfile()
                    return
                }
                
                guard let newLogin = snapshot.value as? String, newLogin == login else {
                    removeObserversFromProfile(profileID, login)
                    removeAccountObservers(profileID, login)
                    forceQuitFromProfile()
                    return
                }
                
            }
            
        }
        
        profilesInfo.child(login).observe(.value) { snapshot in
            
            guard snapshot.exists() else {
                removeObserversFromProfile(profileID, login)
                removeAccountObservers(profileID, login)
                forceQuitFromProfile()
                return
            }
        
            if snapshot.key != login {
                removeObserversFromProfile(profileID, login)
                removeAccountObservers(profileID, login)
                forceQuitFromProfile()
                return
            }
            
        }
        
        profiles.child(profileID).child(FBProfileKeys.profileUpdateDate)
            .observe(.value){ snapshot in
                
                guard snapshot.exists() else {
                    removeObserversFromProfile(profileID, login)
                    removeAccountObservers(profileID, login)
                    forceQuitFromProfile()
                    return
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
                
                if let dateString = snapshot.value as? String, let date = formatter.date(from: dateString)  {
                    
                    guard let lastLogInDate = UserDefaults.standard.value(forKey: ConstantKeys.lastLogInDate) as? Date,
                          lastLogInDate.isGreaterThanDate(dateToCompare: date) || lastLogInDate.equalToDate(dateToCompare: date) else {
                        removeObserversFromProfile(profileID, login)
                        removeAccountObservers(profileID, login)
                        forceQuitFromProfile()
                        return
                        
                    }

                }
                
            }
    
        profilesInfo.child(login).child(FBProfileInfoKeys.onlineStatus).observe(.value) { snapshot in
            guard let status = snapshot.value as? String, status != FBOnlineStatuses.blocked else {
                removeObserversFromProfile(profileID, login)
                removeAccountObservers(profileID, login)
                KeychainSwift.shared.delete(ConstantKeys.currentProfile)
                KeychainSwift.shared.delete(ConstantKeys.currentProfileLogin)
                UserDefaults.standard.setValue(Date?(nil), forKey: ConstantKeys.lastLogInDate)
                
                let storyboard = UIStoryboard(name: StoryboardNames.main, bundle: nil)
                let mainVC = storyboard.instantiateInitialViewController()!
                SceneDelegate.keyWindow?.rootViewController = mainVC
                SceneDelegate.keyWindow?.makeKeyAndVisible()
                showAlert("Ваш аккаунт был заблокирован", "Свяжитесь с администрацией", where: mainVC)
                return
            }
        }
        
    }
    
    static func removeAccountObservers(_ profileID: String, _ login: String) {
        
        profiles.child(profileID).child(FBProfileKeys.balance).removeAllObservers()
        profilesInfo.child(login).child(FBProfileInfoKeys.numberOfRespects).removeAllObservers()
        profilesInfo.child(login).child(FBProfileInfoKeys.numberOfFriends).removeAllObservers()
    }
    
    static func removeObserversFromProfile(_ profileID: String, _ login: String) {
        profiles.child(profileID).removeAllObservers()
        profiles.child(profileID).child(FBProfileKeys.login).removeAllObservers()
        profiles.child(profileID).child(FBProfileKeys.profileUpdateDate).removeAllObservers()
        profilesInfo.child(login).removeAllObservers()
        profilesInfo.child(login).child(FBProfileInfoKeys.onlineStatus).removeAllObservers()
    }
    
    static func setProfileUpdateDate(_ profileID: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let date = formatter.string(from: Date())
        profiles.child(profileID).child(FBProfileKeys.profileUpdateDate).setValue(date)
        
    }
    
    
    static func setObserverToNumberOfFriends(_ login: String, _ result: @escaping (Int?) -> ()) {
        
        profilesInfo.child(login).child(FBProfileInfoKeys.numberOfFriends).observe(.value){ snapshot in
            guard snapshot.exists() else {
                result(nil)
                return
            }
            
            result(snapshot.value as? Int)
        }
        
    }
    
    static func setObserverToNumberOfRespects(_ login: String, _ result: @escaping (Int?) -> ()) {
        
        profilesInfo.child(login).child(FBProfileInfoKeys.numberOfRespects).observe(.value){ snapshot in
            guard snapshot.exists() else {
  
                result(nil)
                return
            }

            result(snapshot.value as? Int)
        }
        
    }
    
    static func setObserverToBalance(_ profileID: String, _ result: @escaping (Int?) -> ()) {
        
        profiles.child(profileID).child(FBProfileKeys.balance).observe(.value){ snapshot in
            guard snapshot.exists() else {
                result(nil)
                return
            }
            
            result(snapshot.value as? Int)
        }
        
    }
    
    static func getProfileInfo(_ login: String, _ result: @escaping (ProfileInfoModel?) -> ()) {
        
        profilesInfo.child(login).observeSingleEvent(of: .value){ snapshot in
            guard snapshot.exists() else {
                result(nil)
                return
            }
            result(parseDataToProfileInfo(snapshot))
        }
        
    }
    
    static func getProfileUpdateDate(_ profileID: String, _ result: @escaping (String?) -> ()) {
        
        profiles.child(profileID).child(FBProfileKeys.profileUpdateDate).observeSingleEvent(of: .value){ snapshot in
            guard snapshot.exists() else {
                result(nil)
                return
            }
            result(snapshot.value as? String)
        }
        
    }
      
    static func getProfileLogin(_ profileID: String, _ result: @escaping (String?) -> ()) {
        
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
        let numberOfRespects = profileElements[FBProfileInfoKeys.numberOfRespects] as? Int
        let numberOfFriends = profileElements[FBProfileInfoKeys.numberOfFriends] as? Int
        let profileType = profileElements[FBProfileInfoKeys.profileType] as? String
        let sponsorName = profileElements[FBProfileInfoKeys.sponsorName] as? String
        let onlineStatus = profileElements[FBProfileInfoKeys.onlineStatus] as? String
        
        return ProfileInfoModel.init(
            firstName: firstName, secondName: secondName, photo: photo,
            dateOfBirth: dateOfBirth, email: email, phone: phone,
            city: city, preferences: preferences, education: education,
            work: work, skills: skills, numberOfRespects: numberOfRespects,
            numberOfFriends: numberOfFriends, profileType: profileType,
            sponsorName: sponsorName, onlineStatus: onlineStatus)
    }
    
   private static func parseDataToFriend(_ data: DataSnapshot) -> Friend? {
        
        guard let profileElements = data.value as? [String : AnyObject] else { return nil }
        
        guard let firstName = profileElements[FBProfileInfoKeys.firstName] as? String,
        let secondName = profileElements[FBProfileInfoKeys.secondName] as? String,
        let photo = profileElements[FBProfileInfoKeys.photo] as? String,
        let city = profileElements[FBProfileInfoKeys.city] as? String,
        let profileType = profileElements[FBProfileInfoKeys.profileType] as? String,
        let onlineStatus = profileElements[FBProfileInfoKeys.onlineStatus] as? String,
        let numberOfRespects = profileElements[FBProfileInfoKeys.numberOfRespects] as? Int,
        let numberOfFriends = profileElements[FBProfileInfoKeys.numberOfFriends] as? Int,
        profileType != FBProfileTypes.sponsor else {
            return nil
        }
    
        let dateOfBirth = profileElements[FBProfileInfoKeys.dateOfBirth] as? String
    
        return Friend.init(login: data.key, firstName: firstName, secondName: secondName,
                           photo: photo, city: city, dateOfBirth: dateOfBirth,
                           onlineStatus: onlineStatus, numberOfFriends: numberOfFriends,
                           numberOfRespects: numberOfRespects, profileType: profileType)
    }
    
    private static func parseDataToFriendsLists(_ data: DataSnapshot) -> [String : [String]]? {
         
        guard let profileElements = data.value as? [String : AnyObject] else { return nil }
        let friends = profileElements[FBProfileKeys.friends] as? [String] ?? []
        let followers = profileElements[FBProfileKeys.followers] as? [String] ?? []
        let requests = profileElements[FBProfileKeys.requests] as? [String] ?? []
        
        return [
            FBProfileKeys.friends: friends,
            FBProfileKeys.followers: followers,
            FBProfileKeys.requests: requests
        ]
     }
    
}
