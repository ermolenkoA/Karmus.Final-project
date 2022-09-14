//
//  CreateNewChatViewController.swift
//  Karmus
//
//  Created by VironIT on 9/10/22.
//

import UIKit

final class CreateNewChatViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet private weak var mainActivityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var mainTableView: UITableView!
    
    // MARK: - Private Properties
    
    private var searchController: UISearchController!
    private var searchResult: [ProfileForChatModel]! = []
    private var conclusion: ((ProfileForChatModel, String?) -> ())?
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        
        self.title = "Перейти к чату"
        
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
        searchResult = nil
        FireBaseDataBaseManager.stopProfilesSearching()
    }
    
    private func searchingStarted(){
        mainTableView.isHidden = true
        mainActivityIndicator.startAnimating()
    }
    
     // MARK: - Private functions
    
    private func searchingEnded(){
        mainTableView.isHidden = false
        mainActivityIndicator.stopAnimating()
    }

}

// MARK: - CreateNewChatConclusionProtocol

extension CreateNewChatViewController: CreateNewChatConclusionProtocol {
    func getConclusion(_ conclusion: @escaping (ProfileForChatModel, String?) -> ()) {
        self.conclusion = conclusion
    }
}

// MARK: - UISearchResultsUpdating

extension CreateNewChatViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let text = searchController.searchBar.text ?? ""
        FireBaseDataBaseManager.stopProfilesSearching()
        searchingStarted()
        FireBaseDataBaseManager.searchAllProfiles(text) { [weak self] profiles in
            
            self?.searchResult = profiles ?? []
            self?.mainTableView.reloadData()
            self?.searchingEnded()
            
        }
        
    }
    
}

// MARK: - UITableViewDelegate

extension CreateNewChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController?.isActive = false
        tableView.deselectRow(at: indexPath, animated: true)
        searchingStarted()
        
        let profile = searchResult[indexPath.row]
        
        FireBaseDataBaseManager.findChat(profile.login) { [weak self] chatID in
            
            var title = ""
            
            if chatID != nil {
                title = "Желаете перейти к чату с пользователем?"
            } else {
                title = "Начать чат с пользователем?"
            }
            
            var alert: UIAlertController! = .init(title: title,
                                                  message: "@" + profile.login,
                                                  preferredStyle: .alert)
            
            let sumbitButton = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
                self?.conclusion?(profile, chatID)
                alert = nil
            }
            
            let backButton = UIAlertAction(title: "Вернуться", style: .default) { _ in
                alert = nil
            }
            
            alert.addAction(sumbitButton)
            alert.addAction(backButton)
            alert.view.tintColor = .black
            self?.searchingEnded()
            self?.present(alert, animated: true)
            
        }
    
    }
    
}

// MARK: - UITableViewDataSource

extension CreateNewChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath)
        
        let profile = searchResult[indexPath.row]

        let name = profile.name
        
        let index = profile.city.firstIndex(of: ",")
        let city = index == nil ? profile.city
            : String(profile.city[profile.city.startIndex..<index!])
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        let date = profile.dateOfBirth != nil ? formatter.date(from: profile.dateOfBirth!) : nil
        
        (cell as? SetProfilesCellProtocol)?.setProfilesCell(photo: profile.photo, name: name,
                                                            city: city, onlineStatus: profile.onlineStatus,
                                                            profileType: profile.profileType, login: profile.login,
                                                            dateOfBirth: date)
        
        return cell
        
    }
    
}

