//
//  FriendsViewController.swift
//  Karmus
//
//  Created by VironIT on 9/5/22.
//

import UIKit
import KeychainSwift

final class FriendsViewController: UIViewController {

    @IBOutlet weak var mainActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var requestButton: UIButton!
    @IBOutlet private weak var allFriendsButton: UIButton!
    @IBOutlet private weak var followersButton: UIButton!
    @IBOutlet private weak var addFriendButton: UIButton!
    
    
    @IBOutlet private weak var friendsTabelView: UITableView!
    
    private var activeButton: UIButton?
    private var friends = [Friend]()
    private var buttons: [UIButton] { [
        requestButton,
        allFriendsButton,
        followersButton,
        addFriendButton
    ] }
    
    private let profileID = KeychainSwift.shared.get(ConstantKeys.currentProfile)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTabelView.delegate = self
        friendsTabelView.dataSource = self
        activeButton = allFriendsButton
        buttons.forEach {
            $0.isUserInteractionEnabled = false
        }
        
        guard let profileID = profileID else {
            forceQuitFromProfile()
            return
        }
        
        mainActivityIndicator.startAnimating()
        
        FireBaseDataBaseManager.getFriends(profileID, where: .friends)
        { [weak self] friends in
            
            self?.buttons.forEach {
                $0.isUserInteractionEnabled = true
            }
            
            self?.mainActivityIndicator.stopAnimating()
            
            guard let friends = friends else {
                showAlert("Ваш список друзей пуст", "Добавьте друзей и выполняйте задания вместе!", where: self)
                
                return
            }
            
            self?.friends = friends
            self?.friendsTabelView.reloadData()
            
        }
        
    }
    
    func setActiveButton(_ button: UIButton?) {
        activeButton?.backgroundColor = #colorLiteral(red: 0.1108371988, green: 0, blue: 1, alpha: 1)
        activeButton = button
        activeButton?.backgroundColor = #colorLiteral(red: 0.03359736346, green: 0.4016051504, blue: 1, alpha: 1)
    }
    
    @IBAction func didTapRequestButton(_ sender: UIButton) {
        
        guard activeButton != sender else { return }
        
        setActiveButton(sender)
        
    }
    
    @IBAction func didTapAllFriendsButton(_ sender: UIButton) {
        
        guard activeButton != sender else { return }
        
        setActiveButton(sender)
        
    }
    
    @IBAction func didTapFollowersButton(_ sender: UIButton) {
        
        guard activeButton != sender else { return }
        
        setActiveButton(sender)
        
    }
    
    @IBAction func didTapAddFriendButton(_ sender: UIButton) {
        
    }
    
}

extension FriendsViewController: UITableViewDelegate {
    
}

extension FriendsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsTVCell", for: indexPath as IndexPath)
        
        let friend = friends[indexPath.row]
        
        let photo = UIImage(named: "jpgDefault")!
        let name = friend.firstName + " " + friend.secondName
        let index = friend.city.firstIndex(of: ",")
        let city = index == nil ? friend.city : String(friend.city[friend.city.startIndex...index!])
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        let date = friend.dateOfBirth != nil ? formatter.date(from: friend.dateOfBirth!) : nil
        
        (cell as? SetFriendsCellInfo)?.setFriendsInfo(photo: photo, name: name,
                                                      city: city, onlineStatus: friend.onlineStatus,
                                                      dateOfBirth: date)
        
        return cell
    }
    
    
}

