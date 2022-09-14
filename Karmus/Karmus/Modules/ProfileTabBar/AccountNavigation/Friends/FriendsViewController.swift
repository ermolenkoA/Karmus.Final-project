//
//  FriendsViewController.swift
//  Karmus
//
//  Created by VironIT on 9/5/22.
//

import UIKit
import KeychainSwift

final class FriendsViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet private weak var mainActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var requestButton: UIButton!
    @IBOutlet private weak var allFriendsButton: UIButton!
    @IBOutlet private weak var followersButton: UIButton!
    @IBOutlet private weak var addFriendButton: UIButton!
    
    @IBOutlet private weak var friendsTabelView: UITableView!
    
    // MARK: - Private Properties
    
    private var activeButton: UIButton?
    private var friends = [Friend]()
    private var buttons: [UIButton] { [
        requestButton,
        allFriendsButton,
        followersButton,
        addFriendButton
    ] }
    
    private var currentFriendProfile: ShortProfileInfoModel?
    private var currentFriendStatus: FriendsTypes?
    
    private let profileID = KeychainSwift.shared.get(ConstantKeys.currentProfile)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        friendsTabelView.delegate = self
        friendsTabelView.dataSource = self
        
        didTapFriendButton(allFriendsButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let backItem = UIBarButtonItem()
        backItem.title = " "
        navigationController?.viewControllers.dropLast().last?.navigationItem.backBarButtonItem = backItem
        self.title = "Список друзей"
        let newBackItem = UIBarButtonItem()
        newBackItem.title = "Мои друзья"
        navigationItem.backBarButtonItem = newBackItem
        
        tabBarController?.tabBar.isHidden = true
        
        if let currentFriendStatus = currentFriendStatus,
           let currentFriendProfile = currentFriendProfile {
            
            friends = []
            friendsTabelView.reloadData()
            
            buttons.forEach {
                $0.isUserInteractionEnabled = false
            }
            
            mainActivityIndicator.startAnimating()
            
            guard let profileID = profileID else {
                forceQuitFromProfile()
                return
            }
            
            FireBaseDataBaseManager.getFriends(profileID, where: getCurrentFriendType()) { [weak self] friends in
                
                self?.friends = friends ?? []
                self?.friendsTabelView.reloadData()
                
                self?.buttons.forEach {
                    $0.isUserInteractionEnabled = true
                }
                
                self?.mainActivityIndicator.stopAnimating()
                    
                if self?.getCurrentFriendType() == .friends && self!.friends.isEmpty {
                    showAlert("Ваш список друзей пуст", "Добавьте друзей и выполняйте задания вместе!", where: self)
                }
                
                self?.showShortProfileInfo(profile: currentFriendProfile, friendStatus: currentFriendStatus)
                
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        guard let profileID = profileID else {
            forceQuitFromProfile()
            return
        }
        
        FireBaseDataBaseManager.removeObserverFromFriendsList(profileID, where: getCurrentFriendType())
    }
    
    // MARK: - Private functions
    
    private func getCurrentFriendType() -> FriendsTypes {
        activeButton != allFriendsButton ? activeButton != followersButton ? .requests : .followers : .friends
    }
    
    private func startSearching(_ profileID: String){
        
        friends = []
        friendsTabelView.reloadData()
        
        buttons.forEach {
            $0.isUserInteractionEnabled = false
        }
        
        mainActivityIndicator.startAnimating()
        
        FireBaseDataBaseManager.getFriends(profileID, where: getCurrentFriendType())
        { [weak self] friends in
            
            self?.friends = friends ?? []
            self?.friendsTabelView.reloadData()
            
            self?.buttons.forEach {
                $0.isUserInteractionEnabled = true
            }
            
            self?.mainActivityIndicator.stopAnimating()
                
            if self?.getCurrentFriendType() == .friends && self!.friends.isEmpty {
                showAlert("Ваш список друзей пуст", "Добавьте друзей и выполняйте задания вместе!", where: self)
            }
            
        }
    }
    
    private func setActiveButton(_ button: UIButton?) {
        activeButton?.backgroundColor = #colorLiteral(red: 0.1108371988, green: 0, blue: 1, alpha: 1)
        activeButton = button
        activeButton?.backgroundColor = #colorLiteral(red: 0.03359736346, green: 0.4016051504, blue: 1, alpha: 1)
    }
    
    // MARK: - IBAction
    
    @IBAction func didTapFriendButton(_ sender: UIButton) {
        
        guard activeButton != sender else { return }
        
        guard let profileID = profileID else {
            forceQuitFromProfile()
            return
        }
        
        FireBaseDataBaseManager.removeObserverFromFriendsList(profileID, where: getCurrentFriendType())
        setActiveButton(sender)
        startSearching(profileID)
        
    }
    
    
    @IBAction func didTapAddFriendButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: StoryboardNames.addFriends, bundle: nil)
        guard let addFriendsVC = storyboard.instantiateInitialViewController() else {
            showAlert("Невозможно перейти на добавление друзей", "Повторите попытку позже", where: self)
            return
        }
        
        self.navigationController?.pushViewController(addFriendsVC, animated: true)
    }
    
}

// MARK: - UITableViewDelegate

extension FriendsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let profile = friends[indexPath.row]
        
        guard let myProfileID = KeychainSwift.shared.get(ConstantKeys.currentProfile) else { return }
        
        let profileInfo = ShortProfileInfoModel.init(login: profile.login,
                                                     firstName: profile.firstName,
                                                     secondName: profile.secondName,
                                                     numberOfRespects: String.makeStringFromNumber(profile.numberOfRespects),
                                                     numberOfFriends: String.makeStringFromNumber(profile.numberOfFriends),
                                                     photo: profile.photo,
                                                     profileType: profile.profileType)
        
        FireBaseDataBaseManager.getFriendStatus(myProfileID, friendLogin: profile.login) { [weak self] friendStatus in
            self?.showShortProfileInfo(profile: profileInfo, friendStatus: friendStatus)
        }
        

    }
    
    private func showShortProfileInfo(profile: ShortProfileInfoModel, friendStatus: FriendsTypes?){
        
        let storyboard = UIStoryboard(name: StoryboardNames.cutProfileScreen, bundle: nil)
        
        guard let shortProfileInfoVC = storyboard.instantiateInitialViewController() else {
            return
        }
        
        shortProfileInfoVC.modalPresentationStyle = .popover
        let popOverVC = shortProfileInfoVC.popoverPresentationController
        popOverVC?.delegate = self
        popOverVC?.sourceView = view
        popOverVC?.sourceRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        shortProfileInfoVC.preferredContentSize = CGSize(width: view.frame.width, height: 240 + view.frame.width*0.3)
        popOverVC?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        
        currentFriendProfile = nil
        currentFriendStatus = nil
        
        (shortProfileInfoVC as? GetShortProfileInfoProtocol)?.getShortProfileInfo(profile: profile, friendStatus, conclusion: { [weak self] in

            shortProfileInfoVC.dismiss(animated: true) {
                
                self?.currentFriendProfile = profile
                self?.currentFriendStatus = friendStatus
                
                let storyboard = UIStoryboard(name: StoryboardNames.fullProfileScreen, bundle: nil)
                
                guard let fullProfileInfoVC = storyboard.instantiateInitialViewController() else {
                    return
                }
                
                (fullProfileInfoVC as? SetLoginProtocol)?.setLogin(login: profile.login)
                self?.navigationController?.pushViewController(fullProfileInfoVC, animated: true)
            }
            
        })
        
        (shortProfileInfoVC as? SetSenderProtocol)?.setSender(self)
        
        self.present(shortProfileInfoVC, animated: true)
    }
    
}

// MARK: - UIPopoverPresentationControllerDelegate

extension FriendsViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}

// MARK: - UITableViewDataSource

extension FriendsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath)
        
        let friend = friends[indexPath.row]
        
        let name = friend.firstName + " " + friend.secondName
        let index = friend.city.firstIndex(of: ",")
        let city = index == nil ? friend.city
            : String(friend.city[friend.city.startIndex..<index!])
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        let date = friend.dateOfBirth != nil ? formatter.date(from: friend.dateOfBirth!) : nil
        
        (cell as? SetFriendsCellInfoProtocol)?.setFriendsInfo(photo: friend.photo,
                                                      name: name,
                                                      city: city,
                                                      onlineStatus: friend.onlineStatus,
                                                      login: friend.login,
                                                      dateOfBirth: date)
        
        return cell
    }
    
}

