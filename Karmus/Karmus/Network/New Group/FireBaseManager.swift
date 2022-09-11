//
//  FireBaseManager.swift
//  Karmus
//
//  Created by User on 8/25/22.
//

import Foundation
import Firebase
import FirebaseDatabase
import KeychainSwift
import Kingfisher

typealias Chat = (chatID: String, interlocutor: ProfileForChatModel, messages: [MessageModel])

final class FireBaseDataBaseManager {
    
    // MARK: - Private Properties

    private static let profiles =  Database.database().reference().child(FBDefaultKeys.profiles)
    private static let profilesInfo =  Database.database().reference().child(FBDefaultKeys.profilesInfo)
    private static let topics =  Database.database().reference().child(FBDefaultKeys.topics)
    private static let chats =  Database.database().reference().child(FBDefaultKeys.chats)
    
    private static var closure: ((Friend?, [DataSnapshot]) -> ())?
    private static var newClosure: ((ProfileForChatModel?, [DataSnapshot]) -> ())?
    private static var chatClosure: ((Chat?, [DataSnapshot]) -> ())?
    
    // MARK: - Description
    
    static let description = "<FireBaseDataBaseManager>"
    
    // MARK: - Get private info from account
    
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
    
    // MARK: - Set private info into account
    
    static func setProfileUpdateDate(_ profileID: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let date = formatter.string(from: Date())
        profiles.child(profileID).child(FBProfileKeys.profileUpdateDate).setValue(date)
        
    }
    
    // MARK: - Get public info from account
    
    static func getCurrentNumberOfSessions() {
        guard let login = KeychainSwift.shared.get(ConstantKeys.currentProfileLogin) else { return }
        
        profilesInfo.child(login).observeSingleEvent(of: .value) { snapshot in
            
            guard snapshot.exists(),
                  let elements = snapshot.value as? [String : AnyObject],
                  let numberOfSessions = elements[FBProfileInfoKeys.numberOfSessions] as? Int,
                  let onlineStatus = elements[FBProfileInfoKeys.onlineStatus] as? String else {
                forceQuitFromProfile()
                return
            }
            
            setNumberOfSessions(login, onlineStatus, numberOfSessions: numberOfSessions + 1)
        }
        
    }
    
    static func getProfilePhoto(_ login: String, _ result: @escaping (String?) -> ()) {
        
        profilesInfo.child(login).observeSingleEvent(of: .value){ snapshot in
            guard snapshot.exists() else {
                result(nil)
                return
            }
            guard let profileElements = snapshot.value as? [String : AnyObject] else {
                
                result(nil)
                return
    
            }
            
            result(profileElements[FBProfileInfoKeys.photo] as? String)
        }
        
    }
    
    static func getProfileInfo(_ login: String, _ result: @escaping (ProfileInfoModel?) -> ()) {
        
        profilesInfo.child(login).observeSingleEvent(of: .value){ snapshot in
            guard snapshot.exists() else {
                result(nil)
                return
            }
            parseDataToProfileInfo(snapshot) { profileInfo in
                result(profileInfo)
            }
        }
        
    }
    
    // MARK: - Set public info into account

    static func setNumberOfSessions(_ login: String, _ currentOnlinestatus: String, numberOfSessions: Int) {

        profilesInfo.child(login).child(FBProfileInfoKeys.numberOfSessions).setValue(numberOfSessions)
        KeychainSwift.shared.set(true, forKey: ConstantKeys.isProfileActive)
        if numberOfSessions == 1 && currentOnlinestatus != FBOnlineStatuses.blocked {
            profilesInfo.child(login).child(FBProfileInfoKeys.onlineStatus).setValue(FBOnlineStatuses.online)
        }
        setSessionObserver(login)
        
    }
    
    static func uploadPhoto(_ image: UIImage, completion: @escaping ((_ url: URL?) -> ())){
        let storageRef = Storage.storage().reference().child("imageTasks")
        let imageData = image.jpegData(compressionQuality: 0.8)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.putData(imageData!, metadata: metaData) {(metaData, error) in
            guard metaData != nil else {
                completion(nil)
                return
            }
                storageRef.downloadURL(completion: {(url, error) in
                    completion(url)
                })
            }
    }
    
    // MARK: - Profiles searching
    
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
            
            guard !profiles.isEmpty else {
                result(nil)
                return
            }
            
            var resultProfiles = [Friend]()
            
            closure = { friend, newProfiles in
                
                if let friend = friend {
                    resultProfiles.append(friend)
                }
                
                if !newProfiles.isEmpty {
                    parseDataToFriend(friends: newProfiles, conclusion: self.closure!)
                } else {
                    result(resultProfiles)
                    closure = nil
                }
                
            }
            
            parseDataToFriend(friends: profiles, conclusion: closure!)
        }
        
    }
    
    static func searchAllProfiles(_ string: String = "", _ result: @escaping ([ProfileForChatModel]?) -> ()) {
        
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
            
            guard !profiles.isEmpty else {
                result(nil)
                return
            }
            
            var resultProfiles = [ProfileForChatModel]()
            
            newClosure = { profile, newProfiles in
                
                if let profile = profile {
                    resultProfiles.append(profile)
                }
                
                if !newProfiles.isEmpty {
                    parseDataToProfileForChatModel(profiles: newProfiles, conclusion: self.newClosure!)
                } else {
                    result(resultProfiles)
                    newClosure = nil
                }
                
            }
            
            parseDataToProfileForChatModel(profiles: profiles, conclusion: newClosure!)
        }
        
    }
    
    static func stopProfilesSearching() {
        profilesInfo.removeAllObservers()
    }
    
    // MARK: - Friends Settings
    
    static func getFriends(_ profileID: String, where friendsType: FriendsTypes, _ result: @escaping ([Friend]?) -> ()) {
        
        let key = friendsType != .friends ? friendsType != .followers ? FBProfileKeys.requests : FBProfileKeys.followers : FBProfileKeys.friends
        
        profiles.child(profileID).child(key).observe(.value) { snapshot in
            
            guard snapshot.exists(), let friendsLogins = snapshot.value as? [String]  else {
                result(nil)
                return
            }
            
            profilesInfo.observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists() else{
                    result(nil)
                    return
                }
                
                guard var profiles = snapshot.children.allObjects as? [DataSnapshot] else {
                    result(nil)
                    return
                }
                
                var friends = [Friend]()
                
                while let profile = profiles.first  {
                    
                    guard friendsLogins.contains(profile.key) else {
                        profiles.removeFirst()
                        continue
                    }
                    
                    closure = { friend, newProfiles in
                        
                        if let friend = friend {
                            friends.append(friend)
                        }
                        
                        if newProfiles.isEmpty {
                            closure = nil
                            result(friends)
                        }
                        
                        var newProfiles = newProfiles
                        
                        while let profile = newProfiles.first  {
                            
                            guard friendsLogins.contains(profile.key) else {
                                newProfiles.removeFirst()
                                continue
                            }
                            
                            parseDataToFriend(friends: newProfiles, conclusion: closure!)
                            break
                        }
                        
                        if newProfiles.isEmpty {
                            closure = nil
                            result(friends)
                        }
                        
                    }
                    
                    parseDataToFriend(friends: profiles, conclusion: closure!)
                    break
                }
                
                if profiles.isEmpty {
                    result(nil)
                }
                
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
        
        profilesInfo.child(myLogin)
            .child(FBProfileInfoKeys.numberOfFriends).observeSingleEvent(of: .value) { snapshot in
                
                if snapshot.exists(), var numberOfFriends = snapshot.value as? Int {
                    numberOfFriends -= 1
                    profilesInfo.child(myLogin)
                        .child(FBProfileInfoKeys.numberOfFriends).setValue(numberOfFriends)
                }
                
                profilesInfo.child(friendLogin)
                    .child(FBProfileInfoKeys.numberOfFriends).observeSingleEvent(of: .value) { snapshot in
                        
                        if snapshot.exists(), var numberOfFriends = snapshot.value as? Int {
                            numberOfFriends -= 1
                            profilesInfo.child(friendLogin)
                                .child(FBProfileInfoKeys.numberOfFriends).setValue(numberOfFriends)
                        }
                        
                    }
            }
        
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
        
        profilesInfo.child(myLogin)
            .child(FBProfileInfoKeys.numberOfFriends).observeSingleEvent(of: .value) { snapshot in
                
                if snapshot.exists(), var numberOfFriends = snapshot.value as? Int {
                    numberOfFriends += 1
                    profilesInfo.child(myLogin)
                        .child(FBProfileInfoKeys.numberOfFriends).setValue(numberOfFriends)
                }
                
                profilesInfo.child(friendLogin)
                    .child(FBProfileInfoKeys.numberOfFriends).observeSingleEvent(of: .value) { snapshot in
                        
                        if snapshot.exists(), var numberOfFriends = snapshot.value as? Int {
                            numberOfFriends += 1
                            profilesInfo.child(friendLogin)
                                .child(FBProfileInfoKeys.numberOfFriends).setValue(numberOfFriends)
                        }
                        
                    }
                
            }
        
        resultFriendType(.friends)
        
    }
    
    // MARK: - Chat Settings
    
    static func getChatsIDs(conclusion: @escaping ([String]) -> ()){
        
        guard let login = KeychainSwift.shared.get(ConstantKeys.currentProfileLogin) else {
            forceQuitFromProfile()
            return
        }
        
        chats.observeSingleEvent(of: .value) { snapshot in
            
            guard snapshot.exists(), let allChats = snapshot.children.allObjects as? [DataSnapshot] else {
                conclusion([String]())
                return
            }
            
            conclusion(
            
                allChats.filter {
                    if let chat = $0.value as? [String : Any],
                       let members = chat[FBChatKeys.members] as? [String],
                       members.contains(login) {
                        return true
                    } else {
                        return false
                    }
                }.map{ $0.key }
            
            )
            
        }
        
    }
    
    static func sendMessage(_ chatID: String, message: Message, conclusion: @escaping (Bool) -> ()) {
        
        chats.child(chatID).child(FBChatKeys.messages).observeSingleEvent(of: .value) { snapshot in
            
            guard snapshot.exists(), var allMassages = snapshot.value as? [[String : Any]] else {
                conclusion(false)
                return
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy HH:mm"
            
            var messageText = ""
            
            switch message.kind {
            case .text(let messageTxt):
                messageText = messageTxt
            default:
                conclusion(false)
                return
            }
            
            var newMassage = [String : Any]()
            newMassage[FBChatMessageKeys.sender] = message.sender.senderId
            newMassage[FBChatMessageKeys.sentDate] = formatter.string(from: message.sentDate)
            newMassage[FBChatMessageKeys.messageText] = messageText
            newMassage[FBChatMessageKeys.isRead] = false

            allMassages.append(newMassage)
            
            chats.child(chatID).child(FBChatKeys.messages).setValue(allMassages)
            conclusion(true)
            
        }
        
    }
    
    static func createNewChat(interlocutorLogin: String, message: Message, conclusion: @escaping (Bool) -> ()) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        var messageText = ""
        
        switch message.kind {
        case .text(let messageTxt):
            messageText = messageTxt
        default:
            conclusion(false)
            return
        }
        
        chats.childByAutoId().setValue([
            
            FBChatKeys.members : [message.sender.senderId, interlocutorLogin],
            FBChatKeys.messages : [
        
                [
                    FBChatMessageKeys.sender : message.sender.senderId,
                    FBChatMessageKeys.sentDate : formatter.string(from: message.sentDate),
                    FBChatMessageKeys.messageText : messageText,
                    FBChatMessageKeys.isRead : false
                
                ]
            
            ]
        ]) { error, _ in
            
            guard error == nil else {
                conclusion(false)
                return
            }
            conclusion(true)
            
        }
        
    }
    
    static func getChatMessages(_ chatID: String, conclusion: @escaping ([Message]) -> ()) {
        
        chats.child(chatID).observe(.childChanged) { snapshot in
            
            guard let chatElements = snapshot.value as? [String : AnyObject],
                  let messages = chatElements[FBChatKeys.messages] as? [[String : AnyObject]] else {
                
                conclusion([Message]())
                return
                
            }
            
            var allMessages = [Message]()
            
            var counter = 0
            
            for message in messages {
                guard let sender = message[FBChatMessageKeys.sender] as? String,
                      let sentDate = message[FBChatMessageKeys.sentDate] as? String,
                      let messageText = message[FBChatMessageKeys.messageText] as? String,
                      let isRead = message[FBChatMessageKeys.isRead] as? Bool else {
                    
                    conclusion([Message]())
                    return
                    
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy HH:mm"
                
                allMessages.append(Message(sender: Sender(senderId: sender, displayName: ""),
                                           messageId: String(counter),
                                           sentDate: formatter.date(from: sentDate)!,
                                           kind: .text(messageText),
                                           isRead: isRead))
                counter += 1
            }
            
        }
        
    }
    
    static func getChatsInfo(_ chatIDs: [String], conclusion: @escaping ([Chat]) -> ()) {
        
        chats.observeSingleEvent(of: .value) { snapshot in
            
            var chats = [Chat]()
            
            guard snapshot.exists(), var allChats = snapshot.children.allObjects as? [DataSnapshot] else {
                conclusion(chats)
                return
            }
            
            allChats = allChats.filter{ chatIDs.contains($0.key) }
            
            if allChats.isEmpty {
                conclusion(chats)
                return
            }
            
            chatClosure = { chat, remainingChats in
                
                if let chat = chat {
                    chats.append(chat)
                }
                
                if remainingChats.isEmpty {
                    closure = nil
                    conclusion(chats)
                }
                
                parseDataToChatInfo(remainingChats, conclusion: self.chatClosure!)

                
            }
            
            parseDataToChatInfo(allChats, conclusion: chatClosure!)
            
        }
        
    }
    
    static func findChat(_ interlocutorLogin: String, conclusion: @escaping (String?) -> ()) {
        
        guard let login = KeychainSwift.shared.get(ConstantKeys.currentProfileLogin) else {
            forceQuitFromProfile()
            return
        }
        
        chats.observeSingleEvent(of: .value) { snapshot in
            
            guard snapshot.exists(), let allChats = snapshot.children.allObjects as? [DataSnapshot] else {
                conclusion(nil)
                return
            }
            
            let chats = allChats.filter {
                if let elements = $0.value as? [String: Any],
                let members = elements[FBChatKeys.members] as? [String],
                members.contains(login) && members.contains(interlocutorLogin) {
                    return true
                }
                return false
            }
            
            conclusion(chats.isEmpty ? nil : chats.first!.key )
            
        }
        
    }
    
    // MARK: - Session Settings
    
    static func removeSession() {
        
        guard let login = KeychainSwift.shared.get(ConstantKeys.currentProfileLogin),
              let numberOfSessionsStr = KeychainSwift.shared.get(ConstantKeys.numberOfSessions),
              let numberOfSessions = Int(numberOfSessionsStr),
              numberOfSessions > 0 else { return }
        
        profilesInfo.child(login).child(FBProfileInfoKeys.numberOfSessions).cancelDisconnectOperations()
        profilesInfo.child(login).child(FBProfileInfoKeys.numberOfSessions).removeAllObservers()
        profilesInfo.child(login).child(FBProfileInfoKeys.numberOfSessions).setValue(numberOfSessions - 1)
        KeychainSwift.shared.delete(ConstantKeys.numberOfSessions)
        
        if numberOfSessions - 1 == 0 {
            profilesInfo.child(login).child(FBProfileInfoKeys.onlineStatus).setValue(FBOnlineStatuses.offline)
        }

    }
    
    // MARK: - Observers
    
    static func createChatsObserver(conclusion: @escaping () -> ()) {
        chats.observe(.childChanged) { snapshot in
            conclusion()
        }
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
                
                guard let numberOfSessionsStr = KeychainSwift.shared.get(ConstantKeys.numberOfSessions),
                      let numberOfSessions = Int(numberOfSessionsStr),
                      numberOfSessions > 0 else { return }
                profilesInfo.child(login).child(FBProfileInfoKeys.numberOfSessions).cancelDisconnectOperations()
                profilesInfo.child(login).child(FBProfileInfoKeys.numberOfSessions).removeAllObservers()
                profilesInfo.child(login).child(FBProfileInfoKeys.onlineStatus).cancelDisconnectOperations()
                profilesInfo.child(login).child(FBProfileInfoKeys.numberOfSessions).setValue(0)
                KeychainSwift.shared.delete(ConstantKeys.numberOfSessions)

                KeychainSwift.shared.delete(ConstantKeys.isProfileActive)
                KeychainSwift.shared.delete(ConstantKeys.currentProfile)
                KeychainSwift.shared.delete(ConstantKeys.currentProfileLogin)
                UserDefaults.standard.setValue(Date?(nil), forKey: ConstantKeys.lastLogInDate)
                
                let storyboard = UIStoryboard(name: StoryboardNames.main, bundle: nil)
                let mainVC = storyboard.instantiateInitialViewController()!
                SceneDelegate.keyWindow?.rootViewController = mainVC
                ((mainVC as? UINavigationController)?.viewControllers.first as? ViewController)?.accountWasBlocked = true
                SceneDelegate.keyWindow?.makeKeyAndVisible()
                return
            }
        }
        
    }
    
    static func setSessionObserver(_ login: String) {
        
        profilesInfo.child(login).child(FBProfileInfoKeys.numberOfSessions).observe(.value) { snapshot in
            
            guard snapshot.exists(), let numberOfSessions = snapshot.value as? Int else {
                forceQuitFromProfile()
                return
            }
        
            KeychainSwift.shared.set(String(numberOfSessions), forKey: ConstantKeys.numberOfSessions)
            
            profilesInfo.child(login).child(FBProfileInfoKeys.numberOfSessions).onDisconnectSetValue(numberOfSessions - 1)
            
            if numberOfSessions - 1 == 0 {
                profilesInfo.child(login).child(FBProfileInfoKeys.onlineStatus).onDisconnectSetValue(FBOnlineStatuses.offline)
            }
            
        }

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
        
        profilesInfo.removeAllObservers()
        
        profiles.child(profileID).child(FBProfileKeys.friends).removeAllObservers()
        profiles.child(profileID).child(FBProfileKeys.followers).removeAllObservers()
        profiles.child(profileID).child(FBProfileKeys.requests).removeAllObservers()

        chats.removeAllObservers()
    }
    
    static func removeObserverFromFriendsList(_ profileID: String, where friendsType: FriendsTypes) {
        
        let key = friendsType != .friends ? friendsType != .followers ? FBProfileKeys.requests : FBProfileKeys.followers : FBProfileKeys.friends
        
        profiles.child(profileID).child(key).removeAllObservers()
        
    }
    
    static func removeCurrentChatObserver(_ chatID: String) {
        chats.child(chatID).child(FBChatKeys.messages).removeAllObservers()
    }
    
    // MARK: - Data parsing
    
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
    
    static func parseDataToProfileInfo(_ data: DataSnapshot, conclusion: @escaping (ProfileInfoModel?) -> ())  {
        
        guard let profileElements = data.value as? [String : AnyObject] else {
            conclusion(nil)
            return
        }
        
        let firstName = profileElements[FBProfileInfoKeys.firstName] as? String
        let secondName = profileElements[FBProfileInfoKeys.secondName] as? String
        let photoName = profileElements[FBProfileInfoKeys.photo] as? String
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
        let numberOfSessions = profileElements[FBProfileInfoKeys.numberOfSessions] as? Int
        
        if photoName == ProfileModelConstants.defaultPhoto {
            conclusion(
                ProfileInfoModel.init(
                    firstName: firstName, secondName: secondName, photo: UIImage(named: "jpgDefaultProfile")!,
                    photoName: photoName!, dateOfBirth: dateOfBirth, email: email,
                    phone: phone, city: city, preferences: preferences, education: education,
                    work: work, skills: skills, numberOfRespects: numberOfRespects,
                    numberOfFriends: numberOfFriends, profileType: profileType, sponsorName: sponsorName,
                    onlineStatus: onlineStatus, numberOfSessions: numberOfSessions)
            )
        } else if let name = photoName{
            let url = URL(string: name)
            if let url = url {
            KingfisherManager.shared.retrieveImage(with: url as Resource, options: nil, progressBlock: nil) { (image, error, cache, imageURL) in
                    guard let image = image else {
                        conclusion(nil)
                        return
                    }
                    conclusion(
                        ProfileInfoModel.init(
                            firstName: firstName, secondName: secondName, photo: image,
                            photoName: photoName!, dateOfBirth: dateOfBirth, email: email,
                            phone: phone, city: city, preferences: preferences, education: education,
                            work: work, skills: skills, numberOfRespects: numberOfRespects,
                            numberOfFriends: numberOfFriends, profileType: profileType, sponsorName: sponsorName,
                            onlineStatus: onlineStatus, numberOfSessions: numberOfSessions)
                    )
                }
            }
        } else { conclusion(nil) }
        
    }
    
    private static func parseDataToFriend(friends: [DataSnapshot], conclusion: @escaping (Friend?, [DataSnapshot]) -> ()) {
        
        let friend = friends.first!
        
        guard let profileElements = friend.value as? [String : AnyObject] else {
            conclusion(nil, [DataSnapshot](friends.dropFirst()))
            return
        }
        
        guard let firstName = profileElements[FBProfileInfoKeys.firstName] as? String,
              let secondName = profileElements[FBProfileInfoKeys.secondName] as? String,
              let photoName = profileElements[FBProfileInfoKeys.photo] as? String,
              let city = profileElements[FBProfileInfoKeys.city] as? String,
              let profileType = profileElements[FBProfileInfoKeys.profileType] as? String,
              let onlineStatus = profileElements[FBProfileInfoKeys.onlineStatus] as? String,
              let numberOfRespects = profileElements[FBProfileInfoKeys.numberOfRespects] as? Int,
              let numberOfFriends = profileElements[FBProfileInfoKeys.numberOfFriends] as? Int,
              profileType != FBProfileTypes.sponsor else {
            
            conclusion(nil, [DataSnapshot](friends.dropFirst()))
            return
            
        }
        
        
        let dateOfBirth = profileElements[FBProfileInfoKeys.dateOfBirth] as? String
        
        if photoName == ProfileModelConstants.defaultPhoto {
            conclusion(
                Friend.init(login: friend.key, firstName: firstName, secondName: secondName,
                                   photo: UIImage(named: "jpgDefaultProfile")!, city: city, dateOfBirth: dateOfBirth,
                                   onlineStatus: onlineStatus, numberOfFriends: numberOfFriends,
                                   numberOfRespects: numberOfRespects, profileType: profileType),
                [DataSnapshot](friends.dropFirst())
            )
        } else {
            let url = URL(string: photoName)
            if let url = url {
                KingfisherManager.shared.retrieveImage(with: url as Resource,
                                                       options: nil, progressBlock: nil){ (image, error, cache, imageURL) in
                    guard let image = image else {
                        conclusion(nil, [DataSnapshot](friends.dropFirst()))
                        return
                    }
                    
                    conclusion(
                        Friend.init(login: friend.key, firstName: firstName, secondName: secondName,
                                           photo: image, city: city, dateOfBirth: dateOfBirth,
                                           onlineStatus: onlineStatus, numberOfFriends: numberOfFriends,
                                           numberOfRespects: numberOfRespects, profileType: profileType),
                        [DataSnapshot](friends.dropFirst())
                    )
                }
            }
        }

    }
    
    private static func parseDataToProfileForChatModel(profiles: [DataSnapshot],
                                                       conclusion: @escaping (ProfileForChatModel?,[DataSnapshot]) -> ()) {
        
        let profile = profiles.first!
        
        guard let profileElements = profile.value as? [String : Any] else {
            conclusion(nil, [DataSnapshot](profiles.dropFirst()))
            return
        }
        
        
        guard let photoName = profileElements[FBProfileInfoKeys.photo] as? String,
              let profileType = profileElements[FBProfileInfoKeys.profileType] as? String,
              let onlineStatus = profileElements[FBProfileInfoKeys.onlineStatus] as? String else {

            conclusion(nil, [DataSnapshot](profiles.dropFirst()))
            return
            
        }
        
        var name = "Неизвестный пользователь"
        var city = "Город"
        let dateOfBirth = profileElements[FBProfileInfoKeys.dateOfBirth] as? String
        
        if profileType == FBProfileTypes.sponsor {
            
           if let sponsorName = profileElements[FBProfileInfoKeys.sponsorName] as? String {
                name = sponsorName
           }
            
        } else {
            
            guard let firstName = profileElements[FBProfileInfoKeys.firstName] as? String,
                  let secondName = profileElements[FBProfileInfoKeys.secondName] as? String,
                  let userCity = profileElements[FBProfileInfoKeys.city] as? String else {
                conclusion(nil, [DataSnapshot](profiles.dropFirst()))
                return
            }
            
            name = firstName + " " + secondName
            city = userCity
        }
        
        if photoName == ProfileModelConstants.defaultPhoto {
            
            conclusion(
                ProfileForChatModel.init(login: profile.key, name: name,
                                         photo: UIImage(named: "jpgDefaultProfile")!, city: city,
                                         dateOfBirth: dateOfBirth, onlineStatus: onlineStatus,
                                         profileType: profileType),
                [DataSnapshot](profiles.dropFirst())
            )
            
        } else {
            
            let url = URL(string: photoName)
            if let url = url {
                
                KingfisherManager.shared.retrieveImage(with: url as Resource, options: nil, progressBlock: nil){ (image, error, cache, imageURL) in
                    
                    guard let image = image else {
                        conclusion(nil, [DataSnapshot](profiles.dropFirst()))
                        return
                    }
                    
                    conclusion(
                        ProfileForChatModel.init(login: profile.key, name: name,
                                                 photo: image, city: city,
                                                 dateOfBirth: dateOfBirth, onlineStatus: onlineStatus,
                                                 profileType: profileType),
                        [DataSnapshot](profiles.dropFirst())
                    )
                    
                }
                
            }
            
        }

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
    
    private static func parseDataToChatInfo(_ chats: [DataSnapshot],
                                            conclusion: @escaping (Chat?, [DataSnapshot]) -> ()) {
        
        let chat = chats.first!
        
        guard let login = KeychainSwift.shared.get(ConstantKeys.currentProfileLogin) else { return }
        
        guard let chatElements = chat.value as? [String : AnyObject],
              let members = chatElements[FBChatKeys.members] as? [String],
              let messages = chatElements[FBChatKeys.messages] as? [[String : AnyObject]] else {
            
            conclusion( nil, [DataSnapshot](chats.dropFirst()) )
            return
            
        }
        
        var allMessages = [MessageModel]()
    
       
        
        let lastMassageDate = messages.last![FBChatMessageKeys.sentDate] as! String
        
        for message in messages {
            guard let sender = message[FBChatMessageKeys.sender] as? String,
                  let sentDate = message[FBChatMessageKeys.sentDate] as? String,
                  let messageText = message[FBChatMessageKeys.messageText] as? String,
                  let isRead = message[FBChatMessageKeys.isRead] as? Bool,
                  (lastMassageDate == sentDate || isRead == false) else {
                
                conclusion( nil, [DataSnapshot](chats.dropFirst()) )
                return
                
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy HH:mm"
            
            allMessages.append(MessageModel(sender: sender,
                                            sentDate: formatter.date(from: sentDate)!,
                                            messageText: messageText,
                                            isRead: isRead))
        }
    
        profilesInfo.child(members.first{ $0 != login }!).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                conclusion( nil, [DataSnapshot](chats.dropFirst()) )
                return
            }
            
            parseDataToProfileForChatModel(profiles: [snapshot]) { interlocutor, _ in
                if let interlocutor = interlocutor {
                    conclusion( (chat.key, interlocutor, allMessages), [DataSnapshot](chats.dropFirst()) )
                } else {
                    conclusion( nil, [DataSnapshot](chats.dropFirst()) )
                }
            }
        }
        
        
        
     }
    
    // MARK: - Get other info
    
    static func getTopics(_ result: @escaping ([String]?) -> ()){
        
        topics.observeSingleEvent(of: .value){ snapshot in
            guard snapshot.exists() else {
                result(nil)
                return
            }
            result(snapshot.value as? [String])
        }
        
    }
    
}
