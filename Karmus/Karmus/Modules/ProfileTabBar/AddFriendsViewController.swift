//
//  AddFriendsViewController.swift
//  Karmus
//
//  Created by VironIT on 9/6/22.
//

import UIKit
import KeychainSwift

final class AddFriendsViewController: UIViewController {

    @IBOutlet private weak var mainActivityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var mainTableView: UITableView!
    
    private var searchController: UISearchController!
    private var searchResult = [Friend]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Введите логин..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.isActive = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        searchController = nil
        FireBaseDataBaseManager.stopProfilesSearching()
    }
    
    private func searchingStarted(){
        mainTableView.isHidden = true
        mainActivityIndicator.startAnimating()
    }
    
    private func searchingEnded(){
        mainTableView.isHidden = false
        mainActivityIndicator.stopAnimating()
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
        (shortProfileInfoVC as? GetShortProfileInfoProtocol)?.getShortProfileInfo(profile: profile, friendStatus)
        
        self.present(shortProfileInfoVC, animated: true)
    }

}

extension AddFriendsViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}

extension AddFriendsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        let text = searchController.searchBar.text ?? ""
        FireBaseDataBaseManager.stopProfilesSearching()
        searchingStarted()
        FireBaseDataBaseManager.searchProfiles(text) { [weak self] profiles in
            
            self?.searchResult = profiles ?? []
            self?.mainTableView.reloadData()
            self?.searchingEnded()
            
        }
        
    }
}

extension AddFriendsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let profile = searchResult[indexPath.row]
        
        guard let myProfileID = KeychainSwift.shared.get(ConstantKeys.currentProfile) else { return }
        
        let profileInfo = ShortProfileInfoModel.init(login: profile.login,
                                                     firstName: profile.firstName,
                                                     secondName: profile.secondName,
                                                     numberOfRespects: String.makeStringFromNumber(profile.numberOfRespects),
                                                     numberOfFriends: String.makeStringFromNumber(profile.numberOfFriends),
                                                     photo: UIImage(named: "jpgDefaultProfile")!,
                                                     profileType: profile.profileType)
        
        FireBaseDataBaseManager.getFriendStatus(myProfileID, friendLogin: profile.login) { [weak self] friendStatus in
            self?.showShortProfileInfo(profile: profileInfo, friendStatus: friendStatus)
        }
        

    }
    
}

extension AddFriendsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath)
        
        let friend = searchResult[indexPath.row]
        
        let photo = UIImage(named: "jpgDefaultProfile")!
        let name = friend.firstName + " " + friend.secondName
        let index = friend.city.firstIndex(of: ",")
        let city = index == nil ? friend.city
            : String(friend.city[friend.city.startIndex..<index!])
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        let date = friend.dateOfBirth != nil ? formatter.date(from: friend.dateOfBirth!) : nil
        
        (cell as? SetFriendsCellInfo)?.setFriendsInfo(photo: photo,
                                                      name: name,
                                                      city: city,
                                                      onlineStatus: friend.onlineStatus,
                                                      login: friend.login,
                                                      dateOfBirth: date)
        
        return cell
    }
    
    
}
