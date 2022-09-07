//
//  AddFriendsViewController.swift
//  Karmus
//
//  Created by VironIT on 9/6/22.
//

import UIKit

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
    }
    
    private func searchingStarted(){
        mainTableView.isHidden = true
        mainActivityIndicator.startAnimating()
    }
    
    private func searchingEnded(){
        mainTableView.isHidden = false
        mainActivityIndicator.stopAnimating()
    }

}

extension AddFriendsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        let text = searchController.searchBar.text ?? ""
        FireBaseDataBaseManager.stopSearching()
        searchingStarted()
        FireBaseDataBaseManager.searchProfiles(text) { [weak self] profiles in
            
            self?.searchResult = profiles ?? []
            self?.mainTableView.reloadData()
            self?.searchingEnded()
            FireBaseDataBaseManager.stopSearching()
            
        }
        
    }
}

extension AddFriendsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.isHidden = true
        let profile = searchResult[indexPath.row]
        

    }
    
    private func addToFriend() {
        
    }
    
}

extension AddFriendsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("\nMYLOG: 123321`\n")
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
